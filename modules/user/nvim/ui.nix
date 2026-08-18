{ pkgs, ... }:

{
  programs.nixvim.plugins = {

    # Status line — lightweight, stylix handles colors
    lualine = {
      enable = true;
      settings.options = {
        theme = "auto";
        globalstatus = true;
        component_separators = { left = "|"; right = "|"; };
        section_separators  = { left = ""; right = ""; };
      };
    };

    # Buffer tabs across the top
    bufferline = {
      enable = true;
      settings.options = {
        mode = "buffers";
        separator_style = "slant";
        always_show_bufferline = false;
        show_buffer_close_icons = true;
        show_close_icon = false;
      };
    };

    # Indent guides
    indent-blankline = {
      enable = true;
      settings = {
        indent.char = "│";
        scope.enabled = true;
      };
    };

    # Better vim.ui.select / vim.ui.input (used by LSP rename, code actions, etc.)
    dressing.enable = true;

    # Icon provider for bufferline, oil, etc. (replaces nvim-web-devicons)
    mini = {
      enable = true;
      mockDevIcons = true;  # suppress auto-enable of web-devicons by other plugins
      modules.icons = { };
    };
  };

  # alpha-nvim loaded via extraPlugins to avoid nixvim generating a broken setup() call
  programs.nixvim.extraPlugins = [ pkgs.vimPlugins.alpha-nvim ];

  programs.nixvim.extraConfigLua = builtins.readFile ./lua/dashboard.lua;

  programs.nixvim.keymaps = [
    # Bufferline navigation
    { mode = "n"; key = "<Tab>";      action = "<cmd>BufferLineCycleNext<CR>"; options.desc = "Next buffer"; }
    { mode = "n"; key = "<S-Tab>";    action = "<cmd>BufferLineCyclePrev<CR>"; options.desc = "Prev buffer"; }
    { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<CR>";             options.desc = "Close buffer"; }
  ];
}
