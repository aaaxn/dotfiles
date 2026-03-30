#!/usr/bin/env bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir=$(basename "${cwd:-$(pwd)}")
branch=$(git -C "${cwd:-$(pwd)}" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
         || git -C "${cwd:-$(pwd)}" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

parts="${dir}"
[ -n "$branch" ] && parts="${parts}  ${branch}"
[ -n "$model" ] && parts="${parts}  ${model}"
[ -n "$used" ] && parts="${parts}  ctx:${used}%"

printf '%s' "${parts}"
