{

  description = "Flake of VitorBandeiraBorges";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      font = "JetBrains Mono Nerd Font";
      fontPkg = "JetBrainsMono";
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          # TODO: Change hostname
          inherit system;
          modules = [ ./configuration.nix ./modules/system ];
          specialArgs = { inherit inputs font fontPkg; };
        };
      };
      homeConfigurations = {
        vitorbborges = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = { inherit inputs system font fontPkg; };
        };
      };
    };

}
