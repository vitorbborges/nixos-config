hyprctl switchxkblayout all next
layout=$(hyprctl devices -j | jq -r '[.keyboards[] | select(.main == true) | .active_keymap][0]')
notify-send -t 2000 " Layout" "$layout"
