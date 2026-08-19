{ lib, pkgs, ... }:

let
  cpu-temp = pkgs.writeShellScript "waybar-cpu-temp"
    (builtins.readFile ./scripts/cpu-temp.sh);

  battery-custom = pkgs.writeShellScript "waybar-battery"
    (builtins.readFile ./scripts/battery.sh);

  weather = pkgs.writeShellApplication {
    name = "waybar-weather";
    runtimeInputs = with pkgs; [ curl jq ];
    text = builtins.readFile ./scripts/weather.sh;
  };
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
        calendar = {
          mode = "month";
          mode-mon-col = 4;
          weeks-pos = "right";
          first-day-of-week = 1;
          on-scroll = 1;
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };

      "custom/weather" = {
        exec = "${weather}/bin/waybar-weather";
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
