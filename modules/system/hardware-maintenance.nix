{ pkgs, ... }:

{
  services.fwupd.enable = true;
  services.fstrim.enable = true;
  # Load Intel thermal sensor module so lm_sensors and sysdiag can read CPU temps
  boot.kernelModules = [ "coretemp" ];

  # Let sysdiag read full NVMe SMART data without a password prompt.
  # Scoped to exactly these two read-only diagnostic invocations on this
  # machine's single NVMe device — not a blanket smartctl/nvme grant.
  security.sudo.extraRules = [
    {
      users = [ "vitor" ];
      commands = [
        {
          command = "${pkgs.smartmontools}/bin/smartctl -a /dev/nvme0n1";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nvme-cli}/bin/nvme smart-log /dev/nvme0n1";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  # Automatically switches CPU governor based on AC/battery state
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo    = "auto";      # allows boost when CPU is under heavy load on battery
      };
      charger = {
        governor = "performance";
        turbo    = "auto";
      };
    };
  };
}
