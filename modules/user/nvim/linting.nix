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
      callback.__raw = ''
        function()
          require("lint").try_lint()
        end
      '';
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
      action.__raw = ''
        function()
          local config = vim.diagnostic.config()
          if config.virtual_text then
            vim.diagnostic.config({ virtual_text = false, underline = false })
            vim.notify("Inline diagnostics hidden")
          else
            vim.diagnostic.config({
              virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
              underline = true,
            })
            vim.notify("Inline diagnostics shown")
          end
        end
      '';
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
