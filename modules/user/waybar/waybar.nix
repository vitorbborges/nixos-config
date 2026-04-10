{ lib, pkgs, ... }:

let
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
      modules-right  = [ "custom/weather" "network" "pulseaudio" "battery" "custom/notification" ];

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          active  = "";
          default = "";
          urgent  = "󰀨";
        };
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

      pulseaudio = {
        format       = "{icon}  {volume}%";
        format-muted = "󰝟";
        format-icons = {
          headphone  = "󰋋";
          headset    = "󰋎";
          default    = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click    = "kitty -e wiremix";
        scroll-step = 5;
        tooltip-format = "{desc}";
      };

      battery = {
        states = { warning = 30; critical = 15; };
        format          = "{icon}  {capacity}%";
        format-charging = "󰂄  {capacity}%";
        format-plugged  = "󰚥  {capacity}%";
        format-full     = "󰁹  {capacity}%";
        format-icons    = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        tooltip-format  = "{timeTo}\n{power:.1f} W";
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
