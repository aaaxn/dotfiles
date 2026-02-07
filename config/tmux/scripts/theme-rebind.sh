#!/usr/bin/env bash
set -euo pipefail

tmux unbind-key T 2>/dev/null || true
tmux bind-key T run-shell "$HOME/.config/tmux/scripts/theme-menu.sh"
