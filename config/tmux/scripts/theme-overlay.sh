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

apply_pane_background() {
  local selected_theme tokyo_theme tokyo_transparent
  selected_theme="$(tmux show-option -gqv @selected_tmux_theme 2>/dev/null || true)"

  case "$selected_theme" in
    catppuccin)
      tmux set-option -gqF window-style "fg=#{?@thm_fg,#{@thm_fg},#cdd6f4},bg=#{?@thm_bg,#{@thm_bg},#1e1e2e}"
      tmux set-option -gqF window-active-style "fg=#{?@thm_fg,#{@thm_fg},#cdd6f4},bg=#{?@thm_bg,#{@thm_bg},#1e1e2e}"
      ;;
    tokyo-night)
      tokyo_theme="$(tmux show-option -gqv @tokyo-night-tmux_theme 2>/dev/null || true)"
      tokyo_transparent="$(tmux show-option -gqv @tokyo-night-tmux_transparent 2>/dev/null || true)"

      if [[ "$tokyo_transparent" == "1" ]]; then
        tmux set-option -gq window-style "fg=#a9b1d6,bg=default"
        tmux set-option -gq window-active-style "fg=#a9b1d6,bg=default"
        return 0
      fi

      case "$tokyo_theme" in
        storm)
          tmux set-option -gq window-style "fg=#a9b1d6,bg=#24283b"
          tmux set-option -gq window-active-style "fg=#c0caf5,bg=#2a2f45"
          ;;
        day)
          tmux set-option -gq window-style "fg=#343b58,bg=#d5d6db"
          tmux set-option -gq window-active-style "fg=#1f2335,bg=#c8cad1"
          ;;
        *)
          tmux set-option -gq window-style "fg=#a9b1d6,bg=#1A1B26"
          tmux set-option -gq window-active-style "fg=#c0caf5,bg=#1f2335"
          ;;
      esac
      ;;
    nord)
      tmux set-option -gq window-style "fg=#D8DEE9,bg=#2E3440"
      tmux set-option -gq window-active-style "fg=#ECEFF4,bg=#3B4252"
      ;;
    ukiyo)
      # Ukiyo already sets window-style from its own palette. Mirror it to active style.
      local current_style
      current_style="$(tmux show-option -gqv window-style 2>/dev/null || true)"
      if [[ -n "$current_style" ]]; then
        tmux set-option -gq window-active-style "$current_style"
      fi
      ;;
  esac
}

apply_pane_background
