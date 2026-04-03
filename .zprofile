# Homebrew shellenv — detect platform and load
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# pipx
case ":${PATH}:" in
  *:"$HOME/.local/bin":*) ;;
  *) export PATH="$PATH:$HOME/.local/bin" ;;
esac

# macOS extras
if [[ "$(uname -s)" == "Darwin" ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
  [[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh 2>/dev/null
fi
