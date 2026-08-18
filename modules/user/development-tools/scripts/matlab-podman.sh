#!/usr/bin/env bash
exec > /tmp/matlab-launch.log 2>&1
echo "Starting at $(date)"
export DISPLAY=:0
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
echo "XAUTHORITY=$XAUTHORITY"
podman start matlab-box 2>&1
echo "Container start exit: $?"
sleep 1
exec podman exec \
  -e DISPLAY=:0 \
  -e XAUTHORITY="$XAUTHORITY" \
  -e WAYLAND_DISPLAY= \
  -e QT_QPA_PLATFORM=xcb \
  -e HOME=/home/vitor \
  -e USER=vitor \
  matlab-box \
  /home/vitor/MATLAB/R2026a/bin/matlab -desktop "$@"
