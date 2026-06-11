# ── Oh My Zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

# Prompt comes from Pure (loaded below), not an OMZ theme
ZSH_THEME=""

# Keep the compdump out of ~/
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ── Pure prompt ──────────────────────────────────────────────────────────────
# macOS: brew install pure | Linux: bootstrap clones it to ~/.zsh/pure
[[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]] && \
  fpath+=("$HOMEBREW_PREFIX/share/zsh/site-functions")
[[ -d "$HOME/.zsh/pure" ]] && fpath+=("$HOME/.zsh/pure")
autoload -U promptinit; promptinit
prompt pure

# ── History ──────────────────────────────────────────────────────────────────
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS SHARE_HISTORY

# ── Environment ──────────────────────────────────────────────────────────────
export TZ="America/Sao_Paulo"

[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
unset UV_PROJECT_ENVIRONMENT

# Codex in tmux can fail to infer the terminal background when COLORFGBG is unset.
if [[ -n "$TMUX" && -z "$COLORFGBG" ]]; then
  export COLORFGBG="15;0"
fi

command -v mise >/dev/null && eval "$(mise activate zsh)"

# ── Aliases ──────────────────────────────────────────────────────────────────
alias tma='tmux a -t'
alias tms='tmux new -s'
alias tmls='tmux ls'
alias oc='opencode'
alias cc='claude --dangerously-skip-permissions'
alias codex='codex --yolo'

# ── Platform-specific ────────────────────────────────────────────────────────
_platform_file="$HOME/.config/zsh/platform.d/$(uname -s | tr '[:upper:]' '[:lower:]').zsh"
[[ -f "$_platform_file" ]] && source "$_platform_file"
unset _platform_file
