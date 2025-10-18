#!/usr/bin/env bash
# archive_deprecated.sh
# Arquiva artefatos deprecated > 90 dias
# Uso: ./archive_deprecated.sh [--dry-run]
set -euo pipefail

BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MANIFEST="$BASE_DIR/.sde_workspace/knowledge/manifest.json"
ARCHIVE_DIR="$BASE_DIR/.sde_workspace/knowledge/archive"

require_tool() {
  command -v "$1" >/dev/null 2>&1 || { echo "[archive:ERRO] Dependência '$1' não encontrada" >&2; exit 8; }
}
require_tool jq
require_tool date

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
fi

NOW_TS=$(date +%s)
CUTOFF_DAYS=90
CUTOFF_TS=$((NOW_TS - CUTOFF_DAYS * 86400))

mkdir -p "$ARCHIVE_DIR"

archived_count=0
for path in $(jq -r '.knowledge_index.artifacts[] | select(.maturity=="deprecated") | .path' "$MANIFEST"); do
  updated_utc=$(jq -r --arg p "$path" '.knowledge_index.artifacts[] | select(.path==$p) | .updated_utc' "$MANIFEST")
  updated_ts=$(date -d "$updated_utc" +%s 2>/dev/null || echo "$NOW_TS")
  if [ "$updated_ts" -lt "$CUTOFF_TS" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo "[archive:DRY] Arquivaria: $path"
    else
      archive_path="$ARCHIVE_DIR/$(basename "$path")"
      mv "$path" "$archive_path"
      TMP=$(mktemp)
      NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
      jq --arg p "$path" --arg now "$NOW" --arg arch "$archive_path" '
        .knowledge_index.artifacts |= map(
          if .path == $p then
            .path = $arch | .archived_at = $now
          else . end
        )
      ' "$MANIFEST" > "$TMP" && mv "$TMP" "$MANIFEST"
      echo "[archive] Arquivado: $path → $archive_path"
    fi
    archived_count=$((archived_count + 1))
  fi
done

if [ "$DRY_RUN" = true ]; then
  echo "[archive] Simulação: $archived_count artefatos seriam arquivados"
else
  echo "[archive] Arquivados: $archived_count artefatos"
  echo "[archive] Execute scan_knowledge.sh para recalcular estatísticas"
fi
