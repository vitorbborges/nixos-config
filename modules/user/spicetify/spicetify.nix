{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.packages = [ pkgs.spicetify-cli ];

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.ziro;
      colorScheme = "blue-dark";

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
        betterGenres
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
