#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$REPO_DIR/scripts/bootstrap.sh"
"$REPO_DIR/scripts/install.sh"
# Best-effort: changing login shell can fail (permissions/TTY) and shouldn't block the setup.
"$REPO_DIR/scripts/set-default-shell-zsh.sh" || true
