{ lib, pkgs, ... }:

let
  cpu-temp = pkgs.writeShellScript "waybar-cpu-temp" ''
    input=$(ls /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input 2>/dev/null | head -1)
    if [[ -n "$input" ]]; then
      temp=$(( $(cat "$input") / 1000 ))
      echo "󰘚  ''${temp}°C"
    else
      echo "󰘚  --°C"
    fi
  '';

  battery-custom = pkgs.writeShellScript "waybar-battery" ''
    cap_file="/sys/class/power_supply/BAT0/capacity"
    status_file="/sys/class/power_supply/BAT0/status"

    if [[ ! -f "$cap_file" ]]; then
      printf '{"text": "󰂑  --%%", "class": "unknown"}\n'
      exit 0
    fi

    raw=$(< "$cap_file")
    status=$(< "$status_file")

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

    printf '{"text": "%s  %d%%", "class": "%s", "percentage": %d, "tooltip": "Raw: %d%% | %s"}\n' \
      "$icon" "$display" "$class" "$display" "$raw" "$status"
  '';

  weather = pkgs.writeShellScript "waybar-weather" ''
    set -euo pipefail
    data=$(${pkgs.curl}/bin/curl -sf --max-time 10 "https://wttr.in/?format=j1") || {
      echo '{"text": "󰖑  --°C", "tooltip": "Weather unavailable"}'
      exit 0
    }

    temp=$(echo "$data"    | ${pkgs.jq}/bin/jq -r '.current_condition[0].temp_C')
    feels=$(echo "$data"   | ${pkgs.jq}/bin/jq -r '.current_condition[0].FeelsLikeC')
    desc=$(echo "$data"    | ${pkgs.jq}/bin/jq -r '.current_condition[0].weatherDesc[0].value')
    wind=$(echo "$data"    | ${pkgs.jq}/bin/jq -r '.current_condition[0].windspeedKmph')
    humidity=$(echo "$data"| ${pkgs.jq}/bin/jq -r '.current_condition[0].humidity')
    code=$(echo "$data"    | ${pkgs.jq}/bin/jq -r '.current_condition[0].weatherCode')
    city=$(echo "$data"    | ${pkgs.jq}/bin/jq -r '.nearest_area[0].areaName[0].value')

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

    tooltip="$desc\n$city\nFeels like ''${feels}°C · Wind ''${wind} km/h · Humidity ''${humidity}%"
    echo "{\"text\": \"$icon  ''${temp}°C\", \"tooltip\": \"$tooltip\"}"
  '';
in

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [{
      layer = "top";
      position = "top";
      exclusive = true;
      margin-top = 8;
      margin-left = 12;
      margin-right = 12;
      height = 40;

      modules-left   = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right  = [ "custom/weather" "custom/cpu-temp" "network" "pulseaudio" "custom/battery" "custom/notification" ];

      "hyprland/workspaces" = {
        format = "{name}";
        format-icons.urgent = "󰀨";
        on-click = "activate";
        persistent-workspaces."*" = 5;
      };

      clock = {
        format = "{:%H:%M · %a %d %b %Y}";
        format-alt = "{:%A, %d %B %Y}";
        tooltip-format = "<big>{:%A, %d %B %Y}</big>\n<tt><small>{calendar}</small></tt>";
      };

      "custom/weather" = {
        exec = "${weather}";
        return-type = "json";
        interval = 1800;  # refresh every 30 minutes
        tooltip = true;
      };

      network = {
        format-wifi       = "🛜  {essid}";
        format-ethernet   = "🔗";
        format-disconnected = "󰖪";
        tooltip-format-wifi     = "{essid} ({signalStrength}%)\n{ifname}: {ipaddr}/{cidr}";
        tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
        on-click = "kitty -e wifitui";
        max-length = 18;
      };

      "custom/cpu-temp" = {
        exec     = "${cpu-temp}";
        interval = 5;
        format   = "{}";
      };

      pulseaudio = {
        format       = "{icon}  {volume}%";
        format-muted = "󰝟  {volume}%";
        format-icons = {
          headphone  = "󰋋";
          headset    = "󰋎";
          default    = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click    = "kitty -e wiremix";
        scroll-step = 5;
        tooltip-format = "{desc}";
      };

      "custom/battery" = {
        exec        = "${battery-custom}";
        return-type = "json";
        interval    = 10;
        tooltip     = true;
      };

      "custom/notification" = {
        tooltip = false;
        format = "{icon}";
        format-icons = {
          notification           = "󱅫";
          none                   = "󰂜";
          dnd-notification       = "󰂛";
          dnd-none               = "󰂛";
          inhibited-notification = "󱅫";
          inhibited-none         = "󰂜";
        };
        return-type = "json";
        exec-if     = "which swaync-client";
        exec        = "swaync-client -swb";
        on-click       = "sleep 0.1 && swaync-client -t -sw";
        on-click-right = "sleep 0.1 && swaync-client -d -sw";
        escape = true;
      };
    }];

    style = lib.mkAfter (builtins.readFile ./style.css);
  };
}
