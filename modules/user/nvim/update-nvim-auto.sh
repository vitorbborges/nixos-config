#!/usr/bin/env bash
# Automated script to update neovim config to latest commit with correct hash

set -e

echo "🔄 Fetching latest commit from nvim-config repo..."

# Get latest commit hash
LATEST_COMMIT=$(gh api repos/vitorbborges/nvim-config/commits/main --jq .sha)
echo "📝 Latest commit: $LATEST_COMMIT"

echo "🔍 Calculating hash for new commit..."

# Get the correct hash using nix-prefetch-github
CORRECT_HASH=$(nix-prefetch-github vitorbborges nvim-config --rev "$LATEST_COMMIT" | jq -r .sha256)

echo "🔐 Hash: $CORRECT_HASH"

# Update nvim.nix with new commit and hash
sed -i "s/rev = \"[a-f0-9]*\"/rev = \"$LATEST_COMMIT\"/" ./nvim.nix
sed -i "s/# Updated: [0-9-]*/# Updated: $(date +%Y-%m-%d)/" ./nvim.nix
sed -i "s/hash = \"sha256-[A-Za-z0-9+/=]*\"/hash = \"sha256-$CORRECT_HASH\"/" ./nvim.nix

echo "✅ Updated nvim.nix with latest commit and correct hash"
echo "🏗️  Applying changes..."

# Apply the changes
cd ../../../
home-manager switch --flake .#vitorbborges

echo "🎉 Neovim config updated successfully!"