WALLPAPER="${1:-}"
NIXOS_CONFIG="$HOME/nixos-config"
WALLPAPER_NIX="$NIXOS_CONFIG/modules/user/stylix/wallpaper.nix"

if [[ -z "$WALLPAPER" ]]; then
  echo "Usage: wallpaper-switch <path-to-image>"
  exit 1
fi

if [[ ! -f "$WALLPAPER" ]]; then
  echo "Error: file not found: $WALLPAPER"
  exit 1
fi

WALLPAPER_ABS="$(realpath "$WALLPAPER")"
echo "Setting wallpaper: $WALLPAPER_ABS"

# 1. Set wallpaper immediately via hyprpaper IPC
hyprctl hyprpaper preload "$WALLPAPER_ABS"
hyprctl hyprpaper wallpaper ",$WALLPAPER_ABS"
echo "Wallpaper set immediately"

# 2. Extract accent colors with matugen and update hyprland borders instantly
if command -v matugen &>/dev/null; then
  COLORS=$(matugen image "$WALLPAPER_ABS" --json 2>/dev/null || echo "{}")
  PRIMARY=$(echo "$COLORS" | jq -r '.colors.dark.primary // empty' 2>/dev/null || echo "")
  SECONDARY=$(echo "$COLORS" | jq -r '.colors.dark.secondary // empty' 2>/dev/null || echo "")

  if [[ -n "$PRIMARY" ]]; then
    P="${PRIMARY#\#}"
    S="${SECONDARY:-$PRIMARY}"
    S="${S#\#}"
    hyprctl keyword general:col.active_border   "rgba(${P}ff) rgba(${S}ff) 45deg" 2>/dev/null || true
    hyprctl keyword general:col.inactive_border "rgba(${S}33)" 2>/dev/null || true
    echo "Hyprland borders updated instantly"
  fi
fi

# 3. Overwrite wallpaper.nix with new path (drives stylix colorscheme on rebuild)
cat > "$WALLPAPER_NIX" << NIXEOF
# Managed by wallpaper-switch script — do not edit manually
{ ... }:
{
  stylix.image = $WALLPAPER_ABS;
}
NIXEOF
echo "wallpaper.nix updated"

# 4. Rebuild silently in background — full theme applied when done
echo "Rebuilding NixOS config in background..."
(
  # SC2024: redirect to /tmp is intentional (written as current user, not root)
  # shellcheck disable=SC2024
  if sudo nixos-rebuild switch --flake "$NIXOS_CONFIG" &>/tmp/nixos-rebuild.log; then
    notify-send "Theme updated" "Full colorscheme applied system-wide"
  else
    notify-send "Theme rebuild failed" "Check /tmp/nixos-rebuild.log for details"
  fi
) &

echo "Done — colors will propagate fully after rebuild (~1-2 min)"
