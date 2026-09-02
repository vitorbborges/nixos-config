# Investments passive-recipe REMINDERS — notify-send, not execution.
#
# Each timer fires a notify-send telling the user which recipe to run today.
# Recipes are run manually (claude < recipes/foo.md) — claude's session tokens
# can't refresh non-interactively, and this avoids wifi/wake races entirely.
#
# Failure contract: the service NEVER exits non-zero and NEVER writes to
# journal/stderr. If connectivity can't be verified, it exits 0 silently —
# zero systemd failure states, zero login-screen pollution.
{ pkgs, lib, ... }:

let
  investmentsDir = "/home/vitor/Projects/Investments";

  # Reminder script: strict NM connectivity check → notify-send. See
  # ./scripts/remind-recipe.sh for the full contract.
  remindRecipe = pkgs.writeShellScript "investments-remind-recipe" (
    builtins.replaceStrings
      [ "@nmcli@" "@notifySend@" "@investmentsDir@" ]
      [
        "${pkgs.networkmanager}/bin/nmcli"
        "${pkgs.libnotify}/bin/notify-send"
        investmentsDir
      ]
      (builtins.readFile ./scripts/remind-recipe.sh)
  );

  # Recipe definitions: name → { file, schedule, label, hint }
  # schedule uses systemd OnCalendar format (man systemd.time)
  # label + hint are shown in the notification; hint is optional ("")
  recipes = {
    "calendar-sync" = {
      file     = "passive_calendar_sync.md";
      schedule = "*-*-01 09:00:00";
      label    = "Financial Calendar Sync";
      hint     = "Syncs Google Calendar with official financial event dates (COPOM, dividends, maturities).";
    };
    "fii-health" = {
      file     = "passive_fii_health.md";
      schedule = "*-*-10 09:00:00";
      label    = "FII Health Check";
      hint     = "Monthly FII fundamentals check (evaluate_fiis.py + web). Flags only if a position breaks its thesis.";
    };
    "macro-watch" = {
      file     = "passive_macro_watch.md";
      schedule = "*-*-12 09:00:00";
      label    = "Macro Watch";
      hint     = "IPCA/SELIC check vs expectations. Flags only on a Tier 1 indicator that persists.";
    };
    "news-scan" = {
      file     = "passive_news_scan.md";
      schedule = "*-*-28 09:00:00";
      label    = "News Scan";
      hint     = "Thesis-relevant news for held positions. Flags only material items.";
    };
    "provider-audit" = {
      file     = "passive_provider_audit.md";
      schedule = "*-01,04,07,10-01 09:00:00";
      label    = "Provider Audit";
      hint     = "Quarterly broker/fee competitive audit. Flags only if switching saves real money.";
    };
    "banking-review" = {
      file     = "passive_banking_review.md";
      schedule = "*-01,04,07,10-01 09:00:00";
      label    = "Banking & Cards Review";
      hint     = "Quarterly banking/card fee optimization. Flags only actionable savings.";
    };
    "tr-sync" = {
      file     = "passive_tr_sync.md";
      schedule = "Mon *-*-* 09:00:00";
      label    = "Trade Republic Sync";
      hint     = "Weekly TR balance sync via fetch_tr_portfolio.py. pytr sessions expire — if login fails, run: pytr login (code arrives in the TR app).";
    };
  };

in {
  systemd.user.services = lib.mapAttrs'
    (name: cfg: lib.nameValuePair "investments-${name}" {
      Unit.Description = "Investments passive recipe reminder: ${name}";
      Service = {
        Type = "oneshot";
        ExecStart = "${remindRecipe} ${lib.escapeShellArg cfg.file} ${lib.escapeShellArg cfg.label} ${lib.escapeShellArg cfg.hint}";
        # Absolute silence: never emit journal output, never fail.
        StandardOutput = "null";
        StandardError  = "null";
      };
    })
    recipes;

  systemd.user.timers = lib.mapAttrs'
    (name: cfg: lib.nameValuePair "investments-${name}" {
      Unit.Description = "Timer — investments passive recipe reminder: ${name}";
      Timer = {
        OnCalendar = cfg.schedule;
        Persistent = true;   # re-fires on next login if PC was off at trigger time
      };
      Install.WantedBy = [ "timers.target" ];
    })
    recipes;
}
