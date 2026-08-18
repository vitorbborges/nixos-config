{ pkgs, ... }:

{
  programs.nixvim.plugins.lint = {
    enable = true;
    lintersByFt = {
      python   = [ "ruff" ];
      yaml     = [ "yamllint" ];
      markdown = [ "markdownlint" ];
      c        = [ "cpplint" ];
      cpp      = [ "cpplint" ];
    };
  };

  programs.nixvim.autoCmd = [
    {
      event = [ "BufEnter" "BufWritePost" "InsertLeave" ];
      callback.__raw = builtins.readFile ./lua/lint-autotrigger.lua;
      desc = "Run linter on buffer events";
    }
  ];

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>l";
      action.__raw = "function() require('lint').try_lint() end";
      options.desc = "Trigger linting for current file";
    }
    {
      mode = "n";
      key = "<leader>vw";
      action.__raw = builtins.readFile ./lua/lint-toggle.lua;
      options.desc = "Toggle inline diagnostics";
    }
  ];

  # Linters injected into nvim's PATH via extraPackages
  programs.nixvim.extraPackages = with pkgs; [
    python3Packages.ruff
    yamllint
    markdownlint-cli
    cpplint
  ];
}
