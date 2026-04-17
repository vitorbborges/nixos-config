{ lib, ... }:

# Terminal tools for server hosts: nvim (full config), zsh, yazi, git.
# Excludes all desktop/Wayland/Hyprland/Stylix modules.
let
  nvimDir = ../user/nvim;
  getDir = dir: lib.mapAttrs
    (file: type:
      if type == "directory" then getDir "${dir}/${file}" else type)
    (builtins.readDir dir);
  files = dir: lib.collect lib.isString
    (lib.mapAttrsRecursive (path: type: lib.concatStringsSep "/" path) (getDir dir));
  importDir = dir: map
    (file: dir + "/${file}")
    (builtins.filter
      (file: lib.hasSuffix ".nix" file && file != "default.nix")
      (files dir));
in {
  imports =
    (importDir nvimDir)
    ++ [
      ../user/zsh/zsh.nix
      ../user/yazi/yazi.nix
      ../user/git/git.nix
    ];
}
