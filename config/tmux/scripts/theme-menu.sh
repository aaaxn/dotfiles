#!/usr/bin/env bash
set -euo pipefail

apply_script="$HOME/.config/tmux/scripts/theme-apply.sh"
current_theme="$(tmux show-option -gqv @selected_tmux_theme 2>/dev/null || true)"

label() {
  local theme="$1"
  local name="$2"
  if [ "$current_theme" = "$theme" ]; then
    printf '[x] %s' "$name"
  else
    printf '[ ] %s' "$name"
  fi
}

tmux display-menu -T "Tmux Themes" -x R -y P \
  "$(label catppuccin Catppuccin)" c "run-shell \"$apply_script catppuccin\"" \
  "$(label tokyo-night Tokyo Night)" t "run-shell \"$apply_script tokyo-night\"" \
  "$(label nord Nord)" n "run-shell \"$apply_script nord\"" \
  "$(label ukiyo Ukiyo)" u "run-shell \"$apply_script ukiyo\""
