{ pkg, ... }:

{

  home.packages = [ pkgs.kitty ];
  programs.kitty = {
    enable = true;
    themeFile = "Dracula";
    enableGitIntegration = true;
    shellIntegration.enableZshIntegration = true;
    settings = {
      background_opacity = lib.mkForce "0.65";
      modify_font = "cell_width 90%";
      confirm_os_window_close = 0;
      scrollback_lines = 2000;
      mouse_hide_wait = "3.0";
      detect_urls = "yes";
      copy_on_select = "clipboard";
      paste_actions = "
        quote_urls_at_prompt,
        replace_newline";
      strip_trailing_spaces = "smart";
      focus_follows_mouse = "yes";
      text_fg_override_threshold = "4.5 ratio";
    };
    keybindings = {
      "ctrl+equal" = "change_font_size all +2.0";
      "ctrl+minus" = "change_font_size all -2.0";
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
    };
  };
  # TODO: FInish configuring kitty
}
