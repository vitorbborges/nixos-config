{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    timeshift
    gparted
    wget
  ];

  # gvfs: lets Nautilus (and other GTK apps) see and mount removable drives via udisks2
  services.gvfs.enable = true;

  # GameMode daemon — CPU/GPU scheduling boost when a game starts (Steam enables automatically)
  programs.gamemode.enable = true;

  # nix-ld: compatibility shim that lets unpatched ELF binaries (pip/uv/npm wheels) find
  # system libraries. Without this, packages like torch fail with "cannot open shared object file".
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib   # libstdc++.so.6 — required by torch, numpy, etc.
      zlib               # libz.so.1
      libGL              # torch GPU ops
      glib               # libglib-2.0.so.0
    ];
  };
}
