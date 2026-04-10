{ ... }:

{
  programs.nixvim = {
    globals.mapleader = " ";

    keymaps = [
      # Insert mode
      { mode = "i"; key = "jk"; action = "<ESC>"; options.desc = "Exit insert mode"; }

      # Clear search highlights
      { mode = "n"; key = "<leader>nh"; action = ":nohl<CR>"; options.desc = "Clear search highlights"; }

      # Increment/decrement numbers
      { mode = "n"; key = "<leader>+"; action = "<C-a>"; options.desc = "Increment number"; }
      { mode = "n"; key = "<leader>-"; action = "<C-x>"; options.desc = "Decrement number"; }

      # Window splits
      { mode = "n"; key = "<leader>sv"; action = "<C-w>v"; options.desc = "Split vertically"; }
      { mode = "n"; key = "<leader>sh"; action = "<C-w>s"; options.desc = "Split horizontally"; }
      { mode = "n"; key = "<leader>se"; action = "<C-w>="; options.desc = "Equal split sizes"; }
      { mode = "n"; key = "<leader>sx"; action = "<cmd>close<CR>"; options.desc = "Close split"; }

      # Tab management
      { mode = "n"; key = "<leader>to"; action = "<cmd>tabnew<CR>"; options.desc = "New tab"; }
      { mode = "n"; key = "<leader>tx"; action = "<cmd>tabclose<CR>"; options.desc = "Close tab"; }
      { mode = "n"; key = "<leader>tn"; action = "<cmd>tabn<CR>"; options.desc = "Next tab"; }
      { mode = "n"; key = "<leader>tp"; action = "<cmd>tabp<CR>"; options.desc = "Prev tab"; }
      { mode = "n"; key = "<leader>tf"; action = "<cmd>tabnew %<CR>"; options.desc = "Buffer in new tab"; }

      # Tmux vertical pane
      {
        mode = "n";
        key = "<leader>tt";
        action.__raw = ''
          function()
            vim.fn.system(string.format("tmux split-window -v -l 20 -c %s", vim.fn.shellescape(vim.fn.getcwd())))
          end
        '';
        options.desc = "New tmux pane (20% height)";
      }

      # Open nixvim options search in browser (find plugins, LSPs, linters by name)
      {
        mode = "n";
        key = "<leader>nx";
        action.__raw = ''function() vim.fn.jobstart({ "xdg-open", "https://nix-community.github.io/nixvim/" }) end'';
        options.desc = "Open nixvim docs in browser";
      }
    ];
  };
}
