{ pkgs, lib, font, ... }:

{

  home = {
    packages = [ pkgs.kitty ];
    sessionVariables.TERMINAL = "kitty";
  };

  programs.kitty = {
    enable = true;
    # Remove themeFile to let stylix handle theming
    enableGitIntegration = true;
    # Remove font settings to let stylix handle fonts
    shellIntegration.enableZshIntegration = true;
    settings = {
      # Let stylix handle opacity through its terminal settings
      modify_font = "cell_width 90%";
      confirm_os_window_close = 0;
      scrollback_lines = 2000;
      mouse_hide_wait = "3.0";
      detect_urls = "yes";
      copy_on_select = "clipboard";
      paste_actions = "quote-urls-at-prompt,replace-dangerous-control-codes";
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
}
