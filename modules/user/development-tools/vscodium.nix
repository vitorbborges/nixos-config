{ config, lib, pkgs, ... }:
let
  cfg = config.userSettings.vscodium;

  pdf-viewer = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "preview-pdf";
    publisher = "analytic-signal";
    version = "1.0.0";
    hash = "sha256-m8Y9gySPEg9aAMYNm2+4+j1ywg+w8Tq7PaqXNiaLuH0=";
  };

  better-markdown-preview = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "better-markdown-preview";
    publisher = "jimeh";
    version = "1.3.0";
    hash = "sha256-Sv1pAGo2MaSrTNJYBJARpstzI8DHG62JlBGmm3LUFFs=";
  };

  table-viewer = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "table-viewer";
    publisher = "jbearak";
    # engine ^1.127.0 starts at 0.8.0; 0.7.0 is the latest compatible with
    # our vscodium (1.126). Bump once we're on 1.127+.
    version = "0.7.0";
    hash = "sha256-b7idE/83uLP/oIadKzXaS91lLSjPisxp2fqZ1ibmKok=";
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
      package = pkgs.vscodium;
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
          better-markdown-preview
          table-viewer
      ];
      profiles.default.userSettings = {
        "keyboard.dispatch" = "keyCode";
        # Custom editors (table-viewer for xlsx/csv) are extensions, so they
        # stay disabled while a window is in Restricted Mode. Files are opened
        # from yazi as untrusted workspaces, so trust must be off system-wide.
        "security.workspace.trust.enabled" = false;
        # On cold start (yazi opens `codium file.xlsx` with no instance
        # running), VS Code races extension activation and the extension's
        # own priority:"default" registration loses — the file falls back to
        # the binary text editor. An explicit association resolves reliably.
        "workbench.editorAssociations" = {
          "*.xlsx" = "tableViewer.excelViewer";
          "*.XLSX" = "tableViewer.excelViewer";
          "*.xls" = "tableViewer.excelViewer";
          "*.XLS" = "tableViewer.excelViewer";
        };
        # VS Code tried to write this default into settings.json on startup.
        # settings.json is a read-only nix symlink, so the write failed and
        # left a dirty buffer that hot-exit restored as an unsaved tab on
        # every launch. Pre-setting it here makes VS Code skip the write.
        "chat.disableAIFeatures" = false;
      };
      mutableExtensionsDir = false;

    };
    };
}
