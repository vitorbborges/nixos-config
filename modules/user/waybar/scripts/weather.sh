set -euo pipefail
fallback() {
  echo '{"text": "󰖑  --°C", "tooltip": "Weather unavailable"}'
  exit 0
}

data=$(curl -sf --max-time 10 "https://wttr.in/?format=j1") || fallback

echo "$data" | jq -e . >/dev/null 2>&1 || fallback

temp=$(echo "$data"    | jq -r '.current_condition[0].temp_C')
feels=$(echo "$data"   | jq -r '.current_condition[0].FeelsLikeC')
desc=$(echo "$data"    | jq -r '.current_condition[0].weatherDesc[0].value')
wind=$(echo "$data"    | jq -r '.current_condition[0].windspeedKmph')
humidity=$(echo "$data"| jq -r '.current_condition[0].humidity')
code=$(echo "$data"    | jq -r '.current_condition[0].weatherCode')
city=$(echo "$data"    | jq -r '.nearest_area[0].areaName[0].value')

case "$code" in
  113)                     icon="☀️" ;;   # Sunny / Clear
  116)                     icon="⛅" ;;   # Partly cloudy
  119|122)                 icon="☁️" ;;   # Cloudy / Overcast
  143|248|260)             icon="🌫️" ;;  # Fog / Mist
  200|386|389|392|395)     icon="⛈️" ;;  # Thunderstorm
  323|326|329|332|335|338|368|371) icon="❄️" ;;  # Snow
  350|374|377)             icon="🌨️" ;;  # Ice / Sleet
  *)                       icon="🌧️" ;;  # Rain (all other codes)
esac

tooltip="$desc\n$city\nFeels like ${feels}°C · Wind ${wind} km/h · Humidity ${humidity}%"
echo "{\"text\": \"$icon  ${temp}°C\", \"tooltip\": \"$tooltip\"}"
