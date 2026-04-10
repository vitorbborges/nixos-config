{ ... }:

{
  programs.nixvim.plugins.render-markdown = {
    enable = true;
    settings = {

      # Reveal raw markdown on the cursor line so editing stays comfortable
      anti_conceal = {
        enabled = true;
        above = 0;
        below = 0;
      };

      # Headings: full-width highlight, no sign column clutter
      heading = {
        enabled = true;
        sign = false;
        position = "overlay";
        width = "full";
        icons = [ "󰲡 " "󰲣 " "󰲥 " "󰲧 " "󰲩 " "󰲫 " ];
      };

      # Code blocks: full style with language badge + icon, hidden delimiters
      code = {
        enabled = true;
        sign = false;
        style = "full";
        border = "hide";
        language_icon = true;
        language_name = true;
        width = "full";
        disable_background = [ "diff" ];
      };

      # Task lists: keep raw [ ] / [x] visible; add custom [-] and [~] states
      checkbox = {
        enabled = true;
        unchecked.icon = "󰄱 ";
        checked.icon   = "󰱒 ";
        custom = {
          todo      = { raw = "[-]"; rendered = "󰥔 "; highlight = "RenderMarkdownTodo"; };
          cancelled = { raw = "[~]"; rendered = "󰰱 "; highlight = "RenderMarkdownError"; };
        };
      };

      # Tables: round border preset, padded cells
      pipe_table = {
        enabled = true;
        style = "full";
        preset = "round";
        cell = "padded";
        padding = 1;
      };

      # Bullet points: cycle icons by nesting level
      bullet.icons = [ "●" "○" "◆" "◇" ];

      # Horizontal rules
      dash = {
        icon = "─";
        width = "full";
      };

      # No sign column decoration (keeps the gutter clean)
      sign.enabled = false;

      # blink-cmp source: completes callout types ([!NOTE] etc.) in markdown
      completions.blink.enabled = true;
    };
  };

  programs.nixvim.keymaps = [
    { mode = "n"; key = "<leader>um"; action = "<cmd>RenderMarkdown toggle<CR>";   options.desc = "Toggle markdown render"; }
    { mode = "n"; key = "<leader>ue"; action = "<cmd>RenderMarkdown expand<CR>";   options.desc = "Expand anti-conceal margin"; }
    { mode = "n"; key = "<leader>uc"; action = "<cmd>RenderMarkdown contract<CR>"; options.desc = "Contract anti-conceal margin"; }
    {
      mode = "n";
      key = "<leader>mt";
      action.__raw = ''
        function()
          local line = vim.api.nvim_get_current_line()
          if line:match("%[x%]") then
            vim.api.nvim_set_current_line(line:gsub("%[x%]", "[ ]", 1))
          elseif line:match("%[ %]") then
            vim.api.nvim_set_current_line(line:gsub("%[ %]", "[x]", 1))
          end
        end
      '';
      options.desc = "Toggle markdown checkbox";
    }
  ];
}
