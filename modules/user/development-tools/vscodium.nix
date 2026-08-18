{ config, lib, pkgs, pkgs-stable, ... }:
let
  cfg = config.userSettings.vscodium;

  pdf-viewer = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "preview-pdf";
    publisher = "analytic-signal";
    version = "1.0.0";
    hash = "sha256-m8Y9gySPEg9aAMYNm2+4+j1ywg+w8Tq7PaqXNiaLuH0=";
  };
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

    programs.vscodium = {
      enable = true;
      package = pkgs-stable.vscodium;
      profiles.default.extensions = with pkgs.vscode-extensions; [
          ms-toolsai.datawrangler
          github.copilot-chat
          ms-toolsai.jupyter
          ms-python.python
          ms-python.vscode-pylance
          charliermarsh.ruff
          pkief.material-icon-theme
          gruntfuggly.todo-tree
          redhat.vscode-yaml
          pdf-viewer
      ];
      profiles.default.userSettings = {
        "keyboard.dispatch" = "keyCode";
      };
      mutableExtensionsDir = false;

    };
    };
}
