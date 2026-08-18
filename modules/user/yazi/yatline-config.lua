require("git"):setup()
require("yatline"):setup({
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
