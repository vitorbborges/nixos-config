#!/usr/bin/env bash
# arxiv2epub - Convert arXiv PDF to EPUB with marker + pandoc
# Usage: arxiv2epub https://arxiv.org/abs/2602.19597
#        arxiv2epub 2602.19597
#
# LLM-enhanced conversion is used automatically when GEMINI_API_KEY is set.
#
# Optional env vars:
#   GEMINI_API_KEY  — Gemini API key for marker's --use_llm (loaded from ~/.config/secrets/api-keys.sh)
#   DOWNLOAD_DIR    — output directory (default: ~/Downloads)

set -euo pipefail

# Reduce CUDA memory fragmentation (marker/surya recommendation)
export PYTORCH_CUDA_ALLOC_CONF="${PYTORCH_CUDA_ALLOC_CONF:-expandable_segments:True}"

DOWNLOAD_DIR="${DOWNLOAD_DIR:-$HOME/Downloads}"
TEMP_DIR=$(mktemp -d -t arxiv2epub-XXXXXX)

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

# Kill entire process group on Ctrl+C (marker spawns worker subprocesses that
# survive a plain SIGINT to the shell without this)
trap 'trap - INT TERM; echo "Interrupted." >&2; kill 0; exit 130' INT TERM

die()  { echo "ERROR: $*" >&2; exit 1; }
warn() { echo "WARNING: $*" >&2; }

# --- Parse arXiv ID from URL or bare ID ---
input="${1:-}"
[[ -z "$input" ]] && die "Usage: arxiv2epub <arxiv-id-or-url>  (e.g. 2602.19597)"

if [[ "$input" =~ arxiv\.org/abs/([0-9]+\.[0-9]+) ]]; then
    paper_id="${BASH_REMATCH[1]}"
elif [[ "$input" =~ ^([0-9]+\.[0-9]+)$ ]]; then
    paper_id="$input"
else
    die "Could not parse arXiv ID from '$input'"
fi

echo "arXiv ID: $paper_id"
PDF_URL="https://arxiv.org/pdf/${paper_id}.pdf"

# --- Fetch paper title for informative file naming ---
echo "Fetching paper metadata..."
TITLE=$(curl -sf "https://export.arxiv.org/api/query?id_list=${paper_id}" | \
    python3 -c \
    "import sys,xml.etree.ElementTree as ET; tree=ET.fromstring(sys.stdin.read()); ns={'a':'http://www.w3.org/2005/Atom'}; e=tree.find('.//a:entry/a:title',ns); print(e.text.strip().replace('\n',' ') if e is not None else '')" \
    2>/dev/null || echo "")

if [[ -n "$TITLE" ]]; then
    SAFE_TITLE=$(echo "$TITLE" | tr -d '/:*?<>|' | tr ' ' '_' | cut -c1-80)
    OUTPUT_EPUB="$DOWNLOAD_DIR/${SAFE_TITLE}_${paper_id}.epub"
    echo "Title: $TITLE"
else
    OUTPUT_EPUB="$DOWNLOAD_DIR/arXiv_${paper_id}.epub"
    echo "Warning: could not fetch title, falling back to arXiv ID filename"
fi

# --- Download PDF ---
echo "Downloading PDF..."
wget -q --show-progress "$PDF_URL" -O "$TEMP_DIR/paper.pdf"

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

# --- Convert PDF → Markdown via marker_single ---
# marker_single processes one file in the main process (no worker pool),
# using ~half the VRAM of the multi-worker `marker` CLI.
echo "Converting PDF to Markdown (this may take a few minutes)..."

run_marker() {
    uv run \
        --python "$(command -v python3)" \
        --with marker-pdf \
        --with psutil \
        marker_single "$TEMP_DIR/paper.pdf" --output_dir "$TEMP_DIR/output" "$@"
}

wait_for_gpu

if [[ -n "${GEMINI_API_KEY:-}" ]]; then
    echo "LLM-enhanced conversion enabled (Gemini)..."
    run_marker --use_llm \
        --llm_service marker.services.gemini.GoogleGeminiService \
        --gemini_api_key "$GEMINI_API_KEY"
else
    echo "No GEMINI_API_KEY set — using standard conversion."
    run_marker
fi

MARKDOWN_FILE="$TEMP_DIR/output/paper/paper.md"
[[ -f "$MARKDOWN_FILE" ]] || die "Marker failed to produce paper.md"

# --- Fix deprecated \rm LaTeX macro ---
printf 'Fixing LaTeX macros (\\rm -> \\mathrm)...\n'
sed -i 's/\\rm\([[:space:]{]\)/\\mathrm\1/g; s/\\rm\([a-zA-Z]\)/\\mathrm{\1}/g' "$MARKDOWN_FILE"

# --- Convert Markdown → EPUB ---
echo "Generating EPUB..."
pandoc "$MARKDOWN_FILE" \
    -o "$TEMP_DIR/paper.epub" \
    --to epub3 --mathml --toc \
    --resource-path="$TEMP_DIR/output/paper"

mv "$TEMP_DIR/paper.epub" "$OUTPUT_EPUB"
echo "EPUB saved to: $OUTPUT_EPUB"
