{ ... }: {

  wayland.windowManager.hyprland.settings = {

    # Hyprland v0.47+ layerrule syntax: "key value, match:namespace regex"
    layerrule = [
      "match:namespace waybar, blur 1"
      "match:namespace swaync-notification-window, blur 0"
      "match:namespace swaync-control-center, blur 1"
    ];

    windowrule = [
      # Wallpaper picker (fzf + kitty image preview)
      "float on, match:class wallpaper-picker"
      "size 1200 700, match:class wallpaper-picker"
      "center on, match:class wallpaper-picker"
      # Clipboard picker (cliphist via fuzzel dmenu)
      "float on, match:class clipboard-picker"
      "size 600 400, match:class clipboard-picker"
      "center on, match:class clipboard-picker"
      # Prevent idle/lock while anything is fullscreen (videos, games, calls)
      "idle_inhibit always, match:fullscreen on"
      # Picture-in-Picture — float, pin on top, keep aspect ratio, top-right corner
      "float on, match:title Picture-in-Picture"
      "pin on, match:title Picture-in-Picture"
      "keep_aspect_ratio on, match:title Picture-in-Picture"
      "move 72% 7%, match:title Picture-in-Picture"
    ];
  };
}
