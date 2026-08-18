{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.memtest86.enable = true;

  # Force S3 (suspend-to-RAM) instead of S0ix (connected standby).
  # S0ix keeps the CPU partially active — NVIDIA stays on, fan spins, battery drains with lid closed.
  boot.kernelParams = [ "mem_sleep_default=deep" ];
}
