{ pkgs, ... }:

{

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # Remove flavors to let stylix handle theming

    # TODO: Finish configuring keymaps and plugins.

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
  };
}
