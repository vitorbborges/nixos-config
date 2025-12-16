{ config, lib, ... }:

{
  # Set default applications
  xdg.mimeApps.defaultApplications = lib.mkMerge [
    (lib.mkIf (config.programs.sioyek.enable && config.programs.zathura.enable) {
      "application/pdf" = [ "sioyek.desktop" "org.pwmt.zathura.desktop" ];
    })
  ];
}
