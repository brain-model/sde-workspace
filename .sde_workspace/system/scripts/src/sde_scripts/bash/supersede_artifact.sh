#!/usr/bin/env bash
# supersede_artifact.sh
# Marca um artefato como deprecated e registra seu substituto
# Uso: ./supersede_artifact.sh <artefato_antigo> <artefato_novo>
set -euo pipefail

BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MANIFEST="$BASE_DIR/.sde_workspace/knowledge/manifest.json"

require_tool() {
  command -v "$1" >/dev/null 2>&1 || { echo "[supersede:ERRO] Dependência '$1' não encontrada" >&2; exit 8; }
}
require_tool jq

if [ $# -lt 2 ]; then
  echo "Uso: $0 <artefato_antigo> <artefato_novo>" >&2
  exit 1
fi

OLD_PATH="$1"
NEW_PATH="$2"

if [ ! -f "$OLD_PATH" ]; then
  echo "[supersede:ERRO] Artefato antigo não encontrado: $OLD_PATH" >&2
  exit 2
fi

if [ ! -f "$NEW_PATH" ]; then
  echo "[supersede:ERRO] Artefato novo não encontrado: $NEW_PATH" >&2
  exit 3
fi

if ! jq -e --arg p "$OLD_PATH" '.knowledge_index.artifacts[] | select(.path==$p)' "$MANIFEST" >/dev/null; then
  echo "[supersede:ERRO] Artefato antigo não indexado: $OLD_PATH" >&2
  exit 4
fi

if ! jq -e --arg p "$NEW_PATH" '.knowledge_index.artifacts[] | select(.path==$p)' "$MANIFEST" >/dev/null; then
  echo "[supersede:ERRO] Artefato novo não indexado: $NEW_PATH" >&2
  exit 5
fi

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP=$(mktemp)

jq --arg old "$OLD_PATH" --arg new "$NEW_PATH" --arg now "$NOW" '
  .knowledge_index.artifacts |= map(
    if .path == $old then
      .maturity = "deprecated" | .superseded_by = $new | .updated_utc = $now | .authoritative = false
    elif .path == $new then
      .supersedes = $old | .updated_utc = $now
    else . end
  )
' "$MANIFEST" > "$TMP" && mv "$TMP" "$MANIFEST"

echo "[supersede] $OLD_PATH → deprecated, substituído por $NEW_PATH"
echo "[supersede] Execute scan_knowledge.sh para recalcular estatísticas"
