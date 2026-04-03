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

# AeroSpace shortcuts cheatsheet
_aerokey_print() {
  local cfg="${AEROKEY_CONFIG:-$HOME/.config/aerospace/aerospace.toml}"

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
