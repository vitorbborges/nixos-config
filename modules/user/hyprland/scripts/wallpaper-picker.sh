#!/usr/bin/env bash
# Wallpaper picker — fzf with kitty image protocol preview
# Runs inside a floating kitty window; select to apply via wallpaper-switch.
WALLPAPER_DIR="$HOME/Media/Pictures/Wallpapers"

# shellcheck disable=SC2016  # fzf evaluates the preview string itself — single quotes are intentional
selection=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
  | sort \
  | fzf \
      --preview 'kitten icat --clear --transfer-mode=memory --stdin=no --place="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0" {}' \
      --preview-window='right:70%,border-left' \
      --prompt='󰋩  Wallpaper › ' \
      --border=rounded \
      --height=100% \
      --layout=reverse)

[[ -n "$selection" ]] && wallpaper-switch "$selection"
