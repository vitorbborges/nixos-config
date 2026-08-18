{ ... }:

{
  programs.nixvim.plugins = {

    gitsigns = {
      enable = true;
      settings.on_attach.__raw = builtins.readFile ./lua/gitsigns.lua;
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
