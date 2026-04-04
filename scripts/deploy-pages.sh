#!/usr/bin/env bash
# Build and deploy to the gh-pages branch for GitHub Pages.
#
# Usage: ./scripts/deploy-pages.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Build into docs/
"$REPO_ROOT/scripts/build-pages.sh"

# Add CNAME for custom domain
echo "www.the-fool-and-his-money.com" > "$REPO_ROOT/docs/CNAME"

# Push docs/ contents to gh-pages branch via a temporary repo
DEPLOY_DIR="$(mktemp -d)"
trap 'rm -rf "$DEPLOY_DIR"' EXIT

cp -r "$REPO_ROOT/docs/." "$DEPLOY_DIR/"
REMOTE_URL=$(git -C "$REPO_ROOT" remote get-url origin)

cd "$DEPLOY_DIR"
git init -q
git add -A
git commit -q -m "Deploy to GitHub Pages"
git push -f "$REMOTE_URL" HEAD:gh-pages

echo "Deployed to gh-pages branch."
