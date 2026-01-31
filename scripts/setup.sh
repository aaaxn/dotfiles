#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/bootstrap.sh"
"$SCRIPT_DIR/install.sh"
# Best-effort: changing login shell can fail (permissions/TTY) and shouldn't block the setup.
"$SCRIPT_DIR/set-default-shell-zsh.sh" || true
