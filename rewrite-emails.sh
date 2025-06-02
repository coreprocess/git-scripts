#!/bin/bash
set -euo pipefail

# --- Input validation ---
if [ $# -ne 1 ]; then
    echo "Usage: $0 <git-repository-url>"
    exit 1
fi

REPO_URL="$1"
MAILMAP_FILE="email-mapping.txt"

# --- Safety checks ---
if ! command -v git-filter-repo > /dev/null 2>&1; then
    echo "❌ git-filter-repo is not installed. Install it with: pip install git-filter-repo"
    exit 1
fi

if [ ! -f "$MAILMAP_FILE" ]; then
    echo "❌ Required file $MAILMAP_FILE not found in current directory."
    exit 1
fi

# --- Extract repo name ---
REPO_NAME=$(basename -s .git "$REPO_URL")

# --- Create backup clone ---
echo "🔒 Creating mirror backup of $REPO_URL..."
git clone --mirror "$REPO_URL" "${REPO_NAME}-backup.git"

# --- Create working clone ---
echo "🛠️  Cloning working copy for rewriting..."
git clone --mirror "$REPO_URL" "${REPO_NAME}-rewrite.git"

cd "${REPO_NAME}-rewrite.git"

# --- Rewrite history using mailmap ---
echo "✍️  Rewriting history using $MAILMAP_FILE..."
git filter-repo --mailmap "../$MAILMAP_FILE"

# --- Force-push rewritten history ---
echo "🚀 Force-pushing rewritten history to origin..."
git remote set-url origin "$REPO_URL"
git push --mirror --force

echo "✅ Rewrite complete. Backup saved in ${REPO_NAME}-backup.git"
