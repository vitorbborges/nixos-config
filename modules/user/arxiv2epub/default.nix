{ pkgs, ... }:

let
  arxiv2epub = pkgs.writeShellApplication {
    name = "arxiv2epub";
    # These are prepended to PATH inside the wrapper — no Nix store paths needed
    # in the script itself. uv finds python3 in PATH, bypassing UV_PYTHON_DOWNLOADS=never.
    runtimeInputs = with pkgs; [ wget curl python3 pandoc uv ];
    # marker-pdf pulls in torch which needs libstdc++.so.6 — NixOS has no FHS so inject it.
    # nix-ld does not help here: Python extensions are loaded via dlopen through the Nix-patched
    # ld, which only looks at LD_LIBRARY_PATH, not NIX_LD_LIBRARY_PATH.
    text = ''
      # gcc libstdc++ for torch; /run/opengl-driver/lib for libcuda.so (NVIDIA driver, NixOS)
      export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      # Load GEMINI_API_KEY from secrets file if not already set
      if [[ -z "''${GEMINI_API_KEY:-}" && -f "$HOME/.config/secrets/api-keys.sh" ]]; then
        # shellcheck source=/dev/null
        source "$HOME/.config/secrets/api-keys.sh"
      fi
      ${builtins.readFile ./arxiv2epub.sh}
    '';
  };
in
{
  home.packages = [ arxiv2epub ];
}
