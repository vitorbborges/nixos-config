{ config, lib, pkgs, ... }:
let
  cfg = config.userSettings.vscodium;
in {
  options = {
    userSettings.vscodium = {
      enable = lib.mkEnableOption "Enable vscodium";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true; # Required for some extensions like Data Wrangler

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default.extensions = with pkgs.vscode-extensions; [
          ms-toolsai-datawrangler
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
