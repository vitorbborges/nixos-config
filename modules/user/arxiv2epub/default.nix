{ pkgs, ... }:

let
  # Shared Nix wrapper preamble: inject libstdc++ + CUDA libs, load API key
  wrapperPreamble = ''
    # gcc libstdc++ for torch; /run/opengl-driver/lib for libcuda.so (NVIDIA driver, NixOS)
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    # Load GEMINI_API_KEY from secrets file if not already set
    if [[ -z "''${GEMINI_API_KEY:-}" && -f "$HOME/.config/secrets/api-keys.sh" ]]; then
      # shellcheck source=/dev/null
      source "$HOME/.config/secrets/api-keys.sh"
    fi
  '';

  arxiv2epub = pkgs.writeShellApplication {
    name = "arxiv2epub";
    # wget: download PDFs; curl: fetch arXiv metadata
    runtimeInputs = with pkgs; [ wget curl python3 pandoc uv ];
    text = wrapperPreamble + (builtins.readFile ./arxiv2epub.sh);
  };

  pdf2epub = pkgs.writeShellApplication {
    name = "pdf2epub";
    # findutils: find PDFs in directory
    runtimeInputs = with pkgs; [ findutils python3 pandoc uv ];
    text = wrapperPreamble + (builtins.readFile ./pdf2epub.sh);
  };
in
{
  home.packages = [ arxiv2epub pdf2epub ];
}
