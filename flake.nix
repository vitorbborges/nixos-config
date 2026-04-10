{

  description = "Flake of VitorBandeiraBorges";

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

    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      username = "vitor";
      kbLayout = "us";
      font = "JetBrains Mono Nerd Font";
      theme = "catppuccin-mocha"; # base16 scheme from pkgs.base16-schemes — change here to retheme everything
    in
    {
      nixosConfigurations = {
        vivobook = lib.nixosSystem {
          inherit system;
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            ./configuration.nix
            ./modules/system
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs system username kbLayout font pkgs-stable theme; };
              home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
              home-manager.users.${username} = import ./home.nix;
            }
          ];
          specialArgs = { inherit inputs username kbLayout pkgs-stable theme; };
        };
      };
    };

}
