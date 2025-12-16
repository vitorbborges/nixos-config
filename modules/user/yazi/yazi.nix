{ pkgs, ... }:

{

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    plugins = {
      git = pkgs.yaziPlugins.git;
      sudo = pkgs.yaziPlugins.sudo;
      piper = pkgs.yaziPlugins.piper;
      yatline = pkgs.yaziPlugins.yatline;
    };
    initLua = ''
      require("git"):setup()
      require("yatline"):setup({
	--theme = my_theme,
	section_separator = { open = "\u{e0b2}", close = "\u{e0b0}" },
	part_separator = { open = "\u{e0b3}", close = "\u{e0b1}" },
	inverse_separator = { open = "\u{e0d6}", close = "\u{e0d7}" },

	style_a = {
		fg = "black",
		bg_mode = {
			normal = "white",
			select = "brightyellow",
			un_set = "brightred"
		}
	},
	style_b = { bg = "brightblack", fg = "brightwhite" },
	style_c = { bg = "black", fg = "brightwhite" },

	permissions_t_fg = "green",
	permissions_r_fg = "yellow",
	permissions_w_fg = "red",
	permissions_x_fg = "cyan",
	permissions_s_fg = "white",

	tab_width = 20,
	tab_use_inverse = false,

	selected = { icon = "\u{f0eed}", fg = "yellow" },
	copied = { icon = "\u{f0c5}", fg = "green" },
	cut = { icon = "\u{f0c4}", fg = "red" },

	total = { icon = "\u{f0b8d}", fg = "yellow" },
	succ = { icon = "\u{f05d}", fg = "green" },
	fail = { icon = "\u{f05c}", fg = "red" },
	found = { icon = "\u{f0b95}", fg = "blue" },
	processed = { icon = "\u{f040d}", fg = "green" },

	show_background = true,

	display_header_line = true,
	display_status_line = true,

	component_positions = { "header", "tab", "status" },

	header_line = {
		left = {
			section_a = {
                			{type = "line", custom = false, name = "tabs", params = {"left"}},
			},
			section_b = {
			},
			section_c = {
			}
		},
		right = {
			section_a = {
			},
			section_b = {
			},
			section_c = {
			}
		}
	},

	status_line = {
		left = {
			section_a = {
                			{type = "string", custom = false, name = "tab_mode"},
			},
			section_b = {
                			{type = "string", custom = false, name = "hovered_size"},
			},
			section_c = {
                			{type = "string", custom = false, name = "hovered_path"},
                			{type = "coloreds", custom = false, name = "count"},
			}
		},
		right = {
			section_a = {
                			{type = "string", custom = false, name = "cursor_position"},
			},
			section_b = {
                			{type = "string", custom = false, name = "cursor_percentage"},
			},
			section_c = {
                			{type = "string", custom = false, name = "hovered_file_extension", params = {true}},
                			{type = "coloreds", custom = false, name = "permissions"},
			}
		}
	},
      })
    '';

    theme.icon = {
      dirs = [
        { name = ".config"; text = ""; }
        { name = ".git"; text = ""; }
        { name = ".github"; text = ""; }
        { name = ".npm"; text = ""; }
        { name = "Desktop"; text = ""; }
        { name = "Development"; text = ""; }
        { name = "Documents"; text = ""; }
        { name = "Downloads"; text = ""; }
        { name = "Library"; text = ""; }
        { name = "Movies"; text = ""; }
        { name = "Music"; text = ""; }
        { name = "Pictures"; text = ""; }
        { name = "Public"; text = ""; }
        { name = "Videos"; text = ""; }
        { name = "nixos"; text = ""; }
        { name = "Archive"; text = ""; }
        { name = "Media"; text = ""; }
        { name = "Podcasts"; text = ""; }
        { name = "Drive"; text = ""; }
        { name = "KP"; text = ""; }
        { name = "Books"; text = ""; }
        { name = "Games"; text = ""; }
        { name = "Game Saves"; text = ""; }
        { name = "Templates"; text = ""; }
        { name = "Notes"; text = ""; }
        { name = "Projects"; text = ""; }
        { name = "Screenshots"; text = ""; }
      ];
    };

    keymap = {
      mgr.prepend_keymap = [
        { run = "cd ~/Projects"; on = [ "g" "p" ]; desc = "Go to projects"; }
        { run = "cd ~/Screenshots"; on = [ "g" "s" ]; desc = "Go to screenshots"; }
        { run = "shell ' \"$@\"' --cursor=0 --interactive"; on = [ "@" ]; }
        { run = "hidden toggle"; on = [ "<C-h>" ]; }
        { run = "yank"; on = [ "y" "y" ]; }
        { run = "copy path"; on = [ "y" "p" ]; }
        { run = "copy dirname"; on = [ "y" "d" ]; }
        { run = "copy filename"; on = [ "y" "n" ]; }
        { run = "copy name_without_ext"; on = [ "y" "N" ]; }
        { run = "yank --cut"; on = [ "d" "d" ]; }
        { run = "remove --force"; on = [ "d" "D" ]; }
        { run = "paste"; on = [ "p" "p" ]; }
        { run = "paste --force"; on = [ "p" "P" ]; }
        { run = "cd --interactive"; on = [ "c" "d" ]; }

        # Sort bindings
        { run = "sort mtime --reverse=no"; on = [ "s" "t" ]; desc = "Sort by modification time"; }
        { run = "sort mtime --reverse=yes"; on = [ "s" "T" ]; desc = "Sort by modification time (reverse)"; }
        { run = "sort natural --reverse=no"; on = [ "s" "n" ]; desc = "Sort by name (natural)"; }
        { run = "sort natural --reverse=yes"; on = [ "s" "N" ]; desc = "Sort by name (natural, reverse)"; }
        { run = "sort alphabetical --reverse=no"; on = [ "s" "a" ]; desc = "Sort by name (alphabetical)"; }
        { run = "sort alphabetical --reverse=yes"; on = [ "s" "A" ]; desc = "Sort by name (alphabetical, reverse)"; }
        { run = "sort extension --reverse=no"; on = [ "s" "x" ]; desc = "Sort by extension"; }
        { run = "sort extension --reverse=yes"; on = [ "s" "X" ]; desc = "Sort by extension (reverse)"; }
        { run = "sort size --reverse=no"; on = [ "s" "s" ]; desc = "Sort by size"; }
        { run = "sort size --reverse=yes"; on = [ "s" "S" ]; desc = "Sort by size (reverse)"; }

        { run = "tab_create --current"; on = [ "t" ]; }
        { run = "close"; on = [ "x" ]; }
        { run = "tab_switch 1 --relative"; on = [ "J" ]; }
        { run = "tab_switch 1 --relative"; on = [ "<C-Tab>" ]; }
        { run = "tab_switch -1 --relative"; on = [ "K" ]; }
        { run = "tab_switch -1 --relative"; on = [ "<C-BackTab>" ]; }
        { run = "undo"; on = [ "u" ]; }
        { run = "redo"; on = [ "<C-r>" ]; }
      ];
    };
  };
}