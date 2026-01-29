#!/usr/bin/env bash
set -euo pipefail

window_id="${1:-}"
if [[ -z "${window_id}" ]]; then
  exit 0
fi

check_process() {
  local pid="$1"

  local comm args
  comm="$(ps -p "$pid" -o comm= 2>/dev/null || true)"
  args="$(ps -p "$pid" -o args= 2>/dev/null || true)"

  local label
  label_for() {
    case "$1" in
      codex) printf '%s' "🤖 Codex" ;;
      claude) printf '%s' "🪶 Claude Code" ;;
      aider) printf '%s' "🛠️ Aider" ;;
      goose) printf '%s' "🪿 Goose" ;;
      amp) printf '%s' "⚡ Amp" ;;
      opencode) printf '%s' "🧩 OpenCode" ;;
    esac
  }

  case "$comm" in
    claude|claude-code) label="$(label_for claude)"; printf '%s' "$label"; return 0 ;;
    aider) label="$(label_for aider)"; printf '%s' "$label"; return 0 ;;
    goose) label="$(label_for goose)"; printf '%s' "$label"; return 0 ;;
    amp) label="$(label_for amp)"; printf '%s' "$label"; return 0 ;;
    opencode) label="$(label_for opencode)"; printf '%s' "$label"; return 0 ;;
  esac

  if [[ "$args" == *"/codex"* ]] || [[ "$comm" == *codex* ]]; then
    label="$(label_for codex)"
    printf '%s' "$label"
    return 0
  fi

  if [[ "$args" == *"/opencode"* ]] || [[ "$comm" == *opencode* ]]; then
    label="$(label_for opencode)"
    printf '%s' "$label"
    return 0
  fi

  return 1
}

find_agent() {
  local parent_pid="$1"
  local depth="${2:-0}"
  [[ "$depth" -gt 10 ]] && return 1

  local children
  children="$(ps -eo pid=,ppid= 2>/dev/null | awk -v ppid="$parent_pid" '$2 == ppid {print $1}' || true)"

  local child_pid agent
  for child_pid in $children; do
    [[ -z "$child_pid" ]] && continue

    agent="$(check_process "$child_pid" 2>/dev/null || true)"
    if [[ -n "$agent" ]]; then
      printf '%s' "$agent"
      return 0
    fi

    agent="$(find_agent "$child_pid" $((depth + 1)) 2>/dev/null || true)"
    if [[ -n "$agent" ]]; then
      printf '%s' "$agent"
      return 0
    fi
  done

  return 1
}

pane_pids="$(tmux list-panes -t "$window_id" -F '#{pane_pid}' 2>/dev/null || true)"

pane_pid=""
for pane_pid in $pane_pids; do
  [[ -z "$pane_pid" ]] && continue

  agent="$(find_agent "$pane_pid" 0 2>/dev/null || true)"
  if [[ -n "$agent" ]]; then
    printf '%s' "$agent"
    exit 0
  fi
done

exit 0
