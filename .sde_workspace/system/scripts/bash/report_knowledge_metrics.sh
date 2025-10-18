#!/usr/bin/env bash
# report_knowledge_metrics.sh
# Calcula métricas operacionais de resolução de conhecimento.
# Métricas emitidas:
#   - reuse_ratio: proporção de reutilização de gaps em relação a gaps criados + reutilizados
#   - priority_violations: quantidade de eventos KNOWLEDGE_PRIORITY_VIOLATION
#   - gaps_opened: quantidade de gaps recém-criados (GAP_CREATED)
# Uso:
#   ./report_knowledge_metrics.sh [--log <arquivo>] [--days <n>] [--since <ISO8601>] [--until <ISO8601>] [--raw]
# Dependências: jq
set -euo pipefail

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[knowledge-metrics:ERROR] Dependência '$1' não encontrada" >&2
    exit 8
  fi
}

usage() {
  cat <<'EOF'
Uso: report_knowledge_metrics.sh [opções]

Opções:
  --log <arquivo>    Caminho para o log (padrão: .sde_workspace/system/logs/knowledge_resolution.log)
  --days <n>         Intervalo em dias retroativos (padrão: 7) — ignorado se --since for usado
  --since <ISO8601>  Data/hora inicial (UTC) para filtrar eventos
  --until <ISO8601>  Data/hora final (UTC); padrão: agora
  --raw              Saída JSON compacta (padrão: pretty)
  --help             Mostra esta mensagem e sai

Exemplos:
  # Métricas da última semana
  report_knowledge_metrics.sh

  # Métricas desde 2025-10-01
  report_knowledge_metrics.sh --since 2025-10-01T00:00:00Z
EOF
}

require_tool jq

BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LOG_FILE="$BASE_DIR/.sde_workspace/system/logs/knowledge_resolution.log"
DAYS=7
SINCE=""
UNTIL=""
PRETTY=true

while [ $# -gt 0 ]; do
  case "$1" in
    --log)
      LOG_FILE="$2"; shift 2 ;;
    --days)
      DAYS="$2"; shift 2 ;;
    --since)
      SINCE="$2"; shift 2 ;;
    --until)
      UNTIL="$2"; shift 2 ;;
    --raw)
      PRETTY=false; shift ;;
    --help|-h)
      usage; exit 0 ;;
    --*)
      echo "[knowledge-metrics:ERROR] Opção desconhecida: $1" >&2
      usage
      exit 64 ;;
    *)
      echo "[knowledge-metrics:ERROR] Argumento inesperado: $1" >&2
      usage
      exit 64 ;;
  esac
done

if [ -z "$UNTIL" ]; then
  UNTIL="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
fi

if [ -n "$SINCE" ]; then
  if ! date -d "$SINCE" >/dev/null 2>&1; then
    echo "[knowledge-metrics:ERROR] Valor inválido para --since (use ISO8601)" >&2
    exit 65
  fi
  SINCE_ISO="$(date -u -d "$SINCE" +"%Y-%m-%dT%H:%M:%SZ")"
else
  if ! date -d "-$DAYS days" >/dev/null 2>&1; then
    echo "[knowledge-metrics:ERROR] Valor inválido para --days" >&2
    exit 65
  fi
  SINCE_ISO="$(date -u -d "$UNTIL - $DAYS days" +"%Y-%m-%dT%H:%M:%SZ")"
fi

if ! date -d "$UNTIL" >/dev/null 2>&1; then
  echo "[knowledge-metrics:ERROR] Valor inválido para --until" >&2
  exit 65
fi
UNTIL_ISO="$(date -u -d "$UNTIL" +"%Y-%m-%dT%H:%M:%SZ")"

if [ ! -f "$LOG_FILE" ] || [ ! -s "$LOG_FILE" ]; then
  EMPTY_OUTPUT=$(jq -n \
    --arg since "$SINCE_ISO" \
    --arg until "$UNTIL_ISO" \
    '{timeframe: {since: $since, until: $until}, counts: {total_events: 0, gap_created: 0, gap_referenced: 0, priority_violations: 0}, metrics: {reuse_ratio: 0, priority_violations: 0, gaps_opened: 0}}')
  if [ "$PRETTY" = true ]; then
    echo "$EMPTY_OUTPUT" | jq '.'
  else
    echo "$EMPTY_OUTPUT"
  fi
  exit 0
fi

METRICS=$(jq -s \
  --arg since "$SINCE_ISO" \
  --arg until "$UNTIL_ISO" \
  'def in_window: (.timestamp_utc >= $since and .timestamp_utc <= $until);
   map(select(in_window)) as $events |
   ($events | length) as $total |
   ($events | map(select(.event == "GAP_CREATED")) | length) as $gap_created |
   ($events | map(select(.event == "GAP_REFERENCED")) | length) as $gap_referenced |
   ($events | map(select(.event == "KNOWLEDGE_PRIORITY_VIOLATION")) | length) as $priority |
   ($gap_created + $gap_referenced) as $reuse_base |
   {
     timeframe: {since: $since, until: $until},
     counts: {
       total_events: $total,
       gap_created: $gap_created,
       gap_referenced: $gap_referenced,
       priority_violations: $priority
     },
     metrics: {
       reuse_ratio: (if $reuse_base == 0 then 0 else ($gap_referenced / $reuse_base) end),
       priority_violations: $priority,
       gaps_opened: $gap_created
     }
   }' "$LOG_FILE")

if [ "$PRETTY" = true ]; then
  echo "$METRICS" | jq '.'
else
  echo "$METRICS"
fi

exit 0
