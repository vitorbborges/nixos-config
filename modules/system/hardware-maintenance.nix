{ ... }:

{
  services.fwupd.enable = true;
  services.fstrim.enable = true;
  # Load Intel thermal sensor module so lm_sensors and sysdiag can read CPU temps
  boot.kernelModules = [ "coretemp" ];
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
