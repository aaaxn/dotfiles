#!/usr/bin/env bash
set -euo pipefail

theme="${1:-}"
case "$theme" in
  catppuccin|tokyo-night|nord) ;;
  *)
    tmux display-message "Tema invalido: '$theme'"
    exit 1
    ;;
esac

repo_base="$HOME/.config/tmux/themes/repos"
state_file="$HOME/.config/tmux/theme-state.conf"
config_file="$HOME/.config/tmux/tmux.conf"

repo_url=""
repo_dir=""
entry_file=""

case "$theme" in
  catppuccin)
    repo_url="https://github.com/catppuccin/tmux.git"
    repo_dir="$repo_base/catppuccin-tmux"
    entry_file="$repo_dir/catppuccin.tmux"
    ;;
  tokyo-night)
    repo_url="https://github.com/janoamaral/tokyo-night-tmux.git"
    repo_dir="$repo_base/tokyo-night-tmux"
    entry_file="$repo_dir/tokyo-night.tmux"
    ;;
  nord)
    repo_url="https://github.com/arcticicestudio/nord-tmux.git"
    repo_dir="$repo_base/nord-tmux"
    entry_file="$repo_dir/nord.tmux"
    ;;
esac

mkdir -p "$repo_base"

if [ ! -f "$entry_file" ]; then
  if [ -d "$repo_dir/.git" ]; then
    tmux display-message "Tema '$theme' parece incompleto em: $repo_dir"
    exit 1
  fi

  if ! git clone --depth 1 "$repo_url" "$repo_dir" >/dev/null 2>&1; then
    tmux display-message "Falha ao baixar tema: $theme"
    exit 1
  fi
fi

cat > "$state_file" <<EOF_STATE
# Auto-generated. Do not edit manually unless needed.
set -g @selected_tmux_theme "$theme"
EOF_STATE

tmux set -g @selected_tmux_theme "$theme"
tmux source-file "$config_file"
tmux display-message "Tema aplicado: $theme"
