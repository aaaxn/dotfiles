#!/usr/bin/env bash
set -euo pipefail

theme="$(tmux show-option -gqv @selected_tmux_theme 2>/dev/null || true)"
if [ -z "$theme" ]; then
  theme="catppuccin"
fi

repo_base="$HOME/.config/tmux/themes/repos"
entry_file=""

case "$theme" in
  catppuccin)
    entry_file="$repo_base/catppuccin-tmux/catppuccin.tmux"
    ;;
  tokyo-night)
    entry_file="$repo_base/tokyo-night-tmux/tokyo-night.tmux"
    ;;
  nord)
    entry_file="$repo_base/nord-tmux/nord.tmux"
    ;;
  ukiyo)
    entry_file="$repo_base/tmux-ukiyo/scripts/ukiyo.sh"
    ;;
  *)
    tmux display-message "Tema desconhecido: $theme"
    exit 0
    ;;
esac

if [ -f "$entry_file" ]; then
  # All selected themes provide shell entrypoints (not plain tmux config files).
  # Running them directly keeps compatibility with each project's loader model.
  if [ "$theme" = "ukiyo" ]; then
    # Compatibility for tmux 3.4+: ukiyo.tmux sets an invalid env var name.
    tmux set-option -gq @ukiyo-root "$repo_base/tmux-ukiyo"
  fi
  "$entry_file"
else
  tmux display-message "Tema '$theme' ainda nao instalado. Use prefix+T para instalar/aplicar."
fi
