#!/usr/bin/env bash
# report_knowledge_health.sh
# Gera relatório de saúde do manifest de conhecimento
# Uso: ./report_knowledge_health.sh [--format md|json]
set -euo pipefail

BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MANIFEST="$BASE_DIR/.sde_workspace/knowledge/manifest.json"

require_tool() {
  command -v "$1" >/dev/null 2>&1 || { echo "[health:ERRO] Dependência '$1' não encontrada" >&2; exit 8; }
}
require_tool jq

FORMAT="${1:-md}"

total=$(jq '.knowledge_index.artifacts | length' "$MANIFEST")
internal=$(jq '.knowledge_index.stats.internal' "$MANIFEST")
external_curated=$(jq '.knowledge_index.stats.external_curated' "$MANIFEST")
external_raw=$(jq '.knowledge_index.stats.external_raw' "$MANIFEST")
draft=$(jq '.knowledge_index.stats.maturity.draft' "$MANIFEST")
review=$(jq '.knowledge_index.stats.maturity.review' "$MANIFEST")
stable=$(jq '.knowledge_index.stats.maturity.stable' "$MANIFEST")
deprecated=$(jq '.knowledge_index.stats.maturity.deprecated' "$MANIFEST")
archived=$(jq '.knowledge_index.stats.archived' "$MANIFEST")
orphans=$(jq '.metrics.orphan_artifacts' "$MANIFEST")
drift=$(jq '.metrics.drift_incidents' "$MANIFEST")
hash_mismatch=$(jq '.metrics.hash_mismatch_rate' "$MANIFEST")
index_latency=$(jq '.metrics.index_latency_avg' "$MANIFEST")
last_scan=$(jq -r '.metrics.last_scan_utc' "$MANIFEST")

if [ "$FORMAT" = "json" ]; then
  jq -n \
    --argjson total "$total" \
    --argjson internal "$internal" \
    --argjson external_curated "$external_curated" \
    --argjson external_raw "$external_raw" \
    --argjson draft "$draft" \
    --argjson review "$review" \
    --argjson stable "$stable" \
    --argjson deprecated "$deprecated" \
    --argjson archived "$archived" \
    --argjson orphans "$orphans" \
    --argjson drift "$drift" \
    --argjson hash_mismatch "$hash_mismatch" \
    --argjson index_latency "$index_latency" \
    --arg last_scan "$last_scan" \
    '{
      total_artifacts: $total,
      sources: {internal: $internal, external_curated: $external_curated, external_raw: $external_raw},
      maturity: {draft: $draft, review: $review, stable: $stable, deprecated: $deprecated},
      archived: $archived,
      quality: {orphans: $orphans, drift_incidents: $drift, hash_mismatch_rate: $hash_mismatch},
      performance: {index_latency_avg: $index_latency},
      last_scan_utc: $last_scan
    }'
else
  cat <<EOF
# Relatório de Saúde do Conhecimento

**Data:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Último Scan:** $last_scan

## Artefatos

- **Total:** $total
- **Internos:** $internal
- **Externos Curados:** $external_curated
- **Externos Raw:** $external_raw

## Maturidade

- **Draft:** $draft
- **Review:** $review
- **Stable:** $stable
- **Deprecated:** $deprecated
- **Arquivados:** $archived

## Qualidade

- **Órfãos:** $orphans
- **Drift Incidents:** $drift
- **Hash Mismatch Rate:** $hash_mismatch

## Performance

- **Latência Média de Indexação:** ${index_latency}s

---
*Gerado por report_knowledge_health.sh*
EOF
fi
