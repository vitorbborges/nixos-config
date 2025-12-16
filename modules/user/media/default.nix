{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vlc
    mpv
    yt-dlp
    ffmpeg
  ];
}
