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

  # Embedded in the EPUB so equations render correctly in crengine (KOReader).
  # Display SVGs are scaled 2x by fix_epub_math.py so they appear at a proper
  # display-equation size (~80-100 px) rather than body-text height (~45 px).
  # Inline equations are pinned to 1em height so they track the reading font size.
  mathCss = pkgs.writeText "math.css" ''
    img {
        width: 100%;
        height: auto;
    }
    span.math.inline img {
        width: auto;
        height: 1em;
        vertical-align: -0.2em;
    }
    span.math.display {
        display: block;
        text-align: center;
        margin: 0.8em auto;
    }
    span.math.display img {
        width: auto;
        height: auto;
        max-width: 100%;
    }
  '';

  # Scales display-math SVGs 2x after pandoc embeds them, so they render at a
  # readable size. Inline SVGs are left alone (CSS controls their height to 1em).
  fixEpubMath = pkgs.writeText "fix-epub-math.py" (builtins.readFile ./fix_epub_math.py);

  # Shared pandoc flags injected into both conversion scripts
  pandocPreamble = ''
    MATH_CSS="${mathCss}"
    FIX_EPUB_MATH="${fixEpubMath}"
  '';

  arxiv2epub = pkgs.writeShellApplication {
    name = "arxiv2epub";
    # wget: download PDFs; curl: fetch arXiv metadata
    runtimeInputs = with pkgs; [ wget curl python3 pandoc uv ];
    text = wrapperPreamble + pandocPreamble + (builtins.readFile ./arxiv2epub.sh);
  };

  pdf2epub = pkgs.writeShellApplication {
    name = "pdf2epub";
    # findutils: find PDFs in directory
    runtimeInputs = with pkgs; [ findutils python3 pandoc uv ];
    text = wrapperPreamble + pandocPreamble + (builtins.readFile ./pdf2epub.sh);
  };

  # Reads Librera Reader's app-Bookmarks.json (synced via Syncthing) and
  # generates/updates per-paper markdown note files in notes/.
  libreraNotesScript = pkgs.writeText "librera-notes.py" (builtins.readFile ./librera_notes.py);

  libreraNotesWrapper = pkgs.writeShellApplication {
    name = "librera-notes";
    runtimeInputs = with pkgs; [ python3 ];
    text = ''
      NOTES_DIR="''${NOTES_DIR:-$HOME/EDF/bibliography/notes}"
      LIBRERA_DIR="''${LIBRERA_DIR:-$HOME/EDF/bibliography/.librera}"
      export NOTES_DIR LIBRERA_DIR
      exec python3 "${libreraNotesScript}" "$@"
    '';
  };

  bibliographyDir = "/home/vitor/EDF/bibliography";

  # Watches pdfs/ for new files and converts them to epub/ in the background.
  # Sends a desktop notification on completion via libnotify.
  bibliographyWatcher = pkgs.writeShellApplication {
    name = "bibliography-watch";
    runtimeInputs = with pkgs; [ libnotify ];
    text = wrapperPreamble + ''
      if [[ -z "''${GEMINI_API_KEY:-}" ]]; then
        notify-send --urgency=critical "Bibliography" "GEMINI_API_KEY not set — conversion skipped" || true
        exit 1
      fi

      PDFS_DIR="${bibliographyDir}/pdfs"
      EPUB_DIR="${bibliographyDir}/epub"

      pending=()
      for pdf in "$PDFS_DIR"/*.pdf; do
        [[ -f "$pdf" ]] || continue
        name=$(basename "$pdf" .pdf)
        [[ -f "$EPUB_DIR/$name.epub" ]] && continue
        pending+=("$pdf")
      done

      total=''${#pending[@]}
      [[ $total -eq 0 ]] && exit 0

      notify-send --urgency=low "Bibliography" "Queued $total PDF(s) for conversion" || true

      converted=0
      failed=0
      for pdf in "''${pending[@]}"; do
        name=$(basename "$pdf" .pdf)
        echo "bibliography-watch: [$((converted + failed + 1))/$total] converting $name.pdf"
        if ${pdf2epub}/bin/pdf2epub --output-dir "$EPUB_DIR" "$pdf"; then
          converted=$((converted + 1))
          notify-send --urgency=low "Bibliography" "[$converted/$total] Converted $name" || true
        else
          failed=$((failed + 1))
          notify-send --urgency=normal "Bibliography" "Failed: $name.pdf" || true
        fi
      done

      if [[ $failed -eq 0 ]]; then
        notify-send --urgency=low "Bibliography" "All done — $converted PDF(s) converted" || true
      else
        notify-send --urgency=normal "Bibliography" "Done: $converted converted, $failed failed" || true
      fi
    '';
  };
in
{
  home.packages = [ arxiv2epub pdf2epub bibliographyWatcher libreraNotesWrapper ];

  systemd.user.paths.bibliography-watch = {
    Unit.Description = "Watch bibliography pdfs/ for new PDFs";
    Path.PathChanged = "${bibliographyDir}/pdfs";
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.bibliography-watch = {
    Unit.Description = "Convert new PDFs in bibliography pdfs/ to epub/";
    Service = {
      Type = "simple";
      ExecStart = "${bibliographyWatcher}/bin/bibliography-watch";
    };
  };
}
