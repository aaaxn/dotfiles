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

selected_theme="$(tmux show-option -gqv @selected_tmux_theme 2>/dev/null || true)"

if [ "$selected_theme" = "catppuccin" ]; then
  # Build Catppuccin modules after theme load so tmux-cpu can interpolate status-right.
  tmux set-option -gq status-right ""
  tmux set-option -agF status-right "#{@catppuccin_status_gitmux}"
  tmux set-option -agq status-right " "
  tmux set-option -agF status-right "#{E:@catppuccin_status_cpu}"
fi

# Prevent pane background color from leaking between themes.
# Status bar and window tabs remain controlled by each theme.
tmux set-window-option -gu window-style 2>/dev/null || true
tmux set-window-option -gu window-active-style 2>/dev/null || true
