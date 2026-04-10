{ ... }:

{
  # oil.nvim: filesystem as an editable buffer — more vim-native than nvim-tree
  # Navigate with hjkl, edit filenames like text, save to apply changes
  programs.nixvim.plugins.oil = {
    enable = true;
    settings = {
      default_file_explorer = true;
      delete_to_trash = true;
      skip_confirm_for_simple_edits = true;
      view_options = {
        show_hidden = true;
        natural_order = true;
      };
      float = {
        padding = 2;
        max_width = 90;
        max_height = 0;
      };
      keymaps = {
        "g?"   = "actions.show_help";
        "<CR>" = "actions.select";
        "p"    = "actions.preview";
        "<C-r>"= "actions.refresh";
        "-"    = "actions.parent";
        "_"    = "actions.open_cwd";
        "gs"   = "actions.change_sort";
        "gx"   = "actions.open_external";
        "g."   = "actions.toggle_hidden";
        "q"    = "actions.close";
        "v"    = { callback = "actions.select"; opts.vertical = true;   desc = "Open in vertical split"; };
        "s"    = { callback = "actions.select"; opts.horizontal = true; desc = "Open in horizontal split"; };
        "t"    = { callback = "actions.select"; opts.tab = true;        desc = "Open in new tab"; };
      };
    };
  };

  programs.nixvim.keymaps = [
    { mode = "n"; key = "<leader>ee"; action = "<cmd>Oil<CR>";       options.desc = "Open explorer (current dir)"; }
    { mode = "n"; key = "<leader>ef"; action = "<cmd>Oil --float<CR>"; options.desc = "Open explorer (float)"; }
    { mode = "n"; key = "<leader>er"; action.__raw = ''function() require("oil").open(vim.fn.getcwd()) end''; options.desc = "Open explorer (cwd)"; }
    { mode = "n"; key = "-";          action = "<cmd>Oil<CR>";       options.desc = "Open parent directory"; }
  ];
}
