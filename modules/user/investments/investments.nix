{ pkgs, lib, ... }:

let
  investmentsDir = "/home/vitor/Investments";
  claudeBin      = "/etc/profiles/per-user/vitor/bin/claude";

  # Wrapper: waits for internet, then runs a recipe via claude (Pro subscription — no API key needed)
  runRecipe = pkgs.writeShellScript "investments-run-recipe" ''
    set -euo pipefail
    RECIPE="$1"

    # Wait for internet — 30 × 10 s = 5 minutes max
    for i in $(seq 1 30); do
      if ${pkgs.curl}/bin/curl -sf --max-time 3 https://1.1.1.1 >/dev/null 2>&1; then
        break
      fi
      if [ "$i" -eq 30 ]; then
        echo "investments-recipe: no internet after 5 minutes, skipping $RECIPE" >&2
        exit 1
      fi
      sleep 10
    done

    cd "${investmentsDir}"
    ${claudeBin} --dangerously-skip-permissions < "$RECIPE"
  '';

  # Recipe definitions: name → { file, schedule }
  # schedule uses systemd OnCalendar format (man systemd.time)
  recipes = {
    "calendar-sync"  = { file = "passive_calendar_sync.md";  schedule = "*-*-01 09:00:00"; };
    "fii-health"     = { file = "passive_fii_health.md";     schedule = "*-*-10 09:00:00"; };
    "macro-watch"    = { file = "passive_macro_watch.md";    schedule = "*-*-12 09:00:00"; };
    "news-scan"      = { file = "passive_news_scan.md";      schedule = "*-*-28 09:00:00"; };
    "provider-audit" = { file = "passive_provider_audit.md"; schedule = "*-01,04,07,10-01 09:00:00"; };
    "banking-review" = { file = "passive_banking_review.md"; schedule = "*-01,04,07,10-01 09:00:00"; };
  };

in {
  systemd.user.services = lib.mapAttrs'
    (name: cfg: lib.nameValuePair "investments-${name}" {
      Unit.Description = "Investments passive recipe: ${name}";
      Service = {
        Type = "oneshot";
        WorkingDirectory = investmentsDir;
        ExecStart = "${runRecipe} ${investmentsDir}/recipes/${cfg.file}";
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
