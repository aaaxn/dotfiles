# ── Completion ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit

# ── History ──────────────────────────────────────────────────────────────────
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS SHARE_HISTORY

# ── Shared settings ─────────────────────────────────────────────────────────
if [[ -f "$HOME/.local/bin/env" ]]; then
  source "$HOME/.local/bin/env"
fi

unset UV_PROJECT_ENVIRONMENT

export TZ="America/Sao_Paulo"

# Codex in tmux can fail to infer the terminal background when COLORFGBG is unset.
if [[ -n "$TMUX" && -z "$COLORFGBG" ]]; then
  export COLORFGBG="15;0"
fi

# ── Aliases ──────────────────────────────────────────────────────────────────
alias tma='tmux a -t'
alias tms='tmux new -s'
alias tmls='tmux ls'
alias oc='opencode'
alias cc='claude --dangerously-skip-permissions'
alias codex='codex --yolo'
alias tmux-prefix='$HOME/.config/tmux/scripts/tmux-prefix.sh'

# ── Platform-specific ────────────────────────────────────────────────────────
_platform_file="$HOME/.config/zsh/platform.d/$(uname -s | tr '[:upper:]' '[:lower:]').zsh"
[[ -f "$_platform_file" ]] && source "$_platform_file"
unset _platform_file

# ── Starship ─────────────────────────────────────────────────────────────────
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"

# ── Plugins (must be at the end) ─────────────────────────────────────────────
[[ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
