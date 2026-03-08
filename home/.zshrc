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


# Let uv default to each project's local .venv.
unset UV_PROJECT_ENVIRONMENT





export TZ="America/Sao_Paulo"

alias tma='tmux a -t'
alias tms='tmux new -s'
alias tmls='tmux ls'
alias oc='opencode'
alias cc='claude code'
alias codex='codex --yolo'
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
alias tmux-prefix='$HOME/.config/tmux/scripts/tmux-prefix.sh'

export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

. "$HOME/.local/share/../bin/env"
export PATH="/home/linuxbrew/.linuxbrew/opt/node@24/bin:$PATH"
