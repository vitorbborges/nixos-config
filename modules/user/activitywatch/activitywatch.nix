{ pkgs, ... }:

let
  awatcher = pkgs.rustPlatform.buildRustPackage {
    pname = "awatcher";
    version = "0.3.3";

    src = pkgs.fetchFromGitHub {
      owner = "2e3s";
      repo = "awatcher";
      rev = "678d7fd0867462f7925c1e4771994bba5f3da0c7";
      sha256 = "01gnc9vym2wcb9y5afhqix0p9cvdjdqqnhig823zqzwajvsdn11d";
    };

    cargoHash = "sha256-/dI0gaTRElAQnZNRo2sKMUc33fphubcG/fXOflPHXWs=";

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = with pkgs; [ openssl dbus libxkbcommon wayland libGL ];

    meta = {
      description = "Window activity and idle watcher for ActivityWatch";
      homepage = "https://github.com/2e3s/awatcher";
      license = pkgs.lib.licenses.mpl20;
      platforms = pkgs.lib.platforms.linux;
    };
  };
in

{
  services.activitywatch = {
    enable = true;
    package = pkgs.aw-server-rust;
    watchers = {
      awatcher = {
        package = awatcher;
        settings = {
          "idle-timeout-seconds" = 180;
          "poll-time-idle-seconds" = 4;
          "poll-time-window-seconds" = 1;

          filters = [
            # ==============================================================================
            # Work
            # ==============================================================================

            {
              match-app-id = "zen";
              match-title = ".*(dev|SDA|profiling|Stack Overflow|kernel|node|python|rust|cargo).*";
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
            # Media
            # ==============================================================================
            {
              match-app-id = "zen";
              match-title = ".*(YouTube|Plex|VLC).*";
              replace-app-id = "Media";
            }

            # ==============================================================================
            # Comm
            # ==============================================================================
            {
              match-app-id = "zen";
              match-title = ".*(Messenger|Telegram|Signal|WhatsApp|Rambox|Slack|Riot|Element|Discord|Nheko|NeoChat|Mattermost|Gmail|Thunderbird|mutt|alpine).*";
              replace-app-id = "Comm";
            }
            {
              match-app-id = "thunderbird_thunderbird";
              replace-app-id = "Comm";
            }

            # ==============================================================================
            # Leisure
            # ==============================================================================
            {
              match-app-id = "zen";
              match-title = ".*(Facebook|Instagram|Twitter|Reddit).*";
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