set -euo pipefail

[ "$#" -gt 0 ] || exit 2

# ── robust MIME detection ──
mime=$(xdg-mime query filetype "$1" 2>/dev/null || true)
if [ -z "$mime" ] || [ "$mime" = "application/octet-stream" ]; then
  mime=$(file --brief --mime-type "$1" 2>/dev/null || true)
fi

# ── known terminal commands (without file args; files appended at runtime) ──
term_cmds_all=(
  "nvim  (editor)"$'\t'"nvim"
  "helix (editor)"$'\t'"helix"
  "nano  (editor)"$'\t'"nano"
  "micro (editor)"$'\t'"micro"
  "bat   (viewer)"$'\t'"bat --paging=always"
  "less  (viewer)"$'\t'"less"
  "cat   (viewer)"$'\t'"cat"
  "emacs (editor)"$'\t'"emacs"
)

# Only offer commands that actually exist on this system.
term_cmds=()
for entry in "${term_cmds_all[@]}"; do
  bin=$(printf '%s' "$entry" | cut -f2- | cut -d' ' -f1)
  command -v "$bin" >/dev/null 2>&1 && term_cmds+=("$entry")
done

# ── known GUI apps (offered for every file; filtered by availability) ──
known_apps_all=(
  "codium  (editor)"$'\t'"codium --force-device-scale-factor=2"
  "zathura (documents)"$'\t'"zathura"
  "gimp    (images)"$'\t'"gimp"
  "imv     (images)"$'\t'"imv"
  "mpv     (media)"$'\t'"mpv"
)
known_apps=()
for entry in "${known_apps_all[@]}"; do
  bin=$(printf '%s' "$entry" | cut -f2- | cut -d' ' -f1)
  command -v "$bin" >/dev/null 2>&1 && known_apps+=("$entry")
done

# ── collect .desktop apps from mimeinfo.cache ──
IFS=: read -ra _xdg_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
app_dirs=("${XDG_DATA_HOME:-$HOME/.local/share}" "${_xdg_dirs[@]}")

desktop_list=""
if [ -n "$mime" ]; then
  desktop_list=$(
    for dir in "${app_dirs[@]}"; do
      cache="$dir/applications/mimeinfo.cache"
      [ -f "$cache" ] || continue
      grep "^${mime}=" "$cache" 2>/dev/null | cut -d= -f2- | tr ';' '\n' || true
    done | sort -u | while IFS= read -r desktop_name; do
      [ -z "$desktop_name" ] && continue
      for adir in "${app_dirs[@]}"; do
        f="$adir/applications/$desktop_name"
        [ -f "$f" ] || continue
        name=$(grep -m1 "^Name=" "$f" 2>/dev/null | cut -d= -f2- || true)
        exec_line=$(grep -m1 "^Exec=" "$f" 2>/dev/null | cut -d= -f2- || true)
        terminal=$(grep -m1 "^Terminal=" "$f" 2>/dev/null | cut -d= -f2- || true)
        [ -n "$name" ] && [ -n "$exec_line" ] || continue
        [ "$terminal" = "true" ] && name="$name (terminal)"
        printf '%s\t%s\n' "$name" "$exec_line"
        break
      done
    done
  )
fi

# Keep file paths shell-quoted; plain "$*" breaks paths containing spaces.
file_args=""
for file in "$@"; do
  printf -v quoted ' %q' "$file"
  file_args+="$quoted"
done
printf -v first_q '%q' "$1"
printf -v dir_q '%q' "$(dirname -- "$1")"

# ── build fzf list: "label\tcommand [files]" ──
{
  for entry in "${term_cmds[@]}"; do
    printf '%s%s\n' "$entry" "$file_args"
  done

  for entry in "${known_apps[@]}"; do
    printf '%s%s\n' "$entry" "$file_args"
  done

  if [ -n "$desktop_list" ]; then
    printf '%s\n' "$desktop_list" | while IFS= read -r line; do
      app_name=$(printf '%s' "$line" | cut -f1)
      app_exec=$(printf '%s' "$line" | cut -f2-)
      printf '%s\t%s%s\n' "$app_name" "$app_exec" "$file_args"
    done
  fi

  printf '%s\t%s\n' "xdg-open  (system default)" "xdg-open $first_q"
  printf '%s\t%s%s\n' "nvim      (force)" "nvim" "$file_args"
  printf '%s\t%s\n' "  shell here" "cd $dir_q && exec $SHELL"
} | grep -v '^$' | while IFS= read -r raw; do
  label=$(printf '%s' "$raw" | cut -f1)
  cmd=$(printf '%s' "$raw" | cut -f2- | sed 's/ %[uUfFdDnNickvm]//g; s/%[uUfFdDnNickvm]//g')
  printf '%s\t%s\n' "$label" "$cmd"
done > /tmp/yazi-openwith-cache.$$ || true

[ ! -s /tmp/yazi-openwith-cache.$$ ] && { rm -f /tmp/yazi-openwith-cache.$$; exit 0; }

# ── fzf picker ──
if ! chosen=$(fzf --delimiter=$'\t' --with-nth=1 \
                 --prompt="open with → " \
                 --height=40% --layout=reverse --border=rounded \
                 --header=" $(basename "$1")  |  $mime " \
                 < /tmp/yazi-openwith-cache.$$); then
  rm -f /tmp/yazi-openwith-cache.$$
  exit 0
fi
rm -f /tmp/yazi-openwith-cache.$$

[ -z "$chosen" ] && exit 0

cmd=$(printf '%s' "$chosen" | cut -f2-)

# terminal editors run blocking; GUI apps are detached
case "$cmd" in
  nvim*|helix*|nano*|micro*|emacs*|"$SHELL"*)
    eval "exec $cmd" ;;
  cd\ *)
    eval "$cmd" ;;
  *)
    eval "$cmd" &>/dev/null & disown ;;
esac
