#!/bin/bash
set -euo pipefail

echo "🔄 Fetching latest remote history..."
git fetch --all --all --prune

# Store the current branch to return to later
INIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📍 Starting from branch: $INIT_BRANCH"

# Try to stash any local changes (tracked + untracked), quietly
echo "📦 Stashing local changes (if any)..."
if git stash push -u -m "pre-rewrite-backup" >/dev/null 2>&1; then
    STASHED=true
else
    STASHED=false
fi

# Reset each local branch to match its remote
echo "🧹 Resetting all local branches to their origin counterparts..."
for BRANCH in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
    echo "➡️  Resetting $BRANCH"
    git checkout "$BRANCH"
    git reset --hard "origin/$BRANCH"
done

# Return to the starting branch
git checkout "$INIT_BRANCH"
echo "🔙 Returned to original branch: $INIT_BRANCH"

# Restore stash only if we created one
if [ "$STASHED" = true ] && git stash list | grep -q "pre-rewrite-backup"; then
    echo "📥 Restoring stashed changes..."
    git stash pop
else
    echo "✅ No stash to restore."
fi

# Cleanup old history
git gc --prune=now
echo "🧼 Garbage collection complete."

echo "✅ Local branches reset to rewritten history and cleaned up."
