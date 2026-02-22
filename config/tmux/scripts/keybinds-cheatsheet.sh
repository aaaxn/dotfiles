#!/usr/bin/env bash
set -euo pipefail

prefix="$(tmux show-option -gqv prefix 2>/dev/null || echo 'C-b')"

use_color=0
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  use_color=1
fi

if [[ "$use_color" -eq 1 ]]; then
  reset=$'\033[0m'
  bold=$'\033[1m'
  dim=$'\033[2m'
  cyan=$'\033[36m'
  green=$'\033[32m'
  yellow=$'\033[33m'
else
  reset=''
  bold=''
  dim=''
  cyan=''
  green=''
  yellow=''
fi

print_row() {
  local key="$1"
  local desc="$2"
  printf "  %b%-22s%b %s\n" "${green}${bold}" "$key" "$reset" "$desc"
}

print_section() {
  local title="$1"
  printf "\n%b%s%b\n" "${cyan}${bold}" "$title" "$reset"
}

render_cheatsheet() {
  printf "%b+------------------------------------------------------------------------+%b\n" "$cyan" "$reset"
  printf "%b| %-70s |%b\n" "$cyan" "${bold}TMUX KEYBINDS CHEATSHEET${reset}${cyan}" "$reset"
  printf "%b| %-70s |%b\n" "$cyan" "Prefix atual: ${yellow}${bold}${prefix}${reset}${cyan}" "$reset"
  printf "%b+------------------------------------------------------------------------+%b\n" "$cyan" "$reset"

  print_section "JANELAS E PANEIS"
  print_row "$prefix + c" "Nova janela no diretorio atual"
  print_row "$prefix + w" "Seletor de janelas (fzf)"
  print_row "$prefix + x" "Fecha pane atual"
  print_row "$prefix + m" "Maximiza/restaura pane atual"
  print_row "$prefix + P" "Define label manual do pane"
  print_row "$prefix + r" "Recarrega config do tmux"
  print_row "$prefix + T" "Menu de temas"
  print_row "$prefix + ?" "Abre este cheatsheet"

  print_section "SPLITS E LAYOUT"
  print_row "$prefix + \\" "Split horizontal"
  print_row "$prefix + Enter" "Split vertical"
  print_row "$prefix + Delete" "Equaliza panes (layout tiled)"

  print_section "REDIMENSIONAR PANEIS"
  print_row "$prefix + -" "Reduz altura"
  print_row "$prefix + =" "Aumenta altura"
  print_row "$prefix + [" "Move borda para esquerda"
  print_row "$prefix + ]" "Move borda para direita"

  print_section "BUSCA E COPY MODE"
  print_row "$prefix + /" "Busca no scrollback (fuzzback)"
  print_row "$prefix + v" "Entra em copy mode"
  print_row "copy-mode + v" "Inicia selecao"
  print_row "copy-mode + V" "Seleciona linha inteira"
  print_row "copy-mode + C-v" "Seleciona bloco"
  print_row "copy-mode + y" "Copia para clipboard e sai"
  print_row "copy-mode + q" "Sai do copy mode"

  print_section "MOUSE"
  printf "  Scroll com mouse funciona no historico/copy-mode.\n"

  printf "\n%bDica:%b pressione %bq%b (no less) ou %bCtrl-c%b para fechar.\n" "$dim" "$reset" "$bold" "$reset" "$bold" "$reset"
}

if [[ ! -t 1 ]]; then
  render_cheatsheet
  exit 0
fi

if command -v less >/dev/null 2>&1; then
  render_cheatsheet | less -R
else
  render_cheatsheet
  printf '\nPressione Enter para fechar...'
  read -r _
fi
