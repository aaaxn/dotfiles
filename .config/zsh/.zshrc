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

# ── Functions ────────────────────────────────────────────────────────────────
codex-ns() {
  local base_link="$HOME/.agents/skills/superpowers"
  local tmp_root="$HOME/.codex/tmp"
  local tmp_home
  local rc=0
  local skill

  mkdir -p "$tmp_root" || return 1
  tmp_home="$(mktemp -d "$tmp_root/codex-ns.XXXXXX")" || return 1

  cp "$HOME/.codex/config.toml" "$tmp_home/config.toml" || {
    rm -rf "$tmp_home"
    return 1
  }

  [[ -f "$HOME/.codex/auth.json" ]] && cp "$HOME/.codex/auth.json" "$tmp_home/auth.json"
  [[ -f "$HOME/.codex/version.json" ]] && cp "$HOME/.codex/version.json" "$tmp_home/version.json"
  [[ -f "$HOME/.codex/models_cache.json" ]] && cp "$HOME/.codex/models_cache.json" "$tmp_home/models_cache.json"

  {
    echo
    echo "# codex-ns temporary overrides"
    echo "project_doc_max_bytes = 0"
    if [[ -e "$base_link" ]]; then
      while IFS= read -r skill; do
        printf '[[skills.config]]\npath = "%s"\nenabled = false\n\n' "$skill"
      done < <(find -L "$base_link" -mindepth 2 -maxdepth 2 -name SKILL.md | sort)
    fi
  } >> "$tmp_home/config.toml"

  CODEX_HOME="$tmp_home" command codex --yolo "$@"
  rc=$?
  rm -rf "$tmp_home"
  return $rc
}

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
