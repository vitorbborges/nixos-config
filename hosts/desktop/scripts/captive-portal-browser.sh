[ "$2" = "connectivity-change" ] || exit 0
[ "$CONNECTIVITY_STATE" = "PORTAL" ] || exit 0

uid=$(id -u "@username@")
runtime_dir="/run/user/$uid"

hyprland_pid=$(pgrep -u "@username@" -x Hyprland 2>/dev/null | head -1)
if [ -n "$hyprland_pid" ]; then
  wayland_display=$(tr '\0' '\n' < /proc/"$hyprland_pid"/environ 2>/dev/null \
    | grep ^WAYLAND_DISPLAY= | cut -d= -f2)
fi
wayland_display="${wayland_display:-wayland-1}"

runuser -u "@username@" -- \
  env XDG_RUNTIME_DIR="$runtime_dir" \
      WAYLAND_DISPLAY="$wayland_display" \
      DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime_dir/bus" \
      xdg-open "http://neverssl.com" &
