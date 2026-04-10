{ pkgs, ... }:

{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "<C-space>";
            node_incremental = "<C-space>";
            scope_incremental = false;
            node_decremental = "<bs>";
          };
        };
      };
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash bibtex c cpp csv gitignore html json julia lua
        markdown markdown_inline matlab python query r rust
        toml vim vimdoc xml yaml nix
      ];
    };

    treesitter-textobjects = {
      enable = true;
      settings = {
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "aa" = { query = "@parameter.outer"; queryGroup = "textobjects"; desc = "outer parameter"; };
            "ia" = { query = "@parameter.inner"; queryGroup = "textobjects"; desc = "inner parameter"; };
            "af" = { query = "@function.outer";  queryGroup = "textobjects"; desc = "outer function"; };
            "if" = { query = "@function.inner";  queryGroup = "textobjects"; desc = "inner function"; };
            "ac" = { query = "@class.outer";     queryGroup = "textobjects"; desc = "outer class"; };
            "ic" = { query = "@class.inner";     queryGroup = "textobjects"; desc = "inner class"; };
          };
        };
        move = {
          enable = true;
          goto_next_start = {
            "]m" = { query = "@function.outer"; queryGroup = "textobjects"; desc = "Next function start"; };
            "]]" = { query = "@class.outer";    queryGroup = "textobjects"; desc = "Next class start"; };
          };
          goto_next_end = {
            "]M" = { query = "@function.outer"; queryGroup = "textobjects"; desc = "Next function end"; };
            "][" = { query = "@class.outer";    queryGroup = "textobjects"; desc = "Next class end"; };
          };
          goto_previous_start = {
            "[m" = { query = "@function.outer"; queryGroup = "textobjects"; desc = "Prev function start"; };
            "[[" = { query = "@class.outer";    queryGroup = "textobjects"; desc = "Prev class start"; };
          };
          goto_previous_end = {
            "[M" = { query = "@function.outer"; queryGroup = "textobjects"; desc = "Prev function end"; };
            "[]" = { query = "@class.outer";    queryGroup = "textobjects"; desc = "Prev class end"; };
          };
        };
        swap = {
          enable = true;
          swap_next."<leader>na"   = { query = "@parameter.inner"; queryGroup = "textobjects"; desc = "Swap next parameter"; };
          swap_previous."<leader>pa" = { query = "@parameter.inner"; queryGroup = "textobjects"; desc = "Swap prev parameter"; };
        };
      };
    };

    ts-autotag.enable = true;
  };
}
