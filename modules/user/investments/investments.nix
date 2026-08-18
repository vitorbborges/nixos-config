{ pkgs, lib, ... }:

let
  investmentsDir = "/home/vitor/Investments";
  claudeBin      = "/etc/profiles/per-user/vitor/bin/claude";

  # Wrapper: waits for internet, then runs a recipe via claude (Pro subscription — no API key needed)
  runRecipe = pkgs.writeShellApplication {
    name = "investments-run-recipe";
    runtimeInputs = with pkgs; [ curl coreutils ];
    text = builtins.replaceStrings
      [ "@investmentsDir@" "@claudeBin@" ]
      [ investmentsDir claudeBin ]
      (builtins.readFile ./scripts/run-recipe.sh);
  };

  # Recipe definitions: name → { file, schedule }
  # schedule uses systemd OnCalendar format (man systemd.time)
  recipes = {
    "calendar-sync"  = { file = "passive_calendar_sync.md";  schedule = "*-*-01 09:00:00"; };
    "fii-health"     = { file = "passive_fii_health.md";     schedule = "*-*-10 09:00:00"; };
    "macro-watch"    = { file = "passive_macro_watch.md";    schedule = "*-*-12 09:00:00"; };
    "news-scan"      = { file = "passive_news_scan.md";      schedule = "*-*-28 09:00:00"; };
    "provider-audit" = { file = "passive_provider_audit.md"; schedule = "*-01,04,07,10-01 09:00:00"; };
    "banking-review" = { file = "passive_banking_review.md"; schedule = "*-01,04,07,10-01 09:00:00"; };
    "tr-sync"        = { file = "passive_tr_sync.md";        schedule = "Mon *-*-* 09:00:00"; };
  };

in {
  systemd.user.services = lib.mapAttrs'
    (name: cfg: lib.nameValuePair "investments-${name}" {
      Unit.Description = "Investments passive recipe: ${name}";
      Service = {
        Type = "oneshot";
        WorkingDirectory = investmentsDir;
        ExecStart = "${runRecipe}/bin/investments-run-recipe ${investmentsDir}/recipes/${cfg.file}";
      };
    })
    recipes;

  systemd.user.timers = lib.mapAttrs'
    (name: cfg: lib.nameValuePair "investments-${name}" {
      Unit.Description  = "Timer — investments passive recipe: ${name}";
      Timer = {
        OnCalendar = cfg.schedule;
        Persistent = true;   # re-fires on next login if PC was off at trigger time
      };
      Install.WantedBy = [ "timers.target" ];
    })
    recipes;
}
