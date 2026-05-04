{ inputs, pkgs, ... }:
{
  # nix-matlab overlay — provides pkgs.matlab (FHS env wrapper) and pkgs.matlab-shell
  nixpkgs.overlays = [ inputs.nix-matlab.overlay ];

  virtualisation.podman.enable = true;

  environment.systemPackages = [
    pkgs.distrobox
    # Wrap matlab to force X11 backend: MATLAB has no native Wayland support and the
    # global QT_QPA_PLATFORM=wayland session var would crash it on launch.
    (pkgs.writeShellScriptBin "matlab" ''
      exec env QT_QPA_PLATFORM=xcb MATLAB_INSTALL_DIR=/home/vitor/MATLAB/R2026a ${pkgs.matlab}/bin/matlab "$@"
    '')
    # FHS shell for running the MATLAB installer
    pkgs.matlab-shell
    # Fallback for the grey-window bug: run `wmname LG3D` before launching MATLAB
    pkgs.wmname
  ];

  # Stable host ID — prevents MATLAB license mismatch after reboots.
  # Derived from: head -c 8 /etc/machine-id
  networking.hostId = "47ba388a";
}
