{ inputs, username, ... }:

{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      keep-outputs = true;       # keep build inputs for nix develop / nix-direnv
      keep-derivations = true;   # keep .drv files for nix develop
      trusted-users = [ "root" "@wheel" ];  # required by devenv to add substituters

      # Limit parallel builds so the system stays usable during rebuilds.
      # i9-13980HX has 24 cores: 8 derivations × 4 cores each = 32 threads max,
      # leaving headroom for the rest of the system.
      max-jobs = 8;
      cores = 4;
      extra-substituters = [ "https://devenv.cachix.org" ];
      extra-trusted-public-keys = [ "devenv.cachix.org-1:mIBmOfqxIVx3U12oA9a6RpkFkRyoMNy76enCl0LmWEg=" ];
    };

    # Pin registry + nixPath to flake's locked nixpkgs so that
    # `nix-shell -p foo`, `nix repl '<nixpkgs>'`, and `nix run nixpkgs#...`
    # all resolve against the same store path as the running system.
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];

    optimise.automatic = true;
    optimise.dates = [ "daily" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
  };

  # Auto-upgrade rebuilds from the current lock file.
  # To update inputs, run `nix flake update` manually then rebuild,
  # or use `nh os switch --update` once nh supports it.
  # (The old --update-input flags were deprecated and removed from Nix.)
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    flake = "/home/${username}/nixos-config";
    flags = [ "--commit-lock-file" ];
    dates = "weekly";  # daily rebuilds without input updates waste time
  };
}
