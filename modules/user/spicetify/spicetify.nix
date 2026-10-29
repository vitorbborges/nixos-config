{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.packages = [ pkgs.spicetify-cli ];

  home.activation.spotifyUiZoom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for prefs in "$HOME"/.config/spotify/Users/*/prefs; do
      [ -f "$prefs" ] || continue
      ${pkgs.gnused}/bin/sed -i 's/^app\.browser\.zoom-level=.*/app.browser.zoom-level=-50/' "$prefs"
      grep -q '^app\.browser\.zoom-level=' "$prefs" || printf '%s\n' 'app.browser.zoom-level=-50' >> "$prefs"
    done
  '';

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.comfy;

      enabledCustomApps = with spicePkgs.apps; [
        marketplace
        # WaveLink 3.0.71 plus software AAC fallback (upstream issue #3), vendored as built.
        ({
          src = ./wavelink;
          name = "wavelink";
        })
      ];

      enabledExtensions = with spicePkgs.extensions; [
        shuffle
        keyboardShortcut
        powerBar
        playlistIcons
        fullAlbumDate
        skipStats
        writeify
        songStats
        autoVolume
        showQueueDuration
        history
        adblock
        playNext
        volumePercentage
        coverAmbience
        simpleBeautifulLyrics
        allOfArtist
        ({
          # The source of the custom extension
          src = pkgs.fetchFromGitHub {
            owner = "abh80";
            repo = "Spicetify-Fullscreen-Canvas";
            rev = "30a0139";
            hash = "sha256-mKEuyWBr+KGuyDvfqQpU8y0l5B5LTmZPN/DTaW4hQZQ="; # Will be prompted by nix
          };
          # The actual file name of the custom extension
          name = "spotifyFullscreenCanvas.js";
        })
      ];
    };
}
