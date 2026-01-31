#!/usr/bin/env bash
set -euo pipefail

log() { printf "%s\n" "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1
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

detect_zsh() {
  # Prefer PATH, but handle common Homebrew and system locations too.
  if need_cmd zsh; then
    command -v zsh
    return 0
  fi

  local candidates=(
    /usr/bin/zsh
    /bin/zsh
    /usr/local/bin/zsh
    /opt/homebrew/bin/zsh
    /home/linuxbrew/.linuxbrew/bin/zsh
  )

  local c
  for c in "${candidates[@]}"; do
    if [[ -x "$c" ]]; then
      printf "%s\n" "$c"
      return 0
    fi
  done

  return 1
}

ensure_shell_allowed() {
  local shell_path="$1"

  if [[ ! -r /etc/shells ]]; then
    log "WARN: /etc/shells not readable; cannot verify if $shell_path is allowed."
    return 0
  fi

  if grep -qxF "$shell_path" /etc/shells; then
    return 0
  fi

  # Most chsh implementations require the shell to be listed in /etc/shells.
  log "Adding $shell_path to /etc/shells (may require sudo)"
  if [[ -w /etc/shells ]]; then
    printf "%s\n" "$shell_path" >>/etc/shells
  else
    sudo_if_needed sh -c "printf '%s\n' '$shell_path' >> /etc/shells"
  fi
}

main() {
  if [[ "${DOTFILES_SKIP_CHSH:-}" == "1" ]]; then
    log "Skipping default shell change (DOTFILES_SKIP_CHSH=1)"
    return 0
  fi

  if [[ ! -t 0 ]]; then
    log "Non-interactive session; skipping default shell change (set DOTFILES_SKIP_CHSH=1 to silence)"
    return 0
  fi

  if ! need_cmd chsh; then
    log "chsh not found; cannot set default shell automatically."
    log "Manual: chsh -s \"$(detect_zsh 2>/dev/null || echo /path/to/zsh)\" \"$USER\""
    return 0
  fi

  local zsh_path
  if ! zsh_path="$(detect_zsh)"; then
    log "zsh not found; install it first, then re-run this script."
    return 1
  fi

  local current_shell="${SHELL:-}"
  if [[ -n "$current_shell" && "$current_shell" == "$zsh_path" ]]; then
    log "Default shell already set to zsh: $zsh_path"
    return 0
  fi

  ensure_shell_allowed "$zsh_path"

  log "Setting default shell to: $zsh_path"
  if chsh -s "$zsh_path" "$USER"; then
    log "Done. Log out and back in to apply."
  else
    log "chsh failed. You may need to run it manually:"
    log "  chsh -s \"$zsh_path\" \"$USER\""
    return 1
  fi
}

main "$@"

