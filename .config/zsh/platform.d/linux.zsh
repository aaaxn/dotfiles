# Linuxbrew env (also needed for non-login shells)
if [[ -z "${HOMEBREW_PREFIX:-}" ]] && [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi

. "$HOME/.local/share/../bin/env" 2>/dev/null || true
export PATH="/home/linuxbrew/.linuxbrew/opt/node@24/bin:$PATH"
