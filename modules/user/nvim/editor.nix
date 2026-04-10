{ pkgs, ... }:

{
  programs.nixvim.plugins = {

    # Auto-close brackets, quotes, etc.
    nvim-autopairs = {
      enable = true;
      settings.check_ts = true; # use treesitter for smarter pairing
    };

    # Surround: add/change/delete surrounding chars (ys, cs, ds, S in visual)
    vim-surround.enable = true;

    # which-key: shows available keybindings in a popup after leader press
    which-key = {
      enable = true;
      settings = {
        delay = 500;
        icons.mappings = false;
        spec = [
          { __unkeyed-1 = "<leader>f"; group = "Find"; }
          { __unkeyed-1 = "<leader>h"; group = "Git hunks"; }
          { __unkeyed-1 = "<leader>l"; group = "LSP / lint"; }
          { __unkeyed-1 = "<leader>e"; group = "Explorer"; }
          { __unkeyed-1 = "<leader>s"; group = "Splits"; }
          { __unkeyed-1 = "<leader>t"; group = "Tabs / tmux"; }
          { __unkeyed-1 = "<leader>m"; group = "Format"; }
          { __unkeyed-1 = "<leader>b"; group = "Buffers"; }
          { __unkeyed-1 = "<leader>v"; group = "View / diagnostics"; }
          { __unkeyed-1 = "<leader>n"; group = "Nix / docs"; }
        ];
      };
    };

    # todo-comments: highlight and search TODO/FIXME/HACK/NOTE/PERF/WARN
    todo-comments = {
      enable = true;
      settings.signs = true;
    };
  };

  # substitute.nvim has no nixvim module — use extraPlugins
  programs.nixvim.extraPlugins = with pkgs.vimPlugins; [
    substitute-nvim   # s/S/ss motions that don't clobber the register
  ];

  programs.nixvim.extraConfigLua = ''
    -- substitute.nvim
    require("substitute").setup()
    vim.keymap.set("n", "s",  require("substitute").operator, { desc = "Substitute (motion)" })
    vim.keymap.set("n", "ss", require("substitute").line,     { desc = "Substitute line" })
    vim.keymap.set("n", "S",  require("substitute").eol,      { desc = "Substitute to EOL" })
    vim.keymap.set("x", "s",  require("substitute").visual,   { desc = "Substitute selection" })

    -- Maximize / restore current split (no plugin needed)
    local _maximized = false
    vim.keymap.set("n", "<leader>sm", function()
      if _maximized then
        vim.cmd("wincmd =")
        _maximized = false
      else
        vim.cmd("wincmd _")
        vim.cmd("wincmd |")
        _maximized = true
      end
    end, { desc = "Toggle maximize split" })
  '';

  programs.nixvim.keymaps = [
    # todo-comments navigation
    { mode = "n"; key = "]t"; action.__raw = ''function() require("todo-comments").jump_next() end''; options.desc = "Next TODO comment"; }
    { mode = "n"; key = "[t"; action.__raw = ''function() require("todo-comments").jump_prev() end''; options.desc = "Prev TODO comment"; }
    { mode = "n"; key = "<leader>ft"; action = "<cmd>TodoFzfLua<CR>"; options.desc = "Find TODOs"; }
  ];
}
