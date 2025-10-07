#!/usr/bin/env bash
# report_knowledge_weekly.sh
# Gera relatório semanal consolidando métricas de resolução de conhecimento e gaps P1.
# Uso:
#   ./report_knowledge_weekly.sh [--format markdown|json] [--days <n>] [--log <arquivo>] [--gaps <dir>] [--output <arquivo>]
# Dependências: jq, report_knowledge_metrics.sh
set -euo pipefail

usage() {
  cat <<'EOF'
Uso: report_knowledge_weekly.sh [opções]

Opções:
  --format <tipo>   Saída em markdown (padrão) ou json
  --days <n>        Intervalo em dias retroativos (padrão: 7)
  --log <arquivo>   Caminho para o log de conhecimento
  --gaps <dir>      Diretório de gaps (padrão: .sde_workspace/knowledge/gaps)
  --output <arq>    Persistir relatório em arquivo
  --help            Mostra esta mensagem e sai

Exemplos:
  # Relatório markdown da última semana
  report_knowledge_weekly.sh

  # Relatório JSON dos últimos 14 dias
  report_knowledge_weekly.sh --format json --days 14
EOF
}

err() { echo "[knowledge-weekly:ERROR] $1" >&2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --format)
      FORMAT="$2"; shift 2 ;;
    --days)
      DAYS="$2"; shift 2 ;;
    --log)
      LOG_FILE="$2"; shift 2 ;;
    --gaps)
      GAPS_DIR="$2"; shift 2 ;;
    --output)
      OUTPUT="$2"; shift 2 ;;
    --help|-h)
      usage; exit 0 ;;
    --*)
      err "Opção desconhecida: $1"
      usage
      exit 64 ;;
    *)
      err "Argumento inesperado: $1"
      usage
      exit 64 ;;
  esac
done

FORMAT=${FORMAT:-markdown}
DAYS=${DAYS:-7}

BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE=${LOG_FILE:-"$BASE_DIR/.sde_workspace/system/logs/knowledge_resolution.log"}
GAPS_DIR=${GAPS_DIR:-"$BASE_DIR/.sde_workspace/knowledge/gaps"}
REPORT_METRICS_SCRIPT="$SCRIPT_DIR/report_knowledge_metrics.sh"

if [ ! -x "$REPORT_METRICS_SCRIPT" ]; then
  err "Script auxiliar report_knowledge_metrics.sh não encontrado ou sem permissão de execução"
  exit 8
fi

if ! command -v jq >/dev/null 2>&1; then
  err "Dependência 'jq' não encontrada"
  exit 8
fi

if ! date -d "-$DAYS days" >/dev/null 2>&1; then
  err "Valor inválido para --days"
  exit 65
fi

METRICS_JSON="$($REPORT_METRICS_SCRIPT --log "$LOG_FILE" --days "$DAYS" --raw)"
SINCE=$(echo "$METRICS_JSON" | jq -r '.timeframe.since')
UNTIL=$(echo "$METRICS_JSON" | jq -r '.timeframe.until')
REUSE_RATIO=$(echo "$METRICS_JSON" | jq -r '.metrics.reuse_ratio')
PRIORITY_VIOLATIONS=$(echo "$METRICS_JSON" | jq -r '.metrics.priority_violations')
GAPS_OPENED=$(echo "$METRICS_JSON" | jq -r '.metrics.gaps_opened')
TOTAL_EVENTS=$(echo "$METRICS_JSON" | jq -r '.counts.total_events')

if [ -d "$GAPS_DIR" ] && compgen -G "$GAPS_DIR"/*.json >/dev/null 2>&1; then
  GAPS_JSON=$(jq -s '
    map(select((.priority // "") | ascii_upcase == "P1" and (.status // "open" | ascii_downcase) == "open"))
    | map({gap_id, priority, impact, owner, status, timestamp_utc, query})
  ' "$GAPS_DIR"/*.json)
else
  GAPS_JSON="[]"
fi

if [ "$FORMAT" = "json" ]; then
  REPORT=$(jq -n --argjson metrics "$METRICS_JSON" --argjson gaps "$GAPS_JSON" '{
    timeframe: $metrics.timeframe,
    counts: $metrics.counts,
    metrics: $metrics.metrics,
    gaps_p1_open: $gaps
  }')
else
  REUSE_FMT=$(LC_NUMERIC=C printf '%.2f' "$REUSE_RATIO")
  REPORT=$( 
    {
  printf '# Relatório Semanal de Conhecimento (%s → %s)\n\n' "$SINCE" "$UNTIL"
  printf '## Métricas (últimos %s dias)\n' "$DAYS"
  printf -- '- Eventos analisados: %s\n' "$TOTAL_EVENTS"
  printf -- '- reuse_ratio: %s\n' "$REUSE_FMT"
  printf -- '- priority_violations: %s\n' "$PRIORITY_VIOLATIONS"
  printf -- '- gaps_opened: %s\n\n' "$GAPS_OPENED"
  printf '## Gaps P1 em aberto\n'
      GAPS_COUNT=$(echo "$GAPS_JSON" | jq 'length')
      if [ "$GAPS_COUNT" -eq 0 ]; then
        printf 'Nenhum gap P1 em aberto no período.\n'
      else
  printf -- '| Gap ID | Owner | Impacto | Status | Aberto em | Query |\n'
  printf -- '| --- | --- | --- | --- | --- | --- |\n'
        echo "$GAPS_JSON" | jq -r '.[] | "| \(.gap_id) | \(.owner // \"-\") | \(.impact // \"-\") | \(.status // \"-\") | \(.timestamp_utc // \"-\") | \((.query // \"-\") | gsub("\\n"; " ") | gsub("[|]"; "\\\\|") ) |"'
      fi
    }
  )
fi

if [ -n "${OUTPUT:-}" ]; then
  printf '%s' "$REPORT" > "$OUTPUT"
  printf '[knowledge-weekly] Relatório salvo em %s\n' "$OUTPUT" >&2
else
  printf '%s' "$REPORT"
fi

exit 0
