WALLPAPER="${1:-}"

if [[ -z "$WALLPAPER" ]]; then
  echo "Usage: wallpaper-switch <path-to-image>"
  exit 1
fi

if [[ ! -f "$WALLPAPER" ]]; then
  notify-send -u critical "wallpaper-switch" "File not found: $WALLPAPER"
  exit 1
fi

WALLPAPER_ABS="$(realpath "$WALLPAPER")"

# 1. Set wallpaper via awww (immediate, no rebuild needed)
if ! awww img "$WALLPAPER_ABS" --transition-type wipe --transition-angle 30 --transition-duration 1; then
  notify-send -u critical "wallpaper-switch" "awww failed — is awww-daemon running?"
  exit 1
fi

# 2. Persist for next login
mkdir -p "$HOME/.config/awww"
echo "$WALLPAPER_ABS" > "$HOME/.config/awww/last-wallpaper"

notify-send -t 3000 "󰋩 Wallpaper" "$(basename "$WALLPAPER_ABS")"

# 3. Extract accent colors and update Hyprland borders live
if command -v matugen &>/dev/null; then
  COLORS=$(matugen image "$WALLPAPER_ABS" --json 2>/dev/null || echo "{}")
  PRIMARY=$(echo "$COLORS" | jq -r '.colors.dark.primary // empty' 2>/dev/null || echo "")
  SECONDARY=$(echo "$COLORS" | jq -r '.colors.dark.secondary // empty' 2>/dev/null || echo "")

  if [[ -n "$PRIMARY" ]]; then
    P="${PRIMARY#\#}"
    S="${SECONDARY:-$PRIMARY}"
    S="${S#\#}"
    hyprctl keyword general:col.active_border   "rgba(${P}ff) rgba(${S}ff) 45deg" 2>/dev/null || true
    hyprctl keyword general:col.inactive_border "rgba(${S}33)" 2>/dev/null || true
  fi
fi
