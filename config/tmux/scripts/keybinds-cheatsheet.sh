#!/usr/bin/env bash
set -euo pipefail

prefix="$(tmux show-option -gqv prefix 2>/dev/null || echo 'C-b')"

# -- Colors (16-color ANSI only, same style as window-picker.sh) --------
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  R=$'\033[0m'
  BD=$'\033[1m'
  DIM=$'\033[2m'
  IT=$'\033[3m'
  CY=$'\033[36m'       # cyan
  GR=$'\033[32m'       # green
  YE=$'\033[33m'       # yellow
  MG=$'\033[35m'       # magenta
  BL=$'\033[34m'       # blue
  WH=$'\033[97m'       # bright white
  GY=$'\033[90m'       # dark grey
else
  R='' BD='' DIM='' IT='' CY='' GR='' YE='' MG='' BL='' WH='' GY=''
fi

# -- Helpers ------------------------------------------------------------
W=72  # content width

hline() {
  printf '%b%s%b\n' "${DIM}${CY}" "$(printf '%*s' "$W" '' | tr ' ' '-')" "$R"
}

title_hline() {
  printf '%b%s%b\n' "${BD}${CY}" "$(printf '%*s' "$W" '' | tr ' ' '=')" "$R"
}

section() {
  local label="$1" color="${2:-$MG}"
  printf '\n%b  %s%b\n' "${BD}${color}" "$label" "$R"
  printf '%b  %s%b\n' "${DIM}${color}" "$(printf '%*s' "$((${#label}))" '' | tr ' ' '-')" "$R"
}

krow() {
  local key="$1" desc="$2"
  local kw=18
  printf '  %b%-*s%b  %b%s%b\n' "${GR}${BD}" "$kw" "[$key]" "$R" "${WH}" "$desc" "$R"
}

note() {
  printf '  %b%s%b\n' "${IT}${GY}" "$1" "$R"
}

# -- Render -------------------------------------------------------------
render_cheatsheet() {
  echo
  title_hline
  printf '%b%*s%b\n' "${BD}${CY}" "$(( (W + 26) / 2 ))" "TMUX KEYBINDS CHEATSHEET" "$R"
  printf '%b%*s%b\n' "${DIM}${WH}" "$(( (W + 14 + ${#prefix}) / 2 ))" "prefix = $prefix" "$R"
  title_hline

  section "JANELAS & PAINEIS" "$MG"
  krow "prefix c"     "Nova janela (dir atual)"
  krow "prefix w"     "Seletor de janelas (fzf)"
  krow "prefix x"     "Fechar painel atual"
  krow "prefix m"     "Maximizar / restaurar painel"
  krow "prefix P"     "Definir label manual do painel"
  krow "prefix r"     "Recarregar tmux.conf"
  krow "prefix T"     "Menu de temas"
  krow "prefix ?"     "Abrir este cheatsheet"

  hline
  section "SPLITS & LAYOUT" "$BL"
  krow "prefix \\"    "Split horizontal  |"
  krow "prefix Enter" "Split vertical    --"
  krow "prefix Del"   "Equalizar paineis (tiled)"

  hline
  section "REDIMENSIONAR" "$YE"
  krow "prefix -"     "Reduzir altura"
  krow "prefix ="     "Aumentar altura"
  krow "prefix ["     "Mover borda p/ esquerda"
  krow "prefix ]"     "Mover borda p/ direita"

  hline
  section "NAVEGACAO ENTRE PAINEIS" "$GR"
  krow "Ctrl-h / Ctrl-j"  "Ir para painel da esq / abaixo"
  krow "Ctrl-k / Ctrl-l"  "Ir para painel de cima / dir"
  note "Funciona inclusive dentro do copy-mode."

  hline
  section "BUSCA & COPY MODE" "$CY"
  krow "prefix /"     "Busca no scrollback (fuzzback)"
  krow "prefix v"     "Entrar no copy mode"
  echo
  krow "v"            "Iniciar selecao"
  krow "V"            "Selecionar linha inteira"
  krow "Ctrl-v"       "Alternar selecao em bloco"
  krow "y"            "Copiar para clipboard e sair"
  krow "Esc"          "Limpar selecao"
  krow "q"            "Sair do copy mode"
  note "Teclas acima funcionam dentro do copy-mode (vi)."

  hline
  section "MOUSE" "$GY"
  note "Scroll com mouse funciona no historico/copy-mode."
  note "Drag seleciona e copia automaticamente."

  echo
  title_hline
  printf '%b%*s%b\n' "${DIM}${WH}" "$(( (W + 22) / 2 ))" "Pressione  q  para sair" "$R"
  title_hline
  echo
}

# -- Output -------------------------------------------------------------
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
