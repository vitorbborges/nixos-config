#!/usr/bin/env bash
# pdf2epub - Convert PDF(s) to EPUB using marker + pandoc
# Usage: pdf2epub /path/to/file.pdf
#        pdf2epub /path/to/directory    # converts all *.pdf files in dir
#
# Optional env vars:
#   GEMINI_API_KEY  — Gemini API key for LLM-enhanced marker conversion
#   FORCE=1         — re-convert even if .epub already exists

set -euo pipefail

# Reduce CUDA memory fragmentation (marker/surya recommendation)
export PYTORCH_CUDA_ALLOC_CONF="${PYTORCH_CUDA_ALLOC_CONF:-expandable_segments:True}"

die()  { echo "ERROR: $*" >&2; exit 1; }
warn() { echo "WARNING: $*" >&2; }

input="${1:-}"
[[ -z "$input" ]] && die "Usage: pdf2epub <pdf-file-or-directory>"

# Kill entire process group on Ctrl+C
trap 'trap - INT TERM; echo "Interrupted." >&2; kill 0; exit 130' INT TERM

# --- Wait for GPU compute processes to clear; fall back to CPU after timeout ---
# Checks CUDA compute apps (ignores Hyprland/display). marker_single needs the
# GPU essentially to itself (~5 GiB); stale marker processes hold 3-7 GiB.
wait_for_gpu() {
    local timeout="${1:-120}" slept=0 other_mib
    command -v nvidia-smi &>/dev/null || return 0
    while true; do
        other_mib=$(nvidia-smi --query-compute-apps=used_memory \
                        --format=csv,noheader,nounits 2>/dev/null \
                    | awk '{s+=$1} END {print s+0}')
        [[ "$other_mib" -le 200 ]] && return 0
        if [[ "$slept" -ge "$timeout" ]]; then
            warn "Other compute processes still hold ${other_mib} MiB GPU after ${timeout}s — switching to CPU"
            export CUDA_VISIBLE_DEVICES=""
            return 0
        fi
        echo "  GPU: ${other_mib} MiB held by other compute processes — waiting (${slept}s/${timeout}s)..."
        sleep 5
        (( slept += 5 )) || true
    done
}

# --- Collect PDFs to process ---
declare -a PDFS=()
if [[ -f "$input" ]]; then
    [[ "$input" == *.pdf ]] || die "File is not a PDF: '$input'"
    PDFS=("$(realpath "$input")")
elif [[ -d "$input" ]]; then
    while IFS= read -r -d '' f; do
        PDFS+=("$f")
    done < <(find "$(realpath "$input")" -maxdepth 1 -name "*.pdf" -print0 | sort -z)
    [[ ${#PDFS[@]} -gt 0 ]] || die "No PDF files found in '$input'"
    echo "Found ${#PDFS[@]} PDF(s) in $(realpath "$input")"
else
    die "Not a file or directory: '$input'"
fi

# --- marker_single runner ---
# Processes one PDF in the main process (no worker pool), using ~half the VRAM
# of the multi-worker `marker` CLI.
run_marker() {
    local pdf_path="$1" output_dir="$2"
    shift 2
    uv run \
        --python "$(command -v python3)" \
        --with marker-pdf \
        --with psutil \
        marker_single "$pdf_path" --output_dir "$output_dir" "$@"
}

# --- Background pandoc jobs (CPU-only, pipelined with GPU work) ---
declare -a BG_PIDS=()

launch_pandoc_bg() {
    local md="$1" output_epub="$2" temp_dir="$3" label="$4"
    (
        if pandoc "$md" \
                -o "$temp_dir/out.epub" \
                --to epub3 --mathml --toc \
                --resource-path="$(dirname "$md")"; then
            mv "$temp_dir/out.epub" "$output_epub"
            echo "  EPUB saved: $output_epub"
        else
            warn "pandoc failed for $label"
            rm -rf "$temp_dir"
            exit 1
        fi
        rm -rf "$temp_dir"
    ) &
    BG_PIDS+=($!)
}

# --- Per-PDF conversion: GPU step (sequential) + pandoc (pipelined background) ---
convert_one() {
    local pdf_path="$1"
    local name dir output_epub temp_dir md

    name=$(basename "$pdf_path" .pdf)
    dir=$(dirname "$pdf_path")
    output_epub="$dir/${name}.epub"

    if [[ -f "$output_epub" && "${FORCE:-0}" != "1" ]]; then
        echo "Skipping (exists): ${name}.epub  [FORCE=1 to re-convert]"
        return 0
    fi

    echo "--> ${name}.pdf"
    temp_dir=$(mktemp -d -t pdf2epub-XXXXXX)
    # Copy with canonical name so output path is predictable: output/paper/paper.md
    cp "$pdf_path" "$temp_dir/paper.pdf"

    # Wait for VRAM before each GPU job (previous job may still be releasing memory)
    wait_for_gpu

    # GPU step — runs to completion before the next PDF starts
    if [[ -n "${GEMINI_API_KEY:-}" ]]; then
        echo "    LLM-enhanced conversion (Gemini)..."
        run_marker "$temp_dir/paper.pdf" "$temp_dir/output" \
            --use_llm \
            --llm_service marker.services.gemini.GoogleGeminiService \
            --gemini_api_key "$GEMINI_API_KEY"
    else
        run_marker "$temp_dir/paper.pdf" "$temp_dir/output"
    fi

    md="$temp_dir/output/paper/paper.md"
    if [[ ! -f "$md" ]]; then
        warn "Marker failed to produce markdown for ${name}, skipping"
        rm -rf "$temp_dir"
        return 1
    fi

    # Fix deprecated \rm LaTeX macro
    sed -i 's/\\rm\([[:space:]{]\)/\\mathrm\1/g; s/\\rm\([a-zA-Z]\)/\\mathrm{\1}/g' "$md"

    # CPU step — launch in background so next GPU job can start immediately
    launch_pandoc_bg "$md" "$output_epub" "$temp_dir" "$name"
}

# --- Main loop ---
MARKER_ERRORS=0
for pdf in "${PDFS[@]}"; do
    convert_one "$pdf" || { (( MARKER_ERRORS++ )) || true; }
done

# Wait for all background pandoc jobs, collecting failures
PANDOC_ERRORS=0
if [[ ${#BG_PIDS[@]} -gt 0 ]]; then
    echo "Waiting for EPUB generation..."
    for pid in "${BG_PIDS[@]}"; do
        wait "$pid" || { (( PANDOC_ERRORS++ )) || true; }
    done
fi

TOTAL_ERRORS=$(( MARKER_ERRORS + PANDOC_ERRORS ))
if [[ $TOTAL_ERRORS -gt 0 ]]; then
    die "$TOTAL_ERRORS conversion(s) failed (marker: $MARKER_ERRORS, pandoc: $PANDOC_ERRORS)"
fi
echo "All done."
