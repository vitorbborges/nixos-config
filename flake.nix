{

  description = "Flake of VitorBandeiraBorges";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          # TODO: Change hostname
          inherit system;
          modules = [ ./configuration.nix ./modules/system ];
          specialArgs = { inherit inputs; };
        };
      };
      homeConfigurations = {
        vitorbborges = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = { inherit inputs system; };
        };
      };
    };

}
