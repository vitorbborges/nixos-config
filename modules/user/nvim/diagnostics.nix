{ ... }:

{
  # trouble.nvim: structured panel for diagnostics, quickfix, loclist, and todos
  programs.nixvim.plugins.trouble = {
    enable = true;
    settings.focus = true; # auto-focus the trouble window when opened
  };

  programs.nixvim.keymaps = [
    { mode = "n"; key = "<leader>xw"; action = "<cmd>Trouble diagnostics toggle<CR>";              options.desc = "Workspace diagnostics (Trouble)"; }
    { mode = "n"; key = "<leader>xd"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>"; options.desc = "Document diagnostics (Trouble)"; }
    { mode = "n"; key = "<leader>xq"; action = "<cmd>Trouble quickfix toggle<CR>";                 options.desc = "Quickfix list (Trouble)"; }
    { mode = "n"; key = "<leader>xl"; action = "<cmd>Trouble loclist toggle<CR>";                  options.desc = "Location list (Trouble)"; }
    { mode = "n"; key = "<leader>xt"; action = "<cmd>Trouble todo toggle<CR>";                     options.desc = "TODOs (Trouble)"; }
  ];
}
