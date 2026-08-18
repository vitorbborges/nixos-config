set -euo pipefail
RECIPE="$1"

# Wait for internet — 30 × 10 s = 5 minutes max
for i in $(seq 1 30); do
  if curl -sf --max-time 3 https://1.1.1.1 >/dev/null 2>&1; then
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "investments-recipe: no internet after 5 minutes, skipping $RECIPE" >&2
    exit 1
  fi
  sleep 10
done

cd "@investmentsDir@"

exec "@claudeBin@" --dangerously-skip-permissions < "$RECIPE"
