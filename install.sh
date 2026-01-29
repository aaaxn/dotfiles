#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR=""

log() {
  printf "%s\n" "$*"
}

ensure_backup_dir() {
  if [[ -z "$BACKUP_DIR" ]]; then
    BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
  fi
}

same_link() {
  local src="$1" dest="$2"
  [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]
}

backup_if_needed() {
  local dest="$1"
  if [[ -e "$dest" || -L "$dest" ]]; then
    ensure_backup_dir
    local target="$BACKUP_DIR$dest"
    mkdir -p "$(dirname "$target")"
    mv "$dest" "$target"
    log "Backup: $dest -> $target"
  fi
}

link_item() {
  local src="$1" dest="$2"

  if same_link "$src" "$dest"; then
    log "OK: $dest already linked"
    return
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    backup_if_needed "$dest"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  log "Link: $dest -> $src"
}

log "Installing dotfiles from: $REPO_DIR"

# Base files
link_item "$REPO_DIR/.zshrc" "$HOME/.zshrc"
link_item "$REPO_DIR/.zshenv" "$HOME/.zshenv"
link_item "$REPO_DIR/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
link_item "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
link_item "$REPO_DIR/.gitconfig" "$HOME/.gitconfig"

# Config directories
link_item "$REPO_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
link_item "$REPO_DIR/.config/tmux" "$HOME/.config/tmux"

log "Done."
if [[ -n "$BACKUP_DIR" ]]; then
  log "Backups stored in: $BACKUP_DIR"
fi
