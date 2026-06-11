#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/$2"
  local backup=""
  local current_target=""

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    current_target="$(readlink "$dst")"
    if [[ "$current_target" == "$src" ]]; then
      echo "linked: $dst"
      return
    fi
  elif [[ -e "$dst" ]]; then
    backup="$dst.bak.$(date +%s)"
    mv "$dst" "$backup"
    echo "backed up: $dst -> $backup"
  fi

  ln -sfn "$src" "$dst"
  echo "linked: $dst"
}

# ── Phase 1: Bootstrap ───────────────────────────────────────────────────────
"$DOTFILES/scripts/bootstrap.sh"

# Clean up stale generated zsh artifacts kept inside the repo from older layouts
rm -f "$DOTFILES/.config/zsh/.zcompdump"*
rm -f "$DOTFILES/.config/zsh/.zsh_history"

# Clean up stale symlinks from previous layouts
for _old in "$HOME/.tmux.conf" "$HOME/.gitconfig" \
            "$HOME/.config/starship.toml" "$HOME/.config/git/config" \
            "$HOME/.claude/keybindings.json" "$HOME/.claude/settings.json" \
            "$HOME/.claude/statusline-command.sh" \
            "$HOME/.claude/skills/ruff" "$HOME/.claude/skills/ty" "$HOME/.claude/skills/uv" \
            "$HOME/.claude/skills/ast-grep" "$HOME/.claude/skills/grill-me" \
            "$HOME/.codex/config.toml" \
            "$HOME/.agents/skills/ast-grep" "$HOME/.agents/skills/grill-me"; do
  [[ -L "$_old" ]] && rm "$_old"
done
unset _old

# ── Phase 2: Cross-platform symlinks ─────────────────────────────────────────

# tmux — safe to link as a whole dir (no app-managed files inside)
link ".config/tmux" ".config/tmux"

# zsh — ZDOTDIR points here; link the whole dir
link ".config/zsh" ".config/zsh"

# .zshenv must live at ~/ (zsh reads it before ZDOTDIR is set)
link ".zshenv" ".zshenv"

link ".config/gitmux/.gitmux.conf" ".gitmux.conf"


# ── Phase 3: macOS-specific ──────────────────────────────────────────────────
if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Installing macOS packages..."
  # skip apps that are already present, whether installed via brew or manually
  if [[ ! -d /Applications/AeroSpace.app ]] && ! brew list aerospace &>/dev/null; then
    brew tap nikitabobko/tap
    brew install nikitabobko/tap/aerospace
  fi
  if [[ ! -d /Applications/Ghostty.app ]] && ! brew list --cask ghostty &>/dev/null; then
    brew install --cask ghostty
  fi
  if [[ ! -d /Applications/Karabiner-Elements.app ]] && ! brew list --cask karabiner-elements &>/dev/null; then
    brew install --cask karabiner-elements
  fi

  link ".config/aerospace" ".config/aerospace"
  link ".config/ghostty"   ".config/ghostty"
  link ".config/karabiner" ".config/karabiner"

  # AeroSpace prefers ~/.aerospace.toml over ~/.config/aerospace — move a
  # stale copy out of the way so the linked config wins
  if [[ -f "$HOME/.aerospace.toml" && ! -L "$HOME/.aerospace.toml" ]]; then
    mv "$HOME/.aerospace.toml" "$HOME/.aerospace.toml.bak.$(date +%s)"
    echo "backed up: $HOME/.aerospace.toml (superseded by ~/.config/aerospace)"
  fi
fi

# ── Phase 4: Linux-specific ──────────────────────────────────────────────────
if [[ "$(uname -s)" != "Darwin" ]]; then
  "$DOTFILES/scripts/set-default-shell-zsh.sh" || true
fi

echo "Done."
