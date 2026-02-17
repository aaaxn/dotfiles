#!/usr/bin/env bash
set -euo pipefail

window_id="${1:-}"
if [[ -z "${window_id}" ]]; then
  exit 0
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

pane_path="$(tmux display-message -p -t "$window_id" "#{pane_current_path}" 2>/dev/null || true)"
if [[ -z "$pane_path" ]]; then
  pane_path="$HOME"
fi

active_pane_id="$(tmux display-message -p -t "$window_id" "#{pane_id}" 2>/dev/null || true)"
manual_label=""
if [[ -n "$active_pane_id" ]]; then
  manual_label="$(tmux display-message -p -t "$active_pane_id" "#{@manual_pane_label}" 2>/dev/null || true)"
fi

format_target() {
  local target_path="$1"

  cd "$target_path" 2>/dev/null || { basename -- "$target_path"; return 0; }

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    basename -- "$target_path"
    return 0
  fi

  local worktree_root worktree_name
  worktree_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  worktree_name="$(basename -- "$worktree_root")"

  local unstaged_add=0 unstaged_del=0 staged_add=0 staged_del=0
  read -r unstaged_add unstaged_del < <(git diff --numstat 2>/dev/null | awk '{add+=$1; del+=$2} END {print add+0, del+0}')
  read -r staged_add staged_del < <(git diff --cached --numstat 2>/dev/null | awk '{add+=$1; del+=$2} END {print add+0, del+0}')

  local total_add=$((unstaged_add + staged_add))
  local total_del=$((unstaged_del + staged_del))

  local out="$worktree_name"
  if [[ "$total_add" -gt 0 || "$total_del" -gt 0 ]]; then
    if [[ "$total_add" -gt 0 ]]; then
      out="$out +$total_add"
    fi
    if [[ "$total_del" -gt 0 ]]; then
      out="$out -$total_del"
    fi
  fi

  printf '%s' "$out"
}

info="$(format_target "$pane_path")"
agent="$("$script_dir/agent-status.sh" "$window_id" 2>/dev/null || true)"

if [[ -n "$manual_label" ]]; then
  if [[ -n "$agent" ]]; then
    printf '%s + %s' "$agent" "$manual_label"
  else
    printf '%s' "$manual_label"
  fi
  exit 0
fi

if [[ -n "$agent" ]]; then
  printf '%s %s' "$agent" "$info"
else
  printf '%s' "$info"
fi
