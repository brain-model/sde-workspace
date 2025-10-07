#!/usr/bin/env bash
# promote_artifact.sh
# Promove a maturidade de um artefato no manifest de conhecimento
# Uso: ./promote_artifact.sh <path> <nova_maturidade>
# Maturidades: draft → review → stable → deprecated
set -euo pipefail

BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MANIFEST="$BASE_DIR/.sde_workspace/knowledge/manifest.json"

require_tool() {
  command -v "$1" >/dev/null 2>&1 || { echo "[promote:ERRO] Dependência '$1' não encontrada" >&2; exit 8; }
}
require_tool jq

if [ $# -lt 2 ]; then
  echo "Uso: $0 <path> <nova_maturidade>" >&2
  exit 1
fi

PATH_ARTIFACT="$1"
NEW_MATURITY="$2"

case "$NEW_MATURITY" in
  draft|review|stable|deprecated) :;;
  *) echo "[promote:ERRO] Maturidade inválida: $NEW_MATURITY" >&2; exit 2;;
esac

if [ ! -f "$PATH_ARTIFACT" ]; then
  echo "[promote:ERRO] Arquivo não encontrado: $PATH_ARTIFACT" >&2
  exit 3
fi

if ! jq -e --arg p "$PATH_ARTIFACT" '.knowledge_index.artifacts[] | select(.path==$p)' "$MANIFEST" >/dev/null; then
  echo "[promote:ERRO] Artefato não indexado: $PATH_ARTIFACT" >&2
  exit 4
fi

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP=$(mktemp)

jq --arg p "$PATH_ARTIFACT" --arg mat "$NEW_MATURITY" --arg now "$NOW" '
  .knowledge_index.artifacts |= map(
    if .path == $p then
      .maturity = $mat | .updated_utc = $now
    else . end
  )
' "$MANIFEST" > "$TMP" && mv "$TMP" "$MANIFEST"

echo "[promote] Artefato $PATH_ARTIFACT promovido para $NEW_MATURITY"
echo "[promote] Execute scan_knowledge.sh para recalcular estatísticas"
