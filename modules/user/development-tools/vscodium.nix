{ config, lib, pkgs, pkgs-stable, ... }:
let
  cfg = config.userSettings.vscodium;
in {
  options = {
    userSettings.vscodium = {
      enable = lib.mkEnableOption "Enable vscodium";
    };
  };

  config = {
    # Enable VSCodium by default
    userSettings.vscodium.enable = lib.mkDefault true;
    # nixpkgs.allowUnfree inherited from system pkgs via useGlobalPkgs = true

    programs.vscode = {
      enable = true;
      package = pkgs-stable.vscodium;
      profiles.default.extensions = with pkgs.vscode-extensions; [
          ms-toolsai.datawrangler
          github.copilot-chat
          ms-toolsai.jupyter
          ms-python.python
          pkief.material-icon-theme
          gruntfuggly.todo-tree
          redhat.vscode-yaml
      ];
      profiles.default.userSettings = {
        "keyboard.dispatch" = "keyCode";
      };
      mutableExtensionsDir = false;

    };
    };
}
