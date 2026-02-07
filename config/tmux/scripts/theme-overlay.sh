#!/usr/bin/env bash
set -euo pipefail

window_text='#(~/.config/tmux/scripts/git-status.sh "#{window_id}")'

# Keep Catppuccin wired to the same custom window text.
tmux set-option -gq @catppuccin_window_text "$window_text"
tmux set-option -gq @catppuccin_window_current_text "$window_text"

patch_window_format() {
  local opt_name="$1"
  local current

  current="$(tmux show-option -gqv "$opt_name" 2>/dev/null || true)"
  [ -z "$current" ] && return 0

  # Already patched for custom script text.
  if [[ "$current" == *"git-status.sh"* ]]; then
    return 0
  fi

  # Most themes expose #W in both current and inactive formats.
  if [[ "$current" == *"#W"* ]]; then
    local patched="${current//\#W/$window_text}"
    tmux set-option -gq "$opt_name" "$patched"
  fi
}

patch_window_format "window-status-format"
patch_window_format "window-status-current-format"
