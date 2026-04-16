{ pkgs, ... }:

let
  screenshot-area = pkgs.writeShellApplication {
    name = "hl-screenshot-area";
    runtimeInputs = with pkgs; [ grim slurp libnotify wl-clipboard ];
    text = builtins.readFile ./scripts/screenshot-area.sh;
  };
  screenshot-full = pkgs.writeShellApplication {
    name = "hl-screenshot-full";
    runtimeInputs = with pkgs; [ grim libnotify wl-clipboard ];
    text = builtins.readFile ./scripts/screenshot-full.sh;
  };
  kb-switch = pkgs.writeShellApplication {
    name = "hl-kb-switch";
    runtimeInputs = with pkgs; [ hyprland jq libnotify ];
    text = ''
      hyprctl switchxkblayout all next
      layout=$(hyprctl devices -j | jq -r '[.keyboards[] | select(.main == true) | .active_keymap][0]')
      notify-send -t 2000 " Layout" "$layout"
    '';
  };
in

{
  home.packages = [ screenshot-area screenshot-full kb-switch ];

  wayland.windowManager.hyprland.settings = {

    bind = [
      # Apps
      "$mod, RETURN, exec, kitty"
      "$mod SHIFT, RETURN, exec, [float] kitty"
      "$mod, Z, exec, zen-beta"
      "$mod, B, exec, kitty -e bluetui"
      "$mod, W, exec, kitty -e wifitui"
      "$mod, C, exec, codium"
      "$mod, M, exec, spotify"
      "$mod, S, exec, kitty -e wiremix"
      "$mod, E, exec, kitty -e yazi"
      "$mod, EQUAL, exec, kitty -e qalc"
      # Window management
      "$mod, Q, killactive"
      "$mod SHIFT, Q, exit"
      "$mod SHIFT, F, togglefloating"
      "$mod, F, fullscreen"
      "$mod CTRL, F, fullscreen, 1"        # fake fullscreen: maximized without true FS
      "$mod, P, pseudo"
      "$mod, J, togglesplit"
      # Launchers and utilities
      "$mod, R, exec, fuzzel"
      "$mod, V, exec, cliphist list | fuzzel --dmenu -p '  Clipboard' | cliphist decode | wl-copy"
      "$mod SHIFT, V, exec, cliphist wipe"
      "$mod SHIFT, W, exec, kitty --class wallpaper-picker -T 'Wallpaper Picker' -e wallpaper-picker"
      # System
      "$mod, A, exec, pypr expose"
      "CTRL ALT, L, exec, pidof hyprlock || hyprlock"
      "$mod, SPACE, exec, hl-kb-switch"
      "$mod CTRL ALT, B, exec, pkill -SIGUSR1 waybar"
      # Screenshots (scripts in ./scripts/, packaged as hl-screenshot-*)
      ", Print, exec, hl-screenshot-area"
      "SHIFT, Print, exec, hl-screenshot-full"
      # Focus
      "$mod, left,  movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up,    movefocus, u"
      "$mod, down,  movefocus, d"
      # Move windows
      "$mod SHIFT, left,  movewindow, l"
      "$mod SHIFT, right, movewindow, r"
      "$mod SHIFT, up,    movewindow, u"
      "$mod SHIFT, down,  movewindow, d"
      # Resize active window
      "$mod ALT, left,  resizeactive, -50 0"
      "$mod ALT, right, resizeactive,  50 0"
      "$mod ALT, up,    resizeactive,  0 -50"
      "$mod ALT, down,  resizeactive,  0  50"
      # Workspaces
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      # Multi-monitor
      "$mod, comma,        focusmonitor, l"
      "$mod, period,       focusmonitor, r"
      "$mod SHIFT, comma,  movecurrentworkspacetomonitor, l"
      "$mod SHIFT, period, movecurrentworkspacetomonitor, r"
    ];

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # Repeating — hold to keep raising/lowering
    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ && notify-send -t 1000 -h string:x-canonical-private-synchronous:audio '󰕾 Volume' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@)\""
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send -t 1000 -h string:x-canonical-private-synchronous:audio '󰕾 Volume' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@)\""
      # Screen brightness (Fn+F6/F7 on ASUS)
      ", XF86MonBrightnessUp,   exec, brightnessctl set 10%+ && notify-send -t 1000 -h string:x-canonical-private-synchronous:brightness '󰃠 Brightness' \"$(brightnessctl -m | cut -d, -f4)\""
      ", XF86MonBrightnessDown, exec, brightnessctl set 10%- && notify-send -t 1000 -h string:x-canonical-private-synchronous:brightness '󰃟 Brightness' \"$(brightnessctl -m | cut -d, -f4)\""
      # Keyboard backlight (Fn+F3/F4 on ASUS)
      ", XF86KbdBrightnessUp,   exec, brightnessctl -d '*::kbd_backlight' set 10%+"
      ", XF86KbdBrightnessDown, exec, brightnessctl -d '*::kbd_backlight' set 10%-"
    ];

    # Locked — work even on lock screen
    bindl = [
      ", XF86AudioMute,    exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify-send -t 1000 -h string:x-canonical-private-synchronous:audio '󰝟 Audio' 'Mute toggled'"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];
  };
}
