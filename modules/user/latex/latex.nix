{ pkgs, ... }:

{
  # TeX Live full scheme — same package universe Overleaf compiles with
  # (Overleaf = full-scheme TeX Live + latexmk). Any project cloned from
  # Overleaf's git bridge compiles here with zero package hunting.
  # Includes latexmk, pdfTeX/XeTeX/LuaLaTeX, and all CTAN packages.
  home.packages = with pkgs; [
    texliveFull
  ];

  # sioyek: the live-preview half of the dual-window VimTeX setup (see
  # nvim/vimtex.nix). Native Wayland (Qt6), auto-reloads when latexmk
  # rewrites the PDF, and has a first-class VimTeX forward/inverse search
  # backend — unlike zathura it needs no xdotool/DBus tricks on Hyprland.
  programs.sioyek = {
    enable = true;
  };
}
