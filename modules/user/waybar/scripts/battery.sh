cap_file="/sys/class/power_supply/BAT0/capacity"
status_file="/sys/class/power_supply/BAT0/status"
power_file="/sys/class/power_supply/BAT0/power_now"
energy_now_file="/sys/class/power_supply/BAT0/energy_now"
energy_full_file="/sys/class/power_supply/BAT0/energy_full"

if [[ ! -f "$cap_file" ]]; then
  printf '{"text": "󰂑  --%%", "class": "unknown"}\n'
  exit 0
fi

raw=$(< "$cap_file")
status=$(< "$status_file")

time_info=""
if [[ -f "$power_file" && -f "$energy_now_file" && -f "$energy_full_file" ]]; then
  power_now=$(< "$power_file")
  energy_now=$(< "$energy_now_file")
  energy_full=$(< "$energy_full_file")

  if [[ "$power_now" -gt 0 ]]; then
    case "$status" in
      Discharging)
        total_minutes=$(( energy_now * 60 / power_now ))
        time_info="⏳ $(( total_minutes / 60 ))h $(( total_minutes % 60 ))m remaining"
        ;;
      Charging)
        total_minutes=$(( (energy_full - energy_now) * 60 / power_now ))
        time_info="⚡ $(( total_minutes / 60 ))h $(( total_minutes % 60 ))m until full"
        ;;
    esac
  fi
fi

display=$(( raw * 100 / 80 ))
[[ "$display" -gt 100 ]] && display=100

case "$status" in
  Charging)
    icon="󰂄"; class="charging" ;;
  Full)
    icon="󰁹"; display=100; class="full" ;;
  *)
    if   [[ "$display" -ge 90 ]]; then icon="󰂂"
    elif [[ "$display" -ge 70 ]]; then icon="󰂀"
    elif [[ "$display" -ge 50 ]]; then icon="󰁾"
    elif [[ "$display" -ge 30 ]]; then icon="󰁼"
    elif [[ "$display" -ge 10 ]]; then icon="󰁻"
    else                               icon="󰁺"
    fi
    if   [[ "$display" -le 10 ]]; then class="critical"
    elif [[ "$display" -le 25 ]]; then class="warning"
    else                               class="discharging"
    fi
    ;;
esac

tooltip="Raw: ${raw}% | ${status}"
[[ -n "$time_info" ]] && tooltip="${tooltip}\n${time_info}"

printf '{"text": "%s  %d%%", "class": "%s", "percentage": %d, "tooltip": "%s"}\n' \
  "$icon" "$display" "$class" "$display" "$tooltip"
