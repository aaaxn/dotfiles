# Antidote plugin manager
if [[ -f "$HOME/.antidote/antidote.zsh" ]]; then
  source "$HOME/.antidote/antidote.zsh"
fi

if [[ -f "$HOME/.zsh_plugins.zsh" ]]; then
  source "$HOME/.zsh_plugins.zsh"
elif [[ -f "$HOME/.zsh_plugins.txt" ]]; then
  antidote load "$HOME/.zsh_plugins.txt"
fi

# zsh-autosuggestions (via brew)
[[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan,bold,underline"
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
  history-beginning-search-backward-end
  history-beginning-search-forward-end
)

# zsh-autocomplete (via brew)
[[ -f "$HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]] && \
  source "$HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

export TZ="America/Sao_Paulo"

# Codex in tmux can fail to infer the terminal background when COLORFGBG is unset.
# Provide a dark-background fallback only for tmux sessions.
if [[ -n "$TMUX" && -z "$COLORFGBG" ]]; then
  export COLORFGBG="15;0"
fi

# Aliases
alias tma='tmux a -t'
alias tms='tmux new -s'
alias tmls='tmux ls'
alias oc='opencode'
alias cc='claude --dangerously-skip-permissions'
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

# AeroSpace shortcuts cheatsheet from ~/.aerospace.toml
_aerokey_print() {
  local cfg="${AEROKEY_CONFIG:-$HOME/.aerospace.toml}"

  if [[ ! -f "$cfg" ]]; then
    echo "AeroSpace config not found: $cfg" >&2
    return 1
  fi

  awk '
    BEGIN { mode = ""; printed = 0 }

    /^\[mode\.[^.]+\.binding\]/ {
      mode = $0
      gsub(/\[|\]/, "", mode)
      sub(/^mode\./, "", mode)
      sub(/\.binding$/, "", mode)
      if (printed++) printf "\n"
      printf "=== %s ===\n", toupper(mode)
      next
    }

    /^\[/ {
      mode = ""
      next
    }

    mode != "" {
      line = $0
      sub(/[[:space:]]*#.*/, "", line)
      if (line ~ /^[[:space:]]*$/) next
      if (line !~ /^[[:space:]]*[A-Za-z0-9_-]+[[:space:]]*=/) next

      key = line
      sub(/=.*/, "", key)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)

      val = line
      sub(/^[^=]*=[[:space:]]*/, "", val)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)

      printf "%-22s -> %s\n", key, val
    }
  ' "$cfg"
}
alias aerokey='_aerokey_print'

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"
