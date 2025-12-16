{ config, lib, pkgs, ... }:

{
  programs.sioyek = {
    enable = true;
    # Keybindings for Sioyek, see https://github.com/ahrm/sioyek/blob/main/pdf_viewer/keys.config
    bindings = {
      # Bind 'H' to create a highlight with the color defined by stylix.
      # The default 'y' binding creates a yellow highlight regardless of this setting.
      "add_highlight" = "H";

      # Open user keys file for editing ('e' for edit)
      "keys_user" = "ge";

      # Open default keys file for reference ('K' for Keys (default))
      "keys" = "gK";

      # Open user preferences file for editing ('p' for preferences)
      "prefs_user" = "gp";
    };
  };

  # Let stylix manage sioyek's appearance
  stylix.targets.sioyek.enable = true;
}
