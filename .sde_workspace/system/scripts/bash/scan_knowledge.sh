#!/usr/bin/env bash
# scan_knowledge.sh
# Scanner incremental para indexação e atualização do manifest de conhecimento
# Uso: ./scan_knowledge.sh [--update] [--report]
# Dependências: jq, sha256sum, yq
set -euo pipefail

BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
KNOWLEDGE_DIR="$BASE_DIR/.sde_workspace/knowledge"
MANIFEST="$KNOWLEDGE_DIR/manifest.json"
TAGS_REGISTRY="$KNOWLEDGE_DIR/internal/references/tags_registry.json"
HEADER_TEMPLATE="$KNOWLEDGE_DIR/internal/templates/metadata_header.md"

require_tool() {
  command -v "$1" >/dev/null 2>&1 || { echo "[scan:ERRO] Dependência '$1' não encontrada" >&2; exit 8; }
}
require_tool jq
require_tool sha256sum
require_tool yq

ts_now() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

scan_dir() {
  local dir="$1"
  find "$dir" -type f -name '*.md' -o -name '*.json' 2>/dev/null
}

parse_yaml_header() {
  local file="$1"
  yq eval 'select(document_index == 0)' "$file" 2>/dev/null || echo "{}"
}

calc_hash() {
  local file="$1"
  sha256sum "$file" | awk '{print $1}'
}

update_manifest() {
  local artifacts_json="$1"
  local now
  now="$(ts_now)"
  jq \
    --arg now "$now" \
    --argjson artifacts "$artifacts_json" \
    '.generatedAt = $now | .knowledge_index.artifacts = $artifacts | .metrics.last_scan_utc = $now | .metrics.scan_runs += 1' \
    "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
}

main() {
  local artifacts=()
  for file in $(scan_dir "$KNOWLEDGE_DIR/internal"; scan_dir "$KNOWLEDGE_DIR/external"); do
    if [[ "$file" == *.md ]]; then
      header=$(awk '/^---/{flag=!flag;next} flag' "$file" | yq eval '.' - 2>/dev/null || echo "{}")
      if [[ "$header" == "{}" ]]; then continue; fi
      id=$(echo "$header" | yq eval '.id' -)
      type=$(echo "$header" | yq eval '.type' -)
      maturity=$(echo "$header" | yq eval '.maturity' -)
      tags=$(echo "$header" | yq eval '.tags' - | jq -c .)
      created_by=$(echo "$header" | yq eval '.created_by' -)
      source_origin=$(echo "$header" | yq eval '.source_origin' -)
      created_utc=$(echo "$header" | yq eval '.created_utc' -)
      updated_utc=$(echo "$header" | yq eval '.updated_utc' -)
      linked_gaps=$(echo "$header" | yq eval '.linked_gaps' - | jq -c .)
      linked_decisions=$(echo "$header" | yq eval '.linked_decisions' - | jq -c .)
      supersedes=$(echo "$header" | yq eval '.supersedes' -)
      superseded_by=$(echo "$header" | yq eval '.superseded_by' -)
      hash="sha256:$(calc_hash "$file")"
      size=$(stat -c %s "$file")
      artifacts+=("$(jq -n --arg path "$file" --arg type "$type" --argjson tags "$tags" --arg maturity "$maturity" --arg hash "$hash" --argjson size "$size" --arg created_utc "$created_utc" --arg updated_utc "$updated_utc" --arg created_by "$created_by" --arg source_origin "$source_origin" --arg authoritative true --argjson linked_gaps "$linked_gaps" --argjson linked_decisions "$linked_decisions" --arg supersedes "$supersedes" --arg superseded_by "$superseded_by" '{path: $path, type: $type, tags: $tags, maturity: $maturity, hash: $hash, size: $size|tonumber, created_utc: $created_utc, updated_utc: $updated_utc, created_by: $created_by, source_origin: $source_origin, authoritative: true, linked: {gaps: $linked_gaps, decisions: $linked_decisions}, supersedes: $supersedes, superseded_by: $superseded_by, archived_at: null, removed_at: null}')")
    fi
  done
  artifacts_json="[$(IFS=,; echo "${artifacts[*]}")]"
  update_manifest "$artifacts_json"
  echo "[scan] Manifest atualizado com $(echo "$artifacts_json" | jq length) artefatos."
}

main "$@"
