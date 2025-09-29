#!/usr/bin/env bash
# apply_handoff_checklist.sh
# Atualiza o bloco checklists_completed de um handoff com os itens padrões para a fase atual.
# Uso:
#   ./apply_handoff_checklist.sh <handoff_file> <phase_current>
set -euo pipefail

HANDOFF_FILE="${1:?informe o arquivo de handoff}" 
PHASE="${2:?informe a fase (INITIALIZING|DESIGN|IMPLEMENTATION|QA_REVIEW|TECH_REVIEW|PM_VALIDATION|ARCHIVED)}"

if ! command -v jq >/dev/null 2>&1; then
  echo "[checklist:ERROR] Dependência 'jq' não encontrada" >&2
  exit 8
fi

if [ ! -f "$HANDOFF_FILE" ]; then
  echo "[checklist:ERROR] Handoff não encontrado: $HANDOFF_FILE" >&2
  exit 2
fi

declare -A CHECKLISTS
CHECKLISTS[INITIALIZING]="pm.initializing.scope_confirmed pm.initializing.handoff_seeded manifest.updated"
CHECKLISTS[DESIGN]="design.reviewed design.context_validated handoff.saved"
CHECKLISTS[IMPLEMENTATION]="implementation.tests_green implementation.artifacts_synced handoff.saved"
CHECKLISTS[QA_REVIEW]="qa.tests_executed qa.evidences_attached handoff.saved"
CHECKLISTS[TECH_REVIEW]="review.diff_inspected review.feedback_registered handoff.saved"
CHECKLISTS[PM_VALIDATION]="pm.validation.metrics_recorded pm.validation.archive_ready manifest.updated"
CHECKLISTS[ARCHIVED]="pm.archived.history_snapshot pm.archived.metrics_published"

if [[ -z "${CHECKLISTS[$PHASE]:-}" ]]; then
  echo "[checklist:ERROR] Fase desconhecida: $PHASE" >&2
  exit 3
fi

items_string=${CHECKLISTS[$PHASE]}
items_json=$(printf '%s' "$items_string" | tr ' ' '\n' | jq -R . | jq -s .)

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

jq --argjson items "$items_json" '.checklists_completed = ((.checklists_completed + $items) | unique)' "$HANDOFF_FILE" > "$tmp"
mv "$tmp" "$HANDOFF_FILE"

echo "[checklist] Itens adicionados para fase $PHASE: $items_string"
