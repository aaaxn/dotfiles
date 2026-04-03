#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/$2"
  mkdir -p "$(dirname "$dst")"
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

# zsh — link subdirs; ~/.config/zsh itself may contain other things
link ".config/zsh/conf.d"     ".config/zsh/conf.d"
link ".config/zsh/platform.d" ".config/zsh/platform.d"

link ".config/starship.toml" ".config/starship.toml"

# claude + codex — real app dirs; link only the config files we own
link ".claude/keybindings.json"      ".claude/keybindings.json"
link ".claude/settings.json"         ".claude/settings.json"
link ".claude/statusline-command.sh" ".claude/statusline-command.sh"
link ".codex/config.toml"            ".codex/config.toml"

link ".gitmux.conf"     ".gitmux.conf"
link ".zshrc"           ".zshrc"
link ".zprofile"        ".zprofile"
link ".zshenv"          ".zshenv"
link ".zsh_plugins.txt" ".zsh_plugins.txt"

# ── Phase 3: macOS-specific ──────────────────────────────────────────────────
if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Installing macOS packages..."
  brew install starship zsh-autosuggestions zsh-autocomplete
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
