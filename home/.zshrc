if [[ -f "$HOME/.local/bin/env" ]]; then
  source "$HOME/.local/bin/env"
fi

if [[ -f "$HOME/.antidote/antidote.zsh" ]]; then
  source "$HOME/.antidote/antidote.zsh"
fi

if [[ -f "$HOME/.zsh_plugins.zsh" ]]; then
  source "$HOME/.zsh_plugins.zsh"
elif [[ -f "$HOME/.zsh_plugins.txt" ]]; then
  antidote load "$HOME/.zsh_plugins.txt"
fi

export TZ="America/Sao_Paulo"

alias tma='tmux a -t'
alias tms='tmux new -s'
alias tmls='tmux ls'
alias oc='opencode'
alias cc='claude code'

export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"

if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
