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
alias codex='codex --yolo'

export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

. "$HOME/.local/share/../bin/env"
export PATH="/home/linuxbrew/.linuxbrew/opt/node@24/bin:$PATH"
