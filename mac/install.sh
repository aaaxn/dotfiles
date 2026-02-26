#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAC_DIR="$REPO_DIR/mac"
BACKUP_DIR=""

log() { printf "%s\n" "$*"; }

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

log "Installing dotfiles (mac) from: $REPO_DIR"

# ── Homebrew packages ─────────────────────────────────────────────────────────
log "Installing brew packages..."

brew install starship zsh-autosuggestions zsh-autocomplete

brew tap nikitabobko/tap
brew install nikitabobko/tap/aerospace

brew tap felixkratz/formulae
brew install felixkratz/formulae/sketchybar

brew install --cask ghostty
brew install --cask karabiner-elements


# ── Cross-platform ────────────────────────────────────────────────────────────
link_item "$REPO_DIR/home/.zshenv"          "$HOME/.zshenv"
link_item "$REPO_DIR/home/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
link_item "$REPO_DIR/home/.tmux.conf"       "$HOME/.tmux.conf"
link_item "$REPO_DIR/home/.gitmux.conf"     "$HOME/.gitmux.conf"
link_item "$REPO_DIR/home/.gitconfig"       "$HOME/.gitconfig"
link_item "$REPO_DIR/config/starship.toml"  "$HOME/.config/starship.toml"
link_item "$REPO_DIR/config/tmux"           "$HOME/.config/tmux"
link_item "$REPO_DIR/config/zsh/conf.d"     "$HOME/.config/zsh/conf.d"

# ── Mac-specific ──────────────────────────────────────────────────────────────
link_item "$MAC_DIR/home/.zshrc"            "$HOME/.zshrc"
link_item "$MAC_DIR/home/.zprofile"         "$HOME/.zprofile"
link_item "$MAC_DIR/config/aerospace.toml"  "$HOME/.aerospace.toml"
link_item "$MAC_DIR/config/sketchybar"      "$HOME/.config/sketchybar"
link_item "$MAC_DIR/config/ghostty"         "$HOME/.config/ghostty"
link_item "$MAC_DIR/config/karabiner"       "$HOME/.config/karabiner"

log "Done."
if [[ -n "$BACKUP_DIR" ]]; then
  log "Backups stored in: $BACKUP_DIR"
fi
