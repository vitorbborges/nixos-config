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

  programs.nixvim.extraConfigLua = ''
    -- Alpha dashboard layout
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "                                   ",
      "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
      "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
      "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⧣⣄     ",
      "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
      "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
      "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
      "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
      " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
      " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
      "      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ",
      "       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ",
      "                                   ",
    }

    dashboard.section.buttons.val = {
      dashboard.button("e", " 📝 New File",           "<cmd>ene<CR>"),
      dashboard.button("f", " 📁 Find File",           "<cmd>FzfLua files<CR>"),
      dashboard.button("s", " 🔄 Restore Session",     "<cmd>SessionRestore<CR>"),
      dashboard.button("r", " 📚 Recent Files",        "<cmd>FzfLua oldfiles<CR>"),
      dashboard.button("g", " 🔍 Grep Project",        "<cmd>FzfLua live_grep<CR>"),
      dashboard.button("c", " ⚙️  Configure Neovim",   "<cmd>cd ~/.config/nvim/ <bar> Oil<CR>"),
      dashboard.button("q", " 🚪 Quit NVIM",           "<cmd>qa<CR>"),
    }

    alpha.setup(dashboard.opts)
  '';

  programs.nixvim.keymaps = [
    # Bufferline navigation
    { mode = "n"; key = "<Tab>";      action = "<cmd>BufferLineCycleNext<CR>"; options.desc = "Next buffer"; }
    { mode = "n"; key = "<S-Tab>";    action = "<cmd>BufferLineCyclePrev<CR>"; options.desc = "Prev buffer"; }
    { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<CR>";             options.desc = "Close buffer"; }
  ];
}
