{ ... }:

{
  programs.nixvim.plugins = {

    # blink-cmp: Rust-based completion engine, ~6x faster than nvim-cmp
    # Replaces: nvim-cmp + cmp-buffer + cmp-path + cmp_luasnip + lspkind
    blink-cmp = {
      enable = true;
      settings = {
        appearance = {
          use_nvim_cmp_as_default = false;
          nerd_font_variant = "mono";
        };

        completion = {
          accept.auto_brackets.enabled = true;
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          menu.draw.treesitter = [ "lsp" ];
        };

        sources.default = [ "lsp" "path" "snippets" "buffer" ];

        keymap = {
          preset = "none";
          "<C-k>"     = [ "select_prev" "fallback" ];
          "<C-j>"     = [ "select_next" "fallback" ];
          "<C-b>"     = [ "scroll_documentation_up" "fallback" ];
          "<C-f>"     = [ "scroll_documentation_down" "fallback" ];
          "<C-Space>" = [ "show" "show_documentation" "hide_documentation" ];
          "<C-e>"     = [ "hide" ];
          "<CR>"      = [ "accept" "fallback" ];
          "<Tab>"     = [ "snippet_forward" "fallback" ];
          "<S-Tab>"   = [ "snippet_backward" "fallback" ];
        };

        snippets.preset = "luasnip";

        signature.enabled = true;
      };
    };

    # Snippet engine
    luasnip = {
      enable = true;
      settings.history = true;
    };

    friendly-snippets.enable = true;
  };
}
