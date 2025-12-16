#!/usr/bin/env bash

set -euo pipefail

# Source home-manager environment
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi

CONFIG_DIR="/home/vitor/nixos-config"
ACTIVITYWATCH_NIX_FILE="${CONFIG_DIR}/modules/user/activitywatch/activitywatch.nix"
EVENTS_FILE=$(mktemp --suffix=.json)
trap 'rm -f "$EVENTS_FILE"' EXIT

HOSTNAME=$(hostname)
BUCKET_ID="aw-watcher-window_${HOSTNAME}"
START_DATE=$(date -d "24 hours ago" -u +"%Y-%m-%dT%H:%M:%SZ")
END_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "Fetching ActivityWatch events from the last 24 hours..."
if ! curl -s "http://127.0.0.1:5600/api/0/buckets/${BUCKET_ID}/events?start=${START_DATE}&end=${END_DATE}" > "$EVENTS_FILE"; then
    echo "Error: Failed to fetch events from ActivityWatch server." >&2
    exit 1
fi

if [ ! -s "$EVENTS_FILE" ]; then
    echo "No events found in the last 24 hours."
    exit 0
fi

echo "Found events, saved to ${EVENTS_FILE}"

PROMPT="Please update my ActivityWatch filter list in '${ACTIVITYWATCH_NIX_FILE}' based on the unclassified activities from the last 24 hours. The events are in '${EVENTS_FILE}'. Analyze the events, identify unclassified activities (those not categorized as 'Work', 'Study', 'Leisure', 'Media', or 'Comm'), and add new filter rules to the existing configuration to classify them. Use your best judgment to categorize them and create general rules where possible."

copilot -p "$PROMPT"

echo "Filter update process completed."