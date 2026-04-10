{ ... }: {

  wayland.windowManager.hyprland.settings = {

    input = {
      kb_layout = "us,br";
      repeat_rate = 50;
      repeat_delay = 300;
      numlock_by_default = true;
      follow_mouse = 1;
      sensitivity = 0;
      touchpad = {
        natural_scroll = true;
        tap-to-click = true;
        disable_while_typing = true;
      };
    };

    # 3-finger horizontal swipe → switch workspace (Hyprland 0.47+ gesture keyword)
    gesture = "3, horizontal, workspace";

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 2;
      layout = "dwindle";
      resize_on_border = true;   # drag window borders without any modifier key
    };

    decoration = {
      rounding = 12;
      inactive_opacity = 0.85;
      blur = {
        enabled = true;
        size = 8;
        passes = 2;
        noise = 0.05;
        xray = false;
      };
      shadow = {
        enabled = true;
        range = 20;
        render_power = 4;
      };
    };

    animations = {
      enabled = true;
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    # $mod+N twice = jump back to previous workspace; cycles wraps 5 → 1
    binds = {
      workspace_back_and_forth = true;
      allow_workspace_cycles = true;
    };

    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      vfr = true;
      mouse_move_enables_dpms = true;  # mouse movement wakes screen after DPMS off
      focus_on_activate = false;        # apps cannot steal focus
    };

    # Prevents XWayland apps from rendering blurry at 2× scale on 3200x2000
    xwayland = {
      force_zero_scaling = true;
    };
  };
}
