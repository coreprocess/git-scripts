#!/bin/bash

set -euo pipefail

# Check for exactly two arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source_repo_url> <destination_repo_url>" >&2
  exit 1
fi

SOURCE_REPO="$1"
DEST_REPO="$2"

# Create a temporary directory
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning from source: $SOURCE_REPO"
git clone --mirror "$SOURCE_REPO" "$TMP_DIR/repo.git"

cd "$TMP_DIR/repo.git"

echo "Pushing to destination: $DEST_REPO"
git push --mirror "$DEST_REPO"

echo "Repository successfully mirrored."
