{ pkgs, ... }:

{
  services.activitywatch = {
    enable = true;
    package = pkgs.aw-server-rust;
    watchers = {
      awatcher = {
        package = pkgs.awatcher;
        settings = {
          "idle-timeout-seconds" = 180;
          "poll-time-idle-seconds" = 4;
          "poll-time-window-seconds" = 1;

          filters = [
            # ==============================================================================
            # Work
            # ==============================================================================
            {
              match-app-id = "kitty";
              replace-app-id = "Work";
            }
            {
              match-app-id = "org.gnome.Nautilus";
              replace-app-id = "Work";
            }
            {
              match-app-id = "vscodium";
              replace-app-id = "Work";
            }
            {
              match-app-id = "zen";
              match-title = ".*(Overleaf|LinkedIn|GitLab|DeepSeek|Qwen Chat|Google Docs|Inria|GitHub|Hugging Face|Jupyter|VSCode|VSCodium).*";
              replace-app-id = "Work";
            }
            {
              match-app-id = "zen";
              match-title = ".*(dev|SDA|profiling|Stack Overflow|kernel|node|python|rust|cargo).*";
              replace-app-id = "Work";
            }
            {
              match-app-id = "thunderbird_thunderbird";
              replace-app-id = "Work";
            }

            # ==============================================================================
            # System Configuration
            # ==============================================================================
            {
              match-app-id = "zen";
              match-title = ".*(nix|nixos|home-manager).*";
              replace-app-id = "System Configuration";
            }
            {
              match-app-id = "Timeshift-gtk";
              replace-app-id = "System Configuration";
            }
            {
              match-app-id = "GParted";
              replace-app-id = "System Configuration";
            }

            # ==============================================================================
            # Study
            # ==============================================================================
            {
              match-app-id = "zen";
              match-title = ".*(WeBeep|Polimi|Politecnico|course|lecture|lesson|tutorial|paper|arxiv|ieee|acm).*";
              replace-app-id = "Study";
            }
            {
              match-app-id = "org.pwmt.zathura";
              replace-app-id = "Study";
            }
            {
              match-app-id = "zen";
              match-title = ".*(Signal Processing|Computational Statistics|Networked Software|Distributed Systems).*";
              replace-app-id = "Study";
            }

            # ==============================================================================
            # Leisure
            # ==============================================================================
            {
              match-app-id = "zen";
              match-title = ".*(YouTube|WhatsApp|Facebook|Instagram|Twitter|Reddit).*";
              replace-app-id = "Leisure";
            }
            {
              match-app-id = "Spotify";
              replace-app-id = "Leisure";
            }
          ];
        };
      };
    };
  };

  home.packages = [
    (pkgs.writeShellScriptBin "update-aw-filters" (builtins.readFile ./update-filters.sh))
  ];
}