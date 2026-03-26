# Dynamic terminal title: icon hostname:~/path
# Icons use Nerd Font glyphs — one per host family.

typeset -A _title_icons=(
  prolina     "󰌢"
  dcc         "󰒋"
  cerberus    "󰛡"
  phocus      "󱗼"
  gorgona     "󰊕"
  harpocrates "󰍁"
  medusa      "󱔎"
)

_title_icon() {
  local h="${1%%.*}"
  local key
  for key in ${(k)_title_icons}; do
    [[ "$h" == ${key}* ]] && { echo "$_title_icons[$key]"; return; }
  done
  echo "󰒋"
}

_set_title() {
  local host="${HOST%%.*}"
  local icon="$(_title_icon "$host")"
  local dir="${PWD/#$HOME/~}"
  print -Pn "\e]2;${icon} ${host}:${dir}\a"
}

# Wrap ssh to set title to remote host during the session.
# precmd restores the local title when ssh exits.
ssh() {
  local dest=""
  local arg
  for arg in "$@"; do
    # skip flags and their values
    [[ "$arg" == -* ]] && continue
    # first non-flag arg is the destination
    dest="$arg"
    break
  done

  if [[ -n "$dest" ]]; then
    # strip user@ if present
    local rhost="${dest#*@}"
    local icon="$(_title_icon "$rhost")"
    print -Pn "\e]2;${icon} ${rhost}\a"
  fi

  command ssh "$@"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _set_title
