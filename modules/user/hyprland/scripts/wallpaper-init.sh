until awww query &>/dev/null; do sleep 0.1; done
last="$HOME/.config/awww/last-wallpaper"
if [[ -f "$last" && -f "$(cat "$last")" ]]; then
  awww img "$(cat "$last")" --transition-type none
else
  awww img "@stylixImage@" --transition-type none
fi
