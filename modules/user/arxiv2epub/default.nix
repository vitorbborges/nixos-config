{ pkgs, ... }:

let
  arxiv2epub = pkgs.writeShellApplication {
    name = "arxiv2epub";
    # These are prepended to PATH inside the wrapper — no Nix store paths needed
    # in the script itself. uv finds python3 in PATH, bypassing UV_PYTHON_DOWNLOADS=never.
    runtimeInputs = with pkgs; [ wget curl python3 pandoc uv ];
    text = builtins.readFile ./arxiv2epub.sh;
  };
in
{
  home.packages = [ arxiv2epub ];
}
