#!/usr/bin/env bash
set -euo pipefail

export PATH="$PATH:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

if ! command -v fzf >/dev/null 2>&1; then
  tmux display-message "window-picker: fzf nao encontrado (instale 'fzf')"
  exit 127
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

get_worktree_info() {
  local pane_path="$1"

  cd "$pane_path" 2>/dev/null || { echo "$pane_path"; return; }

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    basename -- "$pane_path"
    return
  fi

  local worktree_root worktree_name
  worktree_root="$(git rev-parse --show-toplevel 2>/dev/null)"
  worktree_name="$(basename -- "$worktree_root")"

  local unstaged_add=0 unstaged_del=0 staged_add=0 staged_del=0
  read -r unstaged_add unstaged_del < <(git diff --numstat 2>/dev/null | awk '{add+=$1; del+=$2} END {print add+0, del+0}')
  read -r staged_add staged_del < <(git diff --cached --numstat 2>/dev/null | awk '{add+=$1; del+=$2} END {print add+0, del+0}')

  local total_add=$((unstaged_add + staged_add))
  local total_del=$((unstaged_del + staged_del))

  local out="$worktree_name"
  if [[ $total_add -gt 0 || $total_del -gt 0 ]]; then
    out="$out "
    [[ $total_add -gt 0 ]] && out="${out}\033[32m+${total_add}\033[0m"
    [[ $total_add -gt 0 && $total_del -gt 0 ]] && out="$out "
    [[ $total_del -gt 0 ]] && out="${out}\033[31m-${total_del}\033[0m"
  fi

  echo -e "$out"
}

current="$(tmux display-message -p '#{session_name}:#{window_index}')"
pos=1
i=1
lines=""

while IFS='|' read -r target path; do
  worktree_info="$(get_worktree_info "$path")"
  window_id="$(tmux display-message -t "$target" -p '#{window_id}' 2>/dev/null || true)"
  agent_name="$("$script_dir/agent-status.sh" "$window_id" 2>/dev/null || true)"

  if [[ -n "$agent_name" ]]; then
    info="\033[90m$agent_name\033[0m $worktree_info"
  else
    info="$worktree_info"
  fi

  lines+="$target\t$info"$'\n'
  [[ "$target" == "$current" ]] && pos=$i
  ((i++))
done < <(tmux list-windows -a -F '#{session_name}:#{window_index}|#{pane_current_path}')

lines="${lines%$'\n'}"

fzf_cmd=(fzf --tmux 80%,60%)
if ! fzf --help 2>&1 | grep -q -- '--tmux'; then
  # Older fzf builds might not support --tmux; fall back to plain fzf.
  fzf_cmd=(fzf)
fi

selected="$(
  echo -e "$lines" | "${fzf_cmd[@]}" \
    --ansi \
    --sync \
    --prompt="Switch to: " \
    --header="Select a window" \
    --preview='tmux capture-pane -ep -t {1}' \
    --preview-window=right,60% \
    --bind='ctrl-d:preview-half-page-down' \
    --bind='ctrl-u:preview-half-page-up' \
    --bind="start:pos($pos)" \
    --delimiter=$'\t' \
    --with-nth=2
)"

if [[ -n "$selected" ]]; then
  target="$(awk '{print $1}' <<<"$selected")"
  tmux switch-client -t "$target" 2>/dev/null || tmux select-window -t "$target"
fi
