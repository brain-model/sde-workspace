#!/usr/bin/env bash
# validate_manifest.sh
# Valida o manifest de conhecimento: órfãos, drift, schema, tags
# Uso: ./validate_manifest.sh
set -euo pipefail

BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MANIFEST="$BASE_DIR/.sde_workspace/knowledge/manifest.json"
SCHEMA="$BASE_DIR/.sde_workspace/system/schemas/knowledge_manifest.schema.json"
TAGS_REGISTRY="$BASE_DIR/.sde_workspace/knowledge/internal/references/tags_registry.json"

require_tool() {
  command -v "$1" >/dev/null 2>&1 || { echo "[validate:ERRO] Dependência '$1' não encontrada" >&2; exit 8; }
}
require_tool jq

# Validação de schema
if command -v yajsv >/dev/null 2>&1; then
  yajsv -s "$SCHEMA" "$MANIFEST" || { echo "[validate:ERRO] Falha de schema"; exit 3; }
else
  echo "[validate:WARN] YAJSV não encontrado - pulando validação formal de schema"
fi

# Checagem de órfãos
for path in $(jq -r '.knowledge_index.artifacts[].path' "$MANIFEST"); do
  [ -f "$path" ] || { echo "[validate:ERRO] Órfão: $path não existe"; exit 4; }
  hash=$(jq -r --arg p "$path" '.knowledge_index.artifacts[] | select(.path==$p) | .hash' "$MANIFEST")
  actual="sha256:$(sha256sum "$path" | awk '{print $1}')"
  [ "$hash" = "$actual" ] || { echo "[validate:ERRO] Hash mismatch: $path"; exit 5; }
  echo "[validate] $path OK"
  # Checagem de tags
  for tag in $(jq -r --arg p "$path" '.knowledge_index.artifacts[] | select(.path==$p) | .tags[]' "$MANIFEST"); do
    jq -e --arg t "$tag" '.tags[] | select(.tag==$t)' "$TAGS_REGISTRY" >/dev/null || { echo "[validate:WARN] Tag desconhecida: $tag"; }
  done
  # Checagem de rastreabilidade
  gaps=$(jq -r --arg p "$path" '.knowledge_index.artifacts[] | select(.path==$p) | .linked.gaps[]?' "$MANIFEST")
  decisions=$(jq -r --arg p "$path" '.knowledge_index.artifacts[] | select(.path==$p) | .linked.decisions[]?' "$MANIFEST")
  if [ -z "$gaps" ] && [ -z "$decisions" ]; then
    echo "[validate:ERRO] Artefato sem rastreabilidade: $path"; exit 6;
  fi
  # Checagem de maturidade
  maturity=$(jq -r --arg p "$path" '.knowledge_index.artifacts[] | select(.path==$p) | .maturity' "$MANIFEST")
  case "$maturity" in
    draft|review|stable|deprecated) :;;
    *) echo "[validate:ERRO] Maturidade inválida: $maturity ($path)"; exit 7;;
  esac
  # Checagem de supersede
  supersedes=$(jq -r --arg p "$path" '.knowledge_index.artifacts[] | select(.path==$p) | .supersedes' "$MANIFEST")
  if [ "$supersedes" != "null" ] && [ ! -f "$supersedes" ]; then
    echo "[validate:ERRO] Supersede aponta para arquivo inexistente: $supersedes"; exit 8;
  fi
  superseded_by=$(jq -r --arg p "$path" '.knowledge_index.artifacts[] | select(.path==$p) | .superseded_by' "$MANIFEST")
  if [ "$superseded_by" != "null" ] && [ ! -f "$superseded_by" ]; then
    echo "[validate:ERRO] Superseded_by aponta para arquivo inexistente: $superseded_by"; exit 9;
  fi

done

echo "[validate] Manifesto válido e íntegro."
