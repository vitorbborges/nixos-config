#!/usr/bin/env bash
set -euo pipefail

[ -f "$HOME/.config/secrets/api-keys.sh" ] && source "$HOME/.config/secrets/api-keys.sh"

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    echo "ERROR: GEMINI_API_KEY is not set." >&2
    exit 1
fi

PYTHON=$(find /nix/store -maxdepth 3 -name 'python3*' -path '*/bin/python3*' ! -name '*.so' | grep -v wrapper | head -1)

# Find libstdc++.so.6 - prefer gcc's but fallback to any
LIBSTDCXX=$(find /nix/store -name 'libstdc++.so.6' 2>/dev/null | head -1)
if [[ -z "$LIBSTDCXX" ]]; then
    echo "ERROR: libstdc++.so.6 not found in /nix/store" >&2
    exit 1
fi
export LD_PRELOAD="$LIBSTDCXX"

echo "Using Python: $PYTHON"
echo "Preloading: $LD_PRELOAD"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading test PDF..."
wget -q --show-progress "https://arxiv.org/pdf/1706.03762" -O "$TMPDIR/test.pdf"

echo "Converting with Gemini LLM (--pages 1 to limit to 1 page)..."
mkdir -p "$TMPDIR/input" "$TMPDIR/output"
cp "$TMPDIR/test.pdf" "$TMPDIR/input/"

uv run --python "$PYTHON" --with marker-pdf --with psutil \
    marker "$TMPDIR/input" --output_dir "$TMPDIR/output" \
    --page_range 1 \
    --use_llm \
    --llm_service marker.services.gemini.GoogleGeminiService \
    --gemini_api_key "$GEMINI_API_KEY" 2>&1

echo "---"
echo "Check your Gemini API dashboard — if tokens were consumed, LLM is working."
