#!/usr/bin/env bash
set -euo pipefail

log() { printf "%s\n" "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

detect_current_shell() {
  local from_passwd=""
  if need_cmd getent; then
    from_passwd="$(getent passwd "$USER" 2>/dev/null | awk -F: '{print $7}')"
  elif [[ -r /etc/passwd ]]; then
    from_passwd="$(grep -E "^${USER}:" /etc/passwd 2>/dev/null | awk -F: '{print $7}')"
  fi

  if [[ -n "$from_passwd" ]]; then
    printf "%s\n" "$from_passwd"
  else
    printf "%s\n" "${SHELL:-}"
  fi
}

detect_zsh() {
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

is_local_user() {
  grep -qE "^${USER}:" /etc/passwd 2>/dev/null
}

ensure_shell_allowed() {
  local shell_path="$1"

  if [[ ! -r /etc/shells ]]; then
    return 0
  fi

  if grep -qxF "$shell_path" /etc/shells; then
    return 0
  fi

  log "Adding $shell_path to /etc/shells (may require sudo)"
  if [[ -w /etc/shells ]]; then
    printf "%s\n" "$shell_path" >>/etc/shells
  elif need_cmd sudo; then
    sudo sh -c "printf '%s\n' '$shell_path' >> /etc/shells"
  fi
}

# Fallback: add an exec-zsh snippet to ~/.bashrc for network-managed accounts.
BASHRC_MARKER="# dotfiles: exec zsh"

install_bashrc_exec() {
  local zsh_path="$1"
  local bashrc="$HOME/.bashrc"

  if [[ -f "$bashrc" ]] && grep -qF "$BASHRC_MARKER" "$bashrc"; then
    log "~/.bashrc already contains exec-zsh snippet"
    return 0
  fi

  local snippet
  snippet="$(cat <<EOF

$BASHRC_MARKER
# Launch zsh automatically when bash starts (login shell is managed by
# LDAP/network and cannot be changed with chsh).
if [[ -x "$zsh_path" && -z "\${ZSH_EXEC_GUARD:-}" ]]; then
  export ZSH_EXEC_GUARD=1
  exec "$zsh_path" -l
fi
EOF
)"

  if [[ -f "$bashrc" ]]; then
    printf "%s\n" "$snippet" >> "$bashrc"
  else
    printf "%s\n" "$snippet" > "$bashrc"
  fi

  log "Added exec-zsh snippet to ~/.bashrc"
  log "New login sessions will start zsh automatically."
}

try_chsh() {
  local zsh_path="$1"

  if ! need_cmd chsh; then
    return 1
  fi

  if [[ ! -e /dev/tty ]]; then
    return 1
  fi

  ensure_shell_allowed "$zsh_path"

  log "Trying chsh..."
  if chsh -s "$zsh_path" "$USER" </dev/tty 2>/dev/null; then
    log "Done. Log out and back in to apply."
    return 0
  fi

  return 1
}

main() {
  if [[ "${DOTFILES_SKIP_CHSH:-}" == "1" ]]; then
    log "Skipping default shell change (DOTFILES_SKIP_CHSH=1)"
    return 0
  fi

  local zsh_path
  if ! zsh_path="$(detect_zsh)"; then
    log "zsh not found; install it first, then re-run this script."
    return 1
  fi

  local current_shell
  current_shell="$(detect_current_shell)"
  if [[ -n "$current_shell" && "$current_shell" == "$zsh_path" ]]; then
    log "Default shell already set to zsh: $zsh_path"
    return 0
  fi

  # For local users, try chsh first.
  if is_local_user; then
    if try_chsh "$zsh_path"; then
      return 0
    fi
    log "chsh failed; falling back to ~/.bashrc exec method."
  else
    log "Network-managed account detected (user not in /etc/passwd)."
    log "Cannot use chsh; using ~/.bashrc exec fallback."
  fi

  install_bashrc_exec "$zsh_path"
}

main "$@"
