#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$REPO_DIR/scripts/bootstrap.sh"

if [[ "$(uname -s)" == "Darwin" ]]; then
  bash "$REPO_DIR/mac/install.sh"
else
  "$REPO_DIR/scripts/install.sh"
  "$REPO_DIR/scripts/set-default-shell-zsh.sh" || true
fi
