set -euo pipefail

REPORT_DIR="/var/log/security-audit"
RUN_VULNIX=false

for arg in "$@"; do
  case "$arg" in
    --with-vulnix) RUN_VULNIX=true ;;
    -h|--help)
      printf 'Usage: sudo security-audit [--with-vulnix]\n'
      printf '  --with-vulnix  also scan the system closure for known CVEs (needs network; first run is slow)\n'
      exit 0 ;;
    *)
      printf 'Unknown option: %s\n' "$arg" >&2
      exit 2 ;;
  esac
done

if [ "$(id -u)" -ne 0 ]; then
  printf 'security-audit needs root: sudo security-audit\n' >&2
  exit 1
fi

mkdir -p "$REPORT_DIR"
REPORT="$REPORT_DIR/$(date '+%Y-%m-%d_%H%M%S').log"
exec > >(tee "$REPORT") 2>&1

section() { printf '\n===== %s =====\n\n' "$1"; }

section "Lynis audit"
lynis audit system --no-colors || printf 'lynis exited with status %s\n' "$?"

section "Nix store integrity (re-hashes every store path, may take minutes)"
if nix store verify --all --no-trust; then
  printf 'All store paths verified OK against recorded hashes.\n'
else
  printf 'nix store verify reported problems -- inspect the output above.\n'
fi

section "Kernel hardening vs KSPP (failures only)"
kernel-hardening-checker -a -m show_fail || printf 'kernel-hardening-checker exited with status %s\n' "$?"

section "CPU vulnerability mitigations"
if spectre-meltdown-checker --no-color; then
  printf 'No CPU vulnerability issues reported.\n'
else
  printf 'spectre-meltdown-checker exited non-zero -- review the output above.\n'
fi

section "systemd units with exposure >= 8.0"
systemd-analyze security --no-pager | awk 'NR==1 || $2+0 >= 8.0' \
  || printf 'systemd-analyze security failed\n'

if [ "$RUN_VULNIX" = true ]; then
  section "Known CVEs in the system closure (vulnix)"
  vulnix --system \
    || printf 'vulnix exited with status %s -- findings above are heuristic (name/version matching)\n' "$?"
fi

printf '\nFull report saved to: %s\n' "$REPORT"
