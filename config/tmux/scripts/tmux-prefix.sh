#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  alt|a)   key=M-e; send=e;   label="Alt+e"  ;;
  ctrl|c)  key=C-e; send=C-e; label="Ctrl+e" ;;
  show|s)
    echo "$(tmux show -gqv prefix 2>/dev/null || echo M-e)"
    exit 0 ;;
  *)
    echo "Usage: tmux-prefix <alt|ctrl|show>"
    exit 1 ;;
esac

# Apply live
tmux unbind e   2>/dev/null || true
tmux unbind C-e 2>/dev/null || true
tmux set -g prefix "$key"
tmux bind "$send" send-prefix
tmux display-message "Prefix → $label"

# Persist for next session
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/tmux"
mkdir -p "$state_dir"
cat > "$state_dir/prefix.conf" <<EOF
set -g prefix $key
bind $send send-prefix
EOF
