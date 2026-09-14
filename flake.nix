{

  description = "Flake of VitorBandeiraBorges";

  nixConfig = { };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:herdrdev/herdr/v0.8.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-stable.url = "nixpkgs/nixos-25.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Agent-skill sources: vendored into ~/.claude/skills by
    # modules/user/agents/skills.nix and into ~/.config/opencode/AGENTS.md by
    # modules/user/agents/instructions.nix. flake = false — pure source trees,
    # no output schema; bump with `nix flake update`.
    ponytail = { url = "github:DietrichGebert/ponytail"; flake = false; };
    superpowers = { url = "github:obra/superpowers"; flake = false; };
    i-have-adhd = { url = "github:ayghri/i-have-adhd"; flake = false; };
    humanizer = { url = "github:blader/humanizer"; flake = false; };

  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "electron-38.8.4" ];
      };
      # waybar 0.15.0 predates Hyprland 0.56's IPC rename of workspace "id" →
      # "address", which broke deduplication in hyprland/workspaces (persistent
      # workspaces rendered twice). Backport the address fallback until upstream
      # waybar ships a fixed release.
      waybarHyprland056Fix = final: prev: {
        waybar = prev.waybar.overrideAttrs (old: {
          patches = (old.patches or []) ++ [ ./patches/waybar-hyprland-0.56-address.patch ];
        });
      };

      # Silence xorg.* deprecation warnings emitted by upstream packages that
      # haven't migrated to the new top-level names yet (e.g. nvidia-vaapi-driver).
      # Maps the warned aliases directly to the canonical top-level derivations.
      suppressXorgWarnings = final: prev: {
        xorg = prev.xorg // {
          libICE        = prev.libice;
          libSM         = prev.libsm;
          libX11        = prev.libx11;
          libxcb        = prev.libxcb;
          libXcomposite = prev.libxcomposite;
          libXcursor    = prev.libxcursor;
          libXdamage    = prev.libxdamage;
          libXext       = prev.libxext;
          libXfixes     = prev.libxfixes;
          libXft        = prev.libxft;
          libXi         = prev.libxi;
          libXinerama   = prev.libxinerama;
          libXrandr     = prev.libxrandr;
          libXrender    = prev.libxrender;
          libXt         = prev.libxt;
          libXtst       = prev.libxtst;
          libXxf86vm    = prev.libxxf86vm;
        };
      };

      # Desktop pkgs: allowUnfree + nix-matlab overlay applied at instantiation
      # so home-manager (useGlobalPkgs) never sees nixpkgs.overlays in module eval.
      pkgs-desktop = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "electron-38.8.4" ];
        overlays = [ suppressXorgWarnings inputs.nix-matlab.overlay waybarHyprland056Fix ];
      };
      username = "vitor";
      kbLayout = "us";
      font = "JetBrains Mono Nerd Font";
      theme = "catppuccin-mocha"; # base16 scheme from pkgs.base16-schemes — change here to retheme everything
    in
    {
      nixosConfigurations = {
        desktop = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { nixpkgs.pkgs = pkgs-desktop; }
            ./hosts/desktop/configuration.nix
            ./modules/system
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = { inherit inputs system username kbLayout font pkgs-stable theme; };
              home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
              home-manager.users.${username} = import ./hosts/desktop/home.nix;
            }
          ];
          specialArgs = { inherit inputs username kbLayout pkgs-stable theme; };
        };

        oci-vps = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/oci-vps/default.nix
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs username; };
              home-manager.users.${username} = import ./hosts/oci-vps/home.nix;
            }
          ];
          specialArgs = { inherit inputs username; };
        };
      };
    };

}
