{ ... }:

{
  programs.nixvim.plugins = {

    gitsigns = {
      enable = true;
      settings.on_attach.__raw = ''
        function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]h", function() gs.next_hunk() end, { desc = "Next git hunk" })
          map("n", "[h", function() gs.prev_hunk() end, { desc = "Prev git hunk" })

          -- Hunk actions
          map("n", "<leader>hs",  function() gs.stage_hunk() end,  { desc = "Stage hunk" })
          map("n", "<leader>hr",  function() gs.reset_hunk() end,  { desc = "Reset hunk" })
          map("n", "<leader>hS",  function() gs.stage_buffer() end, { desc = "Stage buffer" })
          map("n", "<leader>hR",  function() gs.reset_buffer() end, { desc = "Reset buffer" })
          map("n", "<leader>hu",  function() gs.undo_stage_hunk() end, { desc = "Undo stage hunk" })
          map("n", "<leader>hp",  function() gs.preview_hunk() end, { desc = "Preview hunk" })
          map("v", "<leader>hs",  function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage selected hunk" })
          map("v", "<leader>hr",  function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset selected hunk" })

          -- Blame
          map("n", "<leader>hb",  function() gs.blame_line({ full = true }) end, { desc = "Blame line (full)" })
          map("n", "<leader>hB",  function() gs.toggle_current_line_blame() end, { desc = "Toggle inline blame" })

          -- Diff
          map("n", "<leader>hd",  function() gs.diffthis() end,    { desc = "Diff against HEAD" })
          map("n", "<leader>hD",  function() gs.diffthis("~") end, { desc = "Diff against index" })

          -- Text object: ih = inner hunk
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select inner hunk" })
        end
      '';
    };

    lazygit = {
      enable = true;
      settings.floating_window_use_plenary = 1;
    };
  };

  programs.nixvim.keymaps = [
    { mode = "n"; key = "<leader>lg"; action = "<cmd>LazyGit<CR>";            options.desc = "Open LazyGit"; }
    { mode = "n"; key = "<leader>lf"; action = "<cmd>LazyGitCurrentFile<CR>"; options.desc = "LazyGit current file log"; }
  ];
}
