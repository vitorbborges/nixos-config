{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Intel VMD (Volume Management Device) is required to expose the NVMe SSD.
  # Without `vmd` in initrd the drive is invisible at boot.
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # NOTE: These UUIDs reflect the current Ubuntu partition layout.
  # After installing NixOS run `nixos-generate-config` and replace with the new UUIDs,
  # or update them manually from `lsblk -o NAME,UUID`.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/399218fd-2001-4fe9-b27a-9041990fdae1";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/CFD7-CDB1";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
