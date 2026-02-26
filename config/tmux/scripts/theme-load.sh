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
  *)
    tmux display-message "Tema desconhecido: $theme"
    exit 0
    ;;
esac

if [ -f "$entry_file" ]; then
  # All selected themes provide shell entrypoints (not plain tmux config files).
  # Running them directly keeps compatibility with each project's loader model.
  "$entry_file"
else
  tmux display-message "Tema '$theme' ainda nao instalado. Use prefix+T para instalar/aplicar."
fi
