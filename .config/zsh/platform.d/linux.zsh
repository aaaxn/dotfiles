# Linuxbrew env (also needed for non-login shells)
if [[ -z "${HOMEBREW_PREFIX:-}" ]] && [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi

export PATH="/home/linuxbrew/.linuxbrew/opt/node@24/bin:$PATH"
