{ ... }:
{
  systemd.services.battery-charge-threshold = {
    description = "Set ASUS K6604JI battery charge limit to 80%";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
    '';
  };

  powerManagement.resumeCommands = ''
    echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
  '';
}
