#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Phase 1: Bootstrap dependencies ─────────────────────────────────────────
"$REPO_DIR/scripts/bootstrap.sh"

# Ensure stow is available
if ! command -v stow >/dev/null 2>&1; then
  echo "Installing stow..."
  if command -v brew >/dev/null 2>&1; then
    brew install stow
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y stow
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm stow
  else
    echo "Please install GNU Stow manually" >&2
    exit 1
  fi
fi

STOW_OPTS=("--target=$HOME" "--restow" "--verbose=1")

# Remove old ~/.tmux.conf shim if it exists (no longer needed)
[[ -L "$HOME/.tmux.conf" ]] && rm "$HOME/.tmux.conf"

# Remove old ~/.gitconfig symlink (now at ~/.config/git/config)
[[ -L "$HOME/.gitconfig" ]] && rm "$HOME/.gitconfig"

# ── Phase 2: Stow cross-platform packages ───────────────────────────────────
cross_platform=(zsh git tmux starship gitmux codex)

for pkg in "${cross_platform[@]}"; do
  echo "Stowing: $pkg"
  stow "${STOW_OPTS[@]}" -d "$REPO_DIR" "$pkg"
done

# ── Phase 3: macOS-specific ─────────────────────────────────────────────────
if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Installing macOS brew packages..."
  brew install starship zsh-autosuggestions zsh-autocomplete
  brew tap nikitabobko/tap
  brew install nikitabobko/tap/aerospace
  brew install --cask ghostty
  brew install --cask karabiner-elements

  mac_packages=(aerospace ghostty karabiner)
  for pkg in "${mac_packages[@]}"; do
    echo "Stowing: $pkg"
    stow "${STOW_OPTS[@]}" -d "$REPO_DIR" "$pkg"
  done
fi

# ── Phase 4: Linux-specific ─────────────────────────────────────────────────
if [[ "$(uname -s)" != "Darwin" ]]; then
  "$REPO_DIR/scripts/set-default-shell-zsh.sh" || true
fi

echo "Done."
