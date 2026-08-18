state_dir="${XDG_RUNTIME_DIR:-/tmp}"
alert15="$state_dir/battery-alert-15"
alert5="$state_dir/battery-alert-5"
cap_file="/sys/class/power_supply/BAT0/capacity"
status_file="/sys/class/power_supply/BAT0/status"

[[ -f "$cap_file" ]] || exit 0

level=$(cat "$cap_file")
status=$(cat "$status_file")

if [[ "$status" != "Discharging" ]]; then
  rm -f "$alert15" "$alert5"
  exit 0
fi

if [[ "$level" -le 5 ]] && [[ ! -f "$alert5" ]]; then
  notify-send --urgency=critical --expire-time=0 \
    "Battery Critical" "Only ${level}% left — plug in now!"
  paplay "@soundBatteryLow@" || true
  touch "$alert5"
elif [[ "$level" -le 15 ]] && [[ ! -f "$alert15" ]]; then
  notify-send --urgency=normal --expire-time=15000 \
    "Battery Low" "${level}% remaining — consider plugging in"
  paplay "@soundDialogWarning@" || true
  touch "$alert15"
fi
