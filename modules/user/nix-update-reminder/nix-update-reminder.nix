{ pkgs, ... }:

let
  stampFile = "$HOME/.local/share/nix-update-last";
  checkScript = pkgs.writeShellScript "nix-update-check" ''
    STAMP=${stampFile}
    THRESHOLD=7

    if [ ! -f "$STAMP" ]; then
      ${pkgs.libnotify}/bin/notify-send \
        --urgency=normal \
        --icon=system-software-update \
        'NixOS Update Reminder' \
        'No update recorded yet. Run nix-update to keep your system fresh!'
      exit 0
    fi

    LAST=$(cat "$STAMP")
    NOW=$(${pkgs.coreutils}/bin/date +%s)
    DAYS=$(( (NOW - LAST) / 86400 ))

    if [ "$DAYS" -ge "$THRESHOLD" ]; then
      ${pkgs.libnotify}/bin/notify-send \
        --urgency=normal \
        --icon=system-software-update \
        'NixOS Update Reminder' \
        "It's been ''${DAYS} days since your last update. Run nix-update!"
    fi
  '';
in
{
  systemd.user.services.nix-update-reminder = {
    Unit.Description = "NixOS flake update reminder";
    Service = {
      Type = "oneshot";
      ExecStart = "${checkScript}";
    };
  };

  systemd.user.timers.nix-update-reminder = {
    Unit.Description = "Daily NixOS flake update reminder";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
