{ ... }:

{
  programs.nixvim.plugins = {

    # auto-session: save/restore sessions per working directory
    auto-session = {
      enable = true;
      settings = {
        auto_save = true;
        auto_restore = true;
        suppressed_dirs = [ "~/" "~/Downloads" "/tmp" ];
      };
    };

    # yazi.nvim: open yazi as a floating window inside nvim
    # pick a file/dir and it drops you back in nvim at that location
    yazi = {
      enable = true;
      settings.future_features.process_events = true;
    };
  };

  programs.nixvim.keymaps = [
    { mode = "n"; key = "<leader>wr"; action = "<cmd>SessionRestore<CR>"; options.desc = "Restore session (cwd)"; }
    { mode = "n"; key = "<leader>ws"; action = "<cmd>SessionSave<CR>";    options.desc = "Save session (cwd)"; }
    { mode = "n"; key = "<leader>ey"; action = "<cmd>Yazi<CR>";           options.desc = "Open yazi (current file)"; }
    { mode = "n"; key = "<leader>eY"; action = "<cmd>Yazi cwd<CR>";       options.desc = "Open yazi (cwd)"; }
  ];
}
