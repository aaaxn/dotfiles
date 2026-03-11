#!/usr/bin/env bash
set -euo pipefail

export PATH="$PATH:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

if ! command -v fzf >/dev/null 2>&1; then
  tmux display-message "window-picker: fzf nao encontrado (instale 'fzf')"
  exit 127
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
self="$script_dir/window-picker.sh"

# ── Send-pane mode (runs inside its own display-popup) ───────────────
if [[ "${1:-}" == "--send-pane" ]]; then
  src_pane="$2"

  entries="__new__\t\033[33m[+ Nova Sessao]\033[0m"
  while IFS= read -r sess; do
    win_count="$(tmux list-windows -t "$sess" 2>/dev/null | wc -l)"
    entries+=$'\n'"${sess}\t${sess} \033[90m(${win_count}w)\033[0m"
  done < <(tmux list-sessions -F '#{session_name}')

  selected="$(
    echo -e "$entries" | fzf \
      --ansi \
      --prompt="Send pane to: " \
      --header="Select target session" \
      --preview='tmux list-windows -t {1} -F "  #{window_index}: #{window_name} — #{pane_current_path}" 2>/dev/null || echo "Nova sessao"' \
      --preview-window=right,60% \
      --delimiter=$'\t' \
      --with-nth=2
  )" || exit 0

  target="$(awk '{print $1}' <<<"$selected")"

  if [[ "$target" == "__new__" ]]; then
    # Use fzf as a simple text input for the session name
    session_name="$(
      : | fzf \
        --prompt="Session name: " \
        --header="Type session name, press Enter" \
        --no-info \
        --disabled \
        --bind='enter:become(echo {q})' \
    )" || exit 0

    [[ -z "$session_name" ]] && exit 0

    session_name="${session_name//./-}"
    session_name="${session_name//:/-}"

    if ! tmux has-session -t "=$session_name" 2>/dev/null; then
      tmux new-session -d -s "$session_name"
      placeholder="$(tmux list-windows -t "$session_name" -F '#{window_id}' | head -1)"
      tmux break-pane -d -s "$src_pane" -t "${session_name}:"
      tmux kill-window -t "$placeholder" 2>/dev/null || true
    else
      tmux break-pane -d -s "$src_pane" -t "${session_name}:"
    fi
    tmux switch-client -t "$session_name"
  else
    tmux break-pane -d -s "$src_pane" -t "${target}:"
    tmux switch-client -t "$target"
  fi

  exit 0
fi

# ── Normal window-picker mode ────────────────────────────────────────

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
src_pane="$(tmux display-message -p '#{pane_id}')"
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
  fzf_cmd=(fzf)
fi

selected="$(
  echo -e "$lines" | "${fzf_cmd[@]}" \
    --ansi \
    --sync \
    --prompt="Switch to: " \
    --header=$'enter: switch | ctrl-s: send pane to session' \
    --expect="ctrl-s" \
    --preview='tmux capture-pane -ep -t {1}' \
    --preview-window=right,60% \
    --bind='ctrl-d:preview-half-page-down' \
    --bind='ctrl-u:preview-half-page-up' \
    --bind="start:pos($pos)" \
    --delimiter=$'\t' \
    --with-nth=2
)"

key="$(head -1 <<<"$selected")"
choice="$(sed -n '2p' <<<"$selected")"

case "$key" in
  ctrl-s)
    # Open the send-pane picker in a new tmux popup
    tmux display-popup -E -w 80% -h 60% "'$self' --send-pane '$src_pane'"
    ;;
  *)
    if [[ -n "$choice" ]]; then
      target="$(awk '{print $1}' <<<"$choice")"
      tmux switch-client -t "$target" 2>/dev/null || tmux select-window -t "$target"
    fi
    ;;
esac
