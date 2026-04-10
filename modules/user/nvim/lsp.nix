{ ... }:

{
  programs.nixvim.plugins = {

    # lazydev: Lua LSP completions for nvim APIs (replaces archived neodev.nvim)
    lazydev = {
      enable = true;
      settings.library = [
        { path = "\${3rd}/luv/library"; words = [ "vim%.uv" ]; }
      ];
    };

    lsp = {
      enable = true;

      # Keymaps applied on every LspAttach
      keymaps = {
        silent = true;

        lspBuf = {
          "gD"          = { action = "declaration";     desc = "Go to declaration"; };
          "gd"          = { action = "definition";      desc = "Go to definition"; };
          "gi"          = { action = "implementation";  desc = "Go to implementation"; };
          "gt"          = { action = "type_definition"; desc = "Go to type definition"; };
          "gR"          = { action = "references";      desc = "Show references"; };
          "K"           = { action = "hover";           desc = "Show docs"; };
          "<leader>ca"  = { action = "code_action";     desc = "Code action"; };
          "<leader>rn"  = { action = "rename";          desc = "Smart rename"; };
          "<leader>rs"  = { action = "restart"; desc = "Restart LSP"; };
        };

        diagnostic = {
          "<leader>d"  = { action = "open_float"; desc = "Show line diagnostics"; };
          "[d"         = { action = "goto_prev";  desc = "Prev diagnostic"; };
          "]d"         = { action = "goto_next";  desc = "Next diagnostic"; };
        };
      };

      servers = {
        lua_ls = {
          enable = true;
          settings.Lua = {
            diagnostics.globals = [ "vim" ];
            completion.callSnippet = "Replace";
          };
        };

        pyright.enable = true;

        clangd.enable = true;

        # Nix LSP — nixd is more capable than nil, actively maintained
        nixd.enable = true;
      };
    };
  };

  # Diagnostic display: signs in gutter, no inline virtual text (clean look)
  # Toggle with <leader>vw (wired in linting.nix)
  programs.nixvim.diagnostics = {
    virtual_text = false;
    signs = true;
    underline = false;
    float.source = true;
  };
}
