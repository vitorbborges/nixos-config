#!/usr/bin/env bash
# Bumps modules/user/office/gridcraft.nix to the latest GitHub release.
# Usage: ./update-gridcraft.sh && sudo nixos-rebuild switch --flake ~/nixos-config#desktop
set -euo pipefail
cd "$(dirname "$0")"

latest=$(curl -fsSL https://api.github.com/repos/storytold/gridcraft/releases/latest \
  | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')

if [ -z "$latest" ]; then
  echo "error: could not determine latest release" >&2
  exit 1
fi

current=$(sed -n 's/.*version = "\([^"]*\)";.*/\1/p' gridcraft.nix | head -1)

if [ "$latest" = "$current" ]; then
  echo "gridcraft $current is already current"
  exit 0
fi

url="https://github.com/storytold/gridcraft/releases/download/v${latest}/gridcraft-${latest}-linux-x86_64.deb"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/gridcraft.deb" "$url"
hash=$(nix hash file --type sha256 --sri "$tmp/gridcraft.deb")

sed -i "s/version = \"$current\";/version = \"$latest\";/" gridcraft.nix
sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"$hash\";|" gridcraft.nix

echo "gridcraft $current -> $latest"
echo "rebuild with: sudo nixos-rebuild switch --flake ~/nixos-config#desktop"
