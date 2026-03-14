#!/bin/bash
# scripts/retry-apply.sh
#
# Retries `terraform apply` até a OCI liberar capacidade ARM.
# Diferencia erros de capacidade, erros de rede e erros de código —
# apenas os dois primeiros continuam em loop; erros de código abortam.

# ── CONFIGURAÇÃO ─────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
LOG_FILE="$SCRIPT_DIR/../retry-apply.log"

MAX_HOURS=48       # Desiste após este tempo mesmo sem sucesso
SLEEP_CAPACITY=300 # 5 min entre tentativas quando sem capacidade ARM
SLEEP_NETWORK=600  # 10 min entre tentativas quando sem internet
# ─────────────────────────────────────────────────────────────────────────

# ── CORES ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── ESTADO GLOBAL ─────────────────────────────────────────────────────────
START_TIME=$(date +%s)
ATTEMPT=1

# ── HELPERS ───────────────────────────────────────────────────────────────
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  echo -e "$msg"
  echo -e "$msg" >> "$LOG_FILE"
}

elapsed_minutes() {
  echo $(( ($(date +%s) - START_TIME) / 60 ))
}

on_exit() {
  local mins
  mins=$(elapsed_minutes)
  log ""
  log "Script encerrado — tentativas: $ATTEMPT | tempo: ${mins} min | log: $LOG_FILE"
}

on_interrupt() {
  echo -e "\n${YELLOW}Interrompido pelo usuário.${NC}"
  exit 130
}

# ── VALIDAÇÕES ────────────────────────────────────────────────────────────
if [[ ! -d "$TERRAFORM_DIR" ]]; then
  echo -e "${RED}Erro: diretório terraform não encontrado em $TERRAFORM_DIR${NC}" >&2
  exit 1
fi

if ! command -v terraform &>/dev/null; then
  echo -e "${RED}Erro: terraform não encontrado no PATH${NC}" >&2
  exit 1
fi

# ── SETUP ─────────────────────────────────────────────────────────────────
cd "$TERRAFORM_DIR"

MAX_SECONDS=$(( MAX_HOURS * 3600 ))

trap on_exit EXIT
trap on_interrupt INT TERM

echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║         n8n-infra — OCI ARM Capacity Retry           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
log "Terraform dir : $TERRAFORM_DIR"
log "Log           : $LOG_FILE"
log "Timeout       : ${MAX_HOURS}h"
log "Pressione CTRL+C para cancelar."
log "---"

# ── LOOP PRINCIPAL ────────────────────────────────────────────────────────
while true; do

  # Verifica timeout global
  if (( $(date +%s) - START_TIME >= MAX_SECONDS )); then
    log "${RED}Timeout de ${MAX_HOURS}h atingido sem sucesso. Encerrando.${NC}"
    exit 1
  fi

  log "${CYAN}Tentativa #$ATTEMPT${NC}"

  # Executa terraform apply e captura saída completa
  TF_OUTPUT=$(terraform apply -auto-approve 2>&1)
  EXIT_CODE=$?

  # Grava saída no log
  {
    echo "── Saída tentativa #$ATTEMPT ──"
    echo "$TF_OUTPUT"
    echo "── Fim saída ──"
    echo ""
  } >> "$LOG_FILE"

  # ── SUCESSO ─────────────────────────────────────────────────────────────
  if [[ $EXIT_CODE -eq 0 ]]; then
    echo "$TF_OUTPUT" | tail -20
    printf '\a\a\a'  # bell x3
    echo -e "\n${GREEN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║       SUCESSO! VMs provisionadas na OCI!             ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    log "VMs criadas após $ATTEMPT tentativa(s) e $(elapsed_minutes) minuto(s)."
    exit 0
  fi

  # ── SEM CAPACIDADE ARM ──────────────────────────────────────────────────
  if echo "$TF_OUTPUT" | grep -q "Out of host capacity"; then
    log "${YELLOW}Sem capacidade ARM disponível. Próxima tentativa em $(( SLEEP_CAPACITY / 60 )) min...${NC}"
    sleep "$SLEEP_CAPACITY"

  # ── ERRO DE REDE / INTERNET ─────────────────────────────────────────────
  elif echo "$TF_OUTPUT" | grep -qiE "timeout|connection refused|no such host|network is unreachable|EOF|i/o timeout|dial tcp|TLS handshake"; then
    log "${YELLOW}Falha de rede ou internet. Próxima tentativa em $(( SLEEP_NETWORK / 60 )) min...${NC}"
    sleep "$SLEEP_NETWORK"

  # ── ERRO DE CÓDIGO / CONFIGURAÇÃO ───────────────────────────────────────
  # Não faz sentido tentar novamente — pode ser bug no .tf, variável errada, etc.
  else
    echo ""
    echo "$TF_OUTPUT" | grep -E "^│|Error" | head -20
    echo ""
    log "${RED}Erro desconhecido (não é capacidade nem rede). Abortando para evitar loop infinito.${NC}"
    log "Verifique o log completo: $LOG_FILE"
    exit "$EXIT_CODE"
  fi

  (( ATTEMPT++ ))

done
