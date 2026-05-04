{ pkgs, ... }:

{
  # Daemon: watches clipboard and stores text + images into SQLite history
  services.cliphist = {
    enable = true;
    allowImages = true;
    extraOptions = [
      "-max-dedupe-search" "100"
      "-max-items" "750"
    ];
  };

  # On Wayland the clipboard is "live": the source app must keep serving data.
  # When the source closes or relinquishes ownership, Ctrl+V yields nothing.
  # wl-clip-persist watches both CLIPBOARD and PRIMARY buffers and immediately
  # re-offers the content from a background process, so the clipboard survives
  # focus changes and app exits for all Wayland-native apps.
  systemd.user.services.wl-clip-persist = {
    Unit = {
      Description = "Keep Wayland clipboard alive after source app closes";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
