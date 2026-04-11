#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/$2"
  mkdir -p "$(dirname "$dst")"
  [[ -d "$dst" && ! -L "$dst" ]] && mv "$dst" "$dst.bak.$(date +%s)"
  ln -sfn "$src" "$dst"
  echo "linked: $dst"
}

# ── Phase 1: Bootstrap ───────────────────────────────────────────────────────
"$DOTFILES/scripts/bootstrap.sh"

# Clean up old stow-era symlinks
[[ -L "$HOME/.tmux.conf" ]] && rm "$HOME/.tmux.conf"
[[ -L "$HOME/.gitconfig" ]] && rm "$HOME/.gitconfig"

# ── Phase 2: Cross-platform symlinks ─────────────────────────────────────────

# tmux — safe to link as a whole dir (no app-managed files inside)
link ".config/tmux" ".config/tmux"

# git — link just config; ignore and other files may exist alongside it
link ".config/git/config" ".config/git/config"

# zsh — ZDOTDIR points here; link the whole dir
link ".config/zsh" ".config/zsh"

# .zshenv must live at ~/ (zsh reads it before ZDOTDIR is set)
link ".zshenv" ".zshenv"

link ".config/starship.toml" ".config/starship.toml"
link ".config/gitmux/.gitmux.conf" ".gitmux.conf"


# ── Phase 3: macOS-specific ──────────────────────────────────────────────────
if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Installing macOS packages..."
  brew install starship
  brew tap nikitabobko/tap
  brew install nikitabobko/tap/aerospace
  brew install --cask ghostty karabiner-elements

  link ".config/aerospace" ".config/aerospace"
  link ".config/ghostty"   ".config/ghostty"
  link ".config/karabiner" ".config/karabiner"
fi

# ── Phase 4: Linux-specific ──────────────────────────────────────────────────
if [[ "$(uname -s)" != "Darwin" ]]; then
  "$DOTFILES/scripts/set-default-shell-zsh.sh" || true
fi

echo "Done."
