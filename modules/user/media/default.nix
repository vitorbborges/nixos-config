{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mpv              # video player (superior Wayland support vs VLC)
    yt-dlp           # download video/audio from YouTube and 400+ sites
    ffmpeg           # audio/video conversion and processing
    wiremix          # PipeWire-native TUI mixer ($mod+S)
    bluetui          # Bluetooth TUI manager ($mod+B)
    wl-clipboard     # wl-copy / wl-paste — required by cliphist
    wifitui          # WiFi TUI manager ($mod+W)
    qalculate-gtk    # calculator: powerful (unit conversion, symbolic math); CLI: `qalc`
    nautilus         # GUI file manager for drag-and-drop heavy tasks
    prismlauncher    # Minecraft launcher — set JVM arg -Dsun.java2d.uiScale=2 for HiDPI
  ];
}
