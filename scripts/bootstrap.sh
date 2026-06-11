#!/usr/bin/env bash
set -euo pipefail

log() { printf "%s\n" "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

maybe_eval_brew_shellenv() {
  if need_cmd brew; then
    eval "$(brew shellenv)"
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_homebrew() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "Skipping Homebrew installation on non-macOS"
    return 0
  fi

  if need_cmd brew; then
    log "homebrew already installed"
    return
  fi

  if ! need_cmd curl; then
    log "curl not found; cannot install homebrew"
    return 1
  fi

  log "Installing homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  maybe_eval_brew_shellenv

  if need_cmd brew; then
    log "homebrew installed"
  else
    log "homebrew installation finished, but brew is not in PATH yet"
  fi
}

select_system_pm() {
  if need_cmd apt-get; then
    echo "apt-get"
  elif need_cmd dnf; then
    echo "dnf"
  elif need_cmd yum; then
    echo "yum"
  elif need_cmd pacman; then
    echo "pacman"
  elif need_cmd apk; then
    echo "apk"
  elif need_cmd zypper; then
    echo "zypper"
  else
    return 1
  fi
}

select_pm() {
  if [[ -n "${DOTFILES_PM:-}" ]]; then
    echo "$DOTFILES_PM"
    return 0
  fi

  if need_cmd brew; then
    echo "brew"
  elif need_cmd bun; then
    echo "bun"
  else
    select_system_pm
  fi
}

sudo_if_needed() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  elif need_cmd sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

pkg_install() {
  local pkgs=("$@")
  local pm

  pm="$(select_pm || true)"
  if [[ -z "$pm" ]]; then
    log "No supported package manager found. Install manually: ${pkgs[*]}"
    return 1
  fi

  if [[ "$pm" == "bun" ]]; then
    log "bun detected, but these are system packages; falling back to a system package manager."
    pm="$(select_system_pm || true)"
    if [[ -z "$pm" ]]; then
      log "No supported system package manager found. Install manually: ${pkgs[*]}"
      return 1
    fi
  fi

  if [[ "$pm" == "apt-get" ]]; then
    sudo_if_needed apt-get update -y
    sudo_if_needed apt-get install -y "${pkgs[@]}"
  elif [[ "$pm" == "dnf" ]]; then
    sudo_if_needed dnf install -y "${pkgs[@]}"
  elif [[ "$pm" == "yum" ]]; then
    sudo_if_needed yum install -y "${pkgs[@]}"
  elif [[ "$pm" == "pacman" ]]; then
    sudo_if_needed pacman -Sy --noconfirm "${pkgs[@]}"
  elif [[ "$pm" == "apk" ]]; then
    sudo_if_needed apk add --no-cache "${pkgs[@]}"
  elif [[ "$pm" == "zypper" ]]; then
    sudo_if_needed zypper --non-interactive install "${pkgs[@]}"
  elif [[ "$pm" == "brew" ]]; then
    brew install "${pkgs[@]}"
  else
    log "No supported package manager found. Install manually: ${pkgs[*]}"
    return 1
  fi
}

ensure_packages() {
  local missing=()
  for p in "$@"; do
    if ! need_cmd "$p"; then
      missing+=("$p")
    fi
  done

  if ((${#missing[@]})); then
    log "Installing packages: ${missing[*]}"
    pkg_install "${missing[@]}"
  else
    log "Packages already installed: $*"
  fi
}

ensure_optional_cmd_pkg() {
  local cmd="$1"
  local pkg="$2"

  if need_cmd "$cmd"; then
    log "Optional package already installed: $cmd"
    return 0
  fi

  log "Installing optional package: $pkg (for $cmd)"
  if ! pkg_install "$pkg"; then
    log "Optional install failed for $pkg. You can install it manually."
    return 0
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "oh-my-zsh already installed"
    return
  fi

  if ! need_cmd curl; then
    log "curl not found; cannot install oh-my-zsh"
    return 1
  fi

  log "Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

# Clone a repo into a destination dir (used for OMZ plugins and the Pure prompt)
clone_repo() {
  local repo="$1"
  local dest="$2"
  local name="${repo##*/}"

  if [[ -d "$dest/.git" ]]; then
    log "$name already installed"
    return
  fi

  if ! need_cmd git; then
    log "git not found; cannot install $name"
    return 1
  fi

  mkdir -p "$(dirname "$dest")"
  git clone --depth 1 "https://github.com/$repo.git" "$dest"
  log "$name installed"
}

install_zsh_plugin() {
  local repo="$1"
  local name="${repo##*/}"
  clone_repo "$repo" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"
}

install_tpm() {
  local dest="$HOME/.tmux/plugins/tpm"
  if [[ -d "$dest/.git" ]]; then
    log "tpm already installed"
    return
  fi

  if ! need_cmd git; then
    log "git not found; cannot install tpm"
    return 1
  fi

  mkdir -p "$(dirname "$dest")"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$dest"
  log "tpm installed"
}

log "Bootstrapping dotfiles dependencies"

ensure_packages git curl
install_homebrew
maybe_eval_brew_shellenv

ensure_packages zsh tmux wget

ensure_packages fzf

if [[ "$(uname -s)" != "Darwin" ]]; then
  ensure_optional_cmd_pkg wl-copy wl-clipboard
  ensure_optional_cmd_pkg xclip xclip
fi

install_oh_my_zsh
install_zsh_plugin zsh-users/zsh-autosuggestions
install_zsh_plugin zsh-users/zsh-syntax-highlighting
clone_repo sindresorhus/pure "$HOME/.zsh/pure"
install_tpm

log "Done."
