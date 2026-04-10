{ ... }:

{
  programs.nixvim.plugins.fzf-lua = {
    enable = true;
    settings = {
      winopts = {
        height = 0.85;
        width = 0.80;
        preview.layout = "vertical";
      };
    };
  };

  programs.nixvim.keymaps = [
    # File pickers
    { mode = "n"; key = "<leader>ff"; action = "<cmd>FzfLua files<CR>";            options.desc = "Find files"; }
    { mode = "n"; key = "<leader>fr"; action = "<cmd>FzfLua oldfiles<CR>";         options.desc = "Find recent files"; }
    { mode = "n"; key = "<leader>fs"; action = "<cmd>FzfLua live_grep<CR>";        options.desc = "Grep in project"; }
    { mode = "n"; key = "<leader>fc"; action = "<cmd>FzfLua grep_cword<CR>";       options.desc = "Grep word under cursor"; }
    { mode = "n"; key = "<leader>fb"; action = "<cmd>FzfLua buffers<CR>";          options.desc = "Find open buffers"; }
    { mode = "n"; key = "<leader>fh"; action = "<cmd>FzfLua help_tags<CR>";        options.desc = "Search help tags"; }
    { mode = "n"; key = "<leader>fd"; action = "<cmd>FzfLua diagnostics_document<CR>"; options.desc = "Document diagnostics"; }
    { mode = "n"; key = "<leader>fD"; action = "<cmd>FzfLua diagnostics_workspace<CR>"; options.desc = "Workspace diagnostics"; }

    # LSP pickers (upgrade from plain vim.lsp.buf in lsp.nix)
    { mode = "n"; key = "gR"; action = "<cmd>FzfLua lsp_references<CR>";         options.desc = "LSP references"; }
    { mode = "n"; key = "gd"; action = "<cmd>FzfLua lsp_definitions<CR>";        options.desc = "LSP definitions"; }
    { mode = "n"; key = "gi"; action = "<cmd>FzfLua lsp_implementations<CR>";    options.desc = "LSP implementations"; }
    { mode = "n"; key = "gt"; action = "<cmd>FzfLua lsp_typedefs<CR>";           options.desc = "LSP type definitions"; }
    { mode = "n"; key = "<leader>D"; action = "<cmd>FzfLua lsp_document_diagnostics<CR>"; options.desc = "Buffer diagnostics"; }
  ];
}
