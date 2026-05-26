{ config, pkgs, lib, ... }:
let
  c     = config.lib.stylix.colors;
  font  = config.stylix.fonts.monospace.name;
  icons = "${pkgs.wlogout}/share/wlogout/icons";

  # GTK3 CSS does not support 8-digit hex (#RRGGBBAA). Must use rgba().
  rgba = hex: alpha:
    let
      r = lib.fromHexString (builtins.substring 0 2 hex);
      g = lib.fromHexString (builtins.substring 2 2 hex);
      b = lib.fromHexString (builtins.substring 4 2 hex);
    in "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";
in
{
  programs.wlogout = {
    enable = true;

    layout = [
      { label = "lock";     action = "loginctl lock-session"; text = ""; keybind = "l"; }
      { label = "logout";   action = "hyprctl dispatch exit"; text = ""; keybind = "e"; }
      { label = "suspend";  action = "systemctl suspend";     text = ""; keybind = "u"; }
      { label = "reboot";   action = "systemctl reboot";      text = ""; keybind = "r"; }
      { label = "shutdown"; action = "systemctl poweroff";    text = ""; keybind = "s"; }
    ];

    style = ''
      * {
        background-image: none;
        box-shadow: none;
      }
      window {
        background-color: ${rgba c.base00 0.88};
        font-family: "${font}";
        color: #${c.base05};
      }
      button {
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
        background-color: ${rgba c.base00 0.65};
        border: none;
        margin: 5px;
        transition: background-color 0.2s ease-in-out;
      }
      #lock     { background-image: image(url("${icons}/lock.png"));     }
      #logout   { background-image: image(url("${icons}/logout.png"));   }
      #suspend  { background-image: image(url("${icons}/suspend.png"));  }
      #reboot   { background-image: image(url("${icons}/reboot.png"));   }
      #shutdown { background-image: image(url("${icons}/shutdown.png")); }
      button:hover {
        background-color: ${rgba c.base02 0.3};
      }
      button:focus {
        background-color: ${rgba c.base0D 0.2};
        outline-style: none;
      }
    '';
  };
}
