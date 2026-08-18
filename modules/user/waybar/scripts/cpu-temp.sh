input=$(ls /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input 2>/dev/null | head -1)
if [[ -n "$input" ]]; then
  temp=$(( $(cat "$input") / 1000 ))
  echo "󰘚  ${temp}°C"
else
  echo "󰘚  --°C"
fi
