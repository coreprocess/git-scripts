#!/bin/bash
set -euo pipefail

# --- Config ---
MAPPING_FILE="email-mapping.txt"

# --- Input validation ---
if [ $# -ne 1 ]; then
    echo "Usage: $0 <git-repo-url>"
    exit 1
fi

REPO_URL="$1"

# --- Setup ---
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning $REPO_URL into temporary directory..."
git clone --mirror "$REPO_URL" "$TMP_DIR/repo.git" > /dev/null 2>&1 || {
    echo "❌ Failed to clone repository."
    exit 1
}

cd "$TMP_DIR/repo.git"

# --- Collect all unique identities (author + committer) ---
echo "Collecting unique author and committer identities..."
ALL_IDENTITIES=$(mktemp)

{
    git log --all --pretty=format:'%an <%ae>'; echo;
    git log --all --pretty=format:'%cn <%ce>'; echo;
} | sort | uniq > "$ALL_IDENTITIES"

# --- Load existing mappings (collect old emails already mapped) ---
EXISTING_EMAILS=$(mktemp)

if [ -f "$OLDPWD/$MAPPING_FILE" ]; then
    echo "Reading existing entries from $MAPPING_FILE..."
    awk '{ print $NF }' "$OLDPWD/$MAPPING_FILE" | sort > "$EXISTING_EMAILS"
else
    echo "No existing $MAPPING_FILE found. Creating a new one."
    touch "$OLDPWD/$MAPPING_FILE"
    > "$EXISTING_EMAILS"
fi

# --- Append missing identities ---
echo "Appending missing identities to $MAPPING_FILE..."
while IFS= read -r identity; do
    email=$(echo "$identity" | sed -n 's/.*<\(.*\)>/\1/p')
    if ! grep -Fxq "<$email>" "$EXISTING_EMAILS"; then
        echo "$identity <$email>" >> "$OLDPWD/$MAPPING_FILE"
    fi
done < "$ALL_IDENTITIES"

echo "✅ Done. Updated $MAPPING_FILE with any new identities found."
