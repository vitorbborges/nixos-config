{ pkgs, ... }:

{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        json     = [ "prettier" ];
        yaml     = [ "prettier" ];
        markdown = [ "prettier" ];
        lua      = [ "stylua" ];
        python   = [ "ruff_organize_imports" "ruff_format" ];
        nix      = [ "alejandra" ];
        sql      = [ "sql_formatter" ];
        rust     = [ "rustfmt" ];
        c        = [ "clang_format" ];
        cpp      = [ "clang_format" ];
      };

      format_on_save = {
        lsp_fallback = true;
        async = false;
        timeout_ms = 1000;
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = [ "n" "v" ];
      key = "<leader>mp";
      action.__raw = ''
        function()
          require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
        end
      '';
      options.desc = "Format file or selection";
    }
  ];

  # Formatters injected into nvim's PATH via extraPackages (not system-wide home.packages)
  programs.nixvim.extraPackages = with pkgs; [
    stylua
    prettier
    python3Packages.ruff
    alejandra
    sql-formatter
    rustfmt
    clang-tools  # provides clang-format
  ];
}
