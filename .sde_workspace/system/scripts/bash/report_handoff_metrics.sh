#!/usr/bin/env bash
# report_handoff_metrics.sh
# Gera um relatório de métricas básicas a partir de um arquivo de handoff estruturado.
# Uso:
#   ./report_handoff_metrics.sh [handoff_file] [output_markdown]
# Se nenhum arquivo for informado, utiliza `.sde_workspace/system/handoffs/latest.json`.
# Se nenhum output for informado, imprime no stdout.
set -euo pipefail

HANDOFF_FILE="${1:-.sde_workspace/system/handoffs/latest.json}"
OUTPUT_FILE="${2:-}" 

if ! command -v jq >/dev/null 2>&1; then
  echo "[metrics:ERROR] Dependência 'jq' não encontrada" >&2
  exit 8
fi

if [ ! -f "$HANDOFF_FILE" ]; then
  echo "[metrics:ERROR] Handoff não encontrado: $HANDOFF_FILE" >&2
  exit 2
fi

handoff_id=$(jq -r '.meta.handoff_id' "$HANDOFF_FILE")
phase_current=$(jq -r '.meta.phase_current' "$HANDOFF_FILE")
phase_next=$(jq -r '.meta.phase_next' "$HANDOFF_FILE")
version=$(jq -r '.meta.version' "$HANDOFF_FILE")
clarification_requests=$(jq -r '.quality_signals.clarification_requests' "$HANDOFF_FILE")
context_score=$(jq -r '.quality_signals.context_completeness_score' "$HANDOFF_FILE")
open_questions=$(jq -r '.quality_signals.open_questions' "$HANDOFF_FILE")
artifact_mismatch=$(jq -r '.quality_signals.artifact_hash_mismatch' "$HANDOFF_FILE")

if [ "$version" -gt 1 ]; then
  artifacts_new=$(jq -r '.delta_summary.since_previous_handoff.artifacts_new' "$HANDOFF_FILE")
  artifacts_modified=$(jq -r '.delta_summary.since_previous_handoff.artifacts_modified' "$HANDOFF_FILE")
else
  artifacts_new="N/A"
  artifacts_modified="N/A"
fi

report=$(cat <<EOF
# Relatório de Métricas do Handoff

- **Handoff ID:** $handoff_id
- **Fase Atual → Próxima:** $phase_current → $phase_next
- **Versão:** $version
- **Pedidos de Clarificação:** $clarification_requests
- **Context Completeness Score:** $context_score
- **Perguntas Abertas:** $open_questions
- **Hash Mismatch Detectado:** $artifact_mismatch
- **Artefatos Novos (desde anterior):** $artifacts_new
- **Artefatos Modificados (desde anterior):** $artifacts_modified

> Gerado por `report_handoff_metrics.sh` em $(date -u +"%Y-%m-%dT%H:%M:%SZ").
EOF
)

if [ -n "$OUTPUT_FILE" ]; then
  printf "%s\n" "$report" > "$OUTPUT_FILE"
  echo "[metrics] Relatório salvo em $OUTPUT_FILE"
else
  printf "%s\n" "$report"
fi
