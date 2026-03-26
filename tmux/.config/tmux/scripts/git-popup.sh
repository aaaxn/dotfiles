#!/usr/bin/env bash
set -euo pipefail

pane_path="${1:-$PWD}"

if [[ -z "$pane_path" ]]; then
  pane_path="$HOME"
fi

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  R=$'\033[0m'
  BD=$'\033[1m'
  DIM=$'\033[2m'
  CY=$'\033[36m'
  GR=$'\033[32m'
  YE=$'\033[33m'
  RD=$'\033[31m'
  MG=$'\033[35m'
  WH=$'\033[97m'
else
  R='' BD='' DIM='' CY='' GR='' YE='' RD='' MG='' WH=''
fi

render() {
  cd "$pane_path" 2>/dev/null || {
    printf '%sNao foi possivel abrir:%s %s\n' "$RD" "$R" "$pane_path"
    return 0
  }

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '%sGit Popup%s\n\n' "$BD$CY" "$R"
    printf '%sPath:%s %s\n' "$BD$MG" "$R" "$PWD"
    printf '%sNao esta em um repositorio Git.%s\n' "$YE" "$R"
    return 0
  fi

  local repo_root repo_name branch_name
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"
  repo_name="$(basename -- "$repo_root")"
  branch_name="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  if [[ -z "$branch_name" ]]; then
    branch_name="detached@$(git rev-parse --short HEAD 2>/dev/null || echo '?')"
  fi

  local unstaged_add=0 unstaged_del=0 staged_add=0 staged_del=0
  read -r unstaged_add unstaged_del < <(git diff --numstat 2>/dev/null | awk '{add+=$1; del+=$2} END {print add+0, del+0}')
  read -r staged_add staged_del < <(git diff --cached --numstat 2>/dev/null | awk '{add+=$1; del+=$2} END {print add+0, del+0}')

  local total_add total_del untracked_count
  total_add=$((unstaged_add + staged_add))
  total_del=$((unstaged_del + staged_del))
  untracked_count="$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')"

  printf '%sGit Popup%s\n\n' "$BD$CY" "$R"
  printf '%sRepo:%s   %s\n' "$BD$MG" "$R" "$repo_name"
  printf '%sBranch:%s %s\n' "$BD$MG" "$R" "$branch_name"
  printf '%sPath:%s   %s\n' "$BD$MG" "$R" "$PWD"
  printf '%sTotal:%s  ' "$BD$MG" "$R"
  if [[ "$total_add" -gt 0 ]]; then printf '%s+%s%s ' "$GR" "$total_add" "$R"; else printf '%s' '+0 '; fi
  if [[ "$total_del" -gt 0 ]]; then printf '%s-%s%s ' "$RD" "$total_del" "$R"; else printf '%s' '-0 '; fi
  printf '(%sstaged%s %+d/%+d, %sunstaged%s %+d/%+d)\n' "$DIM" "$R" "$staged_add" "-$staged_del" "$DIM" "$R" "$unstaged_add" "-$unstaged_del"
  printf '%sUntracked:%s %s\n' "$BD$MG" "$R" "$untracked_count"
  printf '\n%sStatus (ate 10 linhas):%s\n' "$BD$MG" "$R"

  local status_output status_lines
  status_output="$(git status --short --branch 2>/dev/null || true)"
  if [[ -z "$status_output" ]]; then
    printf '  (sem saida)\n'
    return 0
  fi

  status_lines="$(printf '%s\n' "$status_output" | sed -n '1,10p')"
  printf '%s\n' "$status_lines" | sed 's/^/  /'

  local total_lines
  total_lines="$(printf '%s\n' "$status_output" | wc -l | tr -d ' ')"
  if [[ "$total_lines" -gt 10 ]]; then
    printf '\n%s... %s linhas no total%s\n' "$DIM" "$total_lines" "$R"
  fi
}

if [[ ! -t 1 ]]; then
  render
  exit 0
fi

if command -v less >/dev/null 2>&1; then
  render | less -R
else
  render
  printf '\nPressione Enter para fechar...'
  read -r _
fi
