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
  find "$dir" \( -name '*.md' -o -name '*.json' \) -type f 2>/dev/null
}

# Extrai somente o PRIMEIRO bloco YAML (entre as duas primeiras linhas ---) para evitar
# interferência de exemplos no corpo do documento.
extract_header_block() {
  local file="$1"
  # Garante que começa com '---' antes de tentar extrair
  if ! head -1 "$file" | grep -q '^---'; then
    return 1
  fi
  awk 'NR==1 && /^---/{hdr=1;next} hdr && /^---$/{exit} hdr {print}' "$file"
}

should_ignore_file() {
  local f="$1"
  # Padrões ignorados: templates de metadata, conteúdo interno de repositórios registrados (tooling), assets binários md auxiliares
  if [[ "$f" =~ /internal/templates/ ]]; then return 0; fi
  if [[ "$f" =~ /tooling/gitops/ci-knife/ ]]; then return 0; fi
  if [[ "$f" =~ /tooling/gitops/examples/cicd-tagging-api/ ]]; then return 0; fi
  if [[ "$f" =~ /knowledge/external/vendor-docs/ ]]; then return 0; fi
  return 1
}

calc_hash() {
  local file="$1"
  sha256sum "$file" | awk '{print $1}'
}

update_manifest() {
  local artifacts_file="$1"
  local files_file="$2"
  local stats_json="$3"
  local ki_stats_json="$4"
  local maturity_distribution_json="$5"
  local now
  now="$(ts_now)"
  jq \
    --arg now "$now" \
    --slurpfile artifacts "$artifacts_file" \
    --slurpfile filesArr "$files_file" \
    --argjson statsObj "$stats_json" \
    --argjson kiStats "$ki_stats_json" \
    --argjson maturityDist "$maturity_distribution_json" \
    '.generatedAt = $now
     | .files = ($filesArr[0] // [])
     | .statistics = $statsObj
     | .knowledge_index.artifacts = ($artifacts[0] // [])
     | .knowledge_index.stats = $kiStats
     | .knowledge_index.gaps = ( .knowledge_index.gaps // [] | map( if type=="object" and has("id") then .id else . end ) )
     | .metrics.last_scan_utc = $now
     | .metrics.scan_runs += 1
     | .metrics.maturity_distribution = $maturityDist' \
    "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
}

main() {
  local artifacts=()
    local artifacts_raw=()
    local files_raw=()
    local total_size=0
    declare -A count_type
    declare -A count_maturity
    local internal_count=0 external_curated_count=0 external_raw_count=0 archived_count=0

    while IFS= read -r file; do
    # Apenas .md
    [[ "$file" != *.md ]] && continue
    if should_ignore_file "$file"; then
      continue
    fi
    header_block=$(extract_header_block "$file" || true)
    [[ -z "$header_block" ]] && continue
    # Validar se contém campo id:
    if ! grep -q '^id:' <<< "$header_block"; then continue; fi
    # Converter para JSON com yq; se falhar, pula.
    header=$(echo "$header_block" | yq eval '.' - 2>/dev/null || echo '{}')
    [[ "$header" == "{}" ]] && continue
    id=$(echo "$header" | yq eval -o=json '.id' - | tr -d '"')
    type=$(echo "$header" | yq eval -o=json '.type' - | tr -d '"')
    maturity=$(echo "$header" | yq eval -o=json '.maturity' - | tr -d '"')
    tags=$(echo "$header" | yq eval -o=json '.tags' - 2>/dev/null || echo '[]')
    created_by=$(echo "$header" | yq eval -o=json '.created_by' - | tr -d '"')
    source_origin=$(echo "$header" | yq eval -o=json '.source_origin' - | tr -d '"')
    created_utc=$(echo "$header" | yq eval -o=json '.created_utc' - | tr -d '"')
    updated_utc=$(echo "$header" | yq eval -o=json '.updated_utc' - | tr -d '"')
    linked_gaps=$(echo "$header" | yq eval -o=json '.linked_gaps' - 2>/dev/null || echo '[]')
    linked_decisions=$(echo "$header" | yq eval -o=json '.linked_decisions' - 2>/dev/null || echo '[]')
    supersedes=$(echo "$header" | yq eval -o=json '.supersedes' - | tr -d '"')
    superseded_by=$(echo "$header" | yq eval -o=json '.superseded_by' - | tr -d '"')
    hash="sha256:$(calc_hash "$file")"
    size=$(stat -c %s "$file")
    # Incrementa contadores
    count_type[$type]=$(( ${count_type[$type]:-0} + 1 ))
    count_maturity[$maturity]=$(( ${count_maturity[$maturity]:-0} + 1 ))
    total_size=$(( total_size + size ))
    if [[ "$source_origin" == "internal" ]]; then
      internal_count=$(( internal_count + 1 ))
    elif [[ "$source_origin" == "external_curated" ]]; then
      external_curated_count=$(( external_curated_count + 1 ))
    else
      external_raw_count=$(( external_raw_count + 1 ))
    fi
  # Artifact (schema knowledge_index.artifacts)
  artifacts_raw+=("$(jq -n --arg path "$file" --arg type "$type" --argjson tags "$tags" --arg maturity "$maturity" --arg hash "$hash" --argjson size "$size" --arg created_utc "$created_utc" --arg updated_utc "$updated_utc" --arg created_by "$created_by" --arg source_origin "$source_origin" --argjson linked_gaps "$linked_gaps" --argjson linked_decisions "$linked_decisions" --arg supersedes "$supersedes" --arg superseded_by "$superseded_by" '{path: $path, type: $type, tags: $tags, maturity: $maturity, hash: $hash, size: ($size|tonumber), created_utc: $created_utc, updated_utc: $updated_utc, created_by: $created_by, source_origin: $source_origin, authoritative: true, linked: {gaps: $linked_gaps, decisions: $linked_decisions}, supersedes: $supersedes, superseded_by: $superseded_by, archived_at: null, removed_at: null}')")
  # Files entry (schema .files)
  # title heurística: basename sem extensão
  base_name=$(basename "$file")
  title="${base_name%.*}"
  files_raw+=("$(jq -n --arg path "$file" --arg checksum "$hash" --argjson size "$size" --arg lastModified "$updated_utc" --arg id "$id" --arg title "$title" --arg category "$type" --arg created "$created_utc" --arg updated "$updated_utc" --arg source "$source_origin" --argjson tags "$tags" '{path:$path, checksum:$checksum, size:($size|tonumber), lastModified:$lastModified, metadata:{id:$id, title:$title, category:$category, created:$created, updated:$updated, source:$source, tags:$tags}}')")
  done < <(scan_dir "$KNOWLEDGE_DIR/internal"; scan_dir "$KNOWLEDGE_DIR/external")
  # Build JSON arrays
  artifacts_tmp=$(mktemp)
  files_tmp=$(mktemp)
  trap 'rm -f "$artifacts_tmp" "$files_tmp"' EXIT

  if ((${#artifacts_raw[@]})); then
    printf '%s\n' "${artifacts_raw[@]}" | jq -s '.' > "$artifacts_tmp"
  else
    echo '[]' > "$artifacts_tmp"
  fi

  if ((${#files_raw[@]})); then
    printf '%s\n' "${files_raw[@]}" | jq -s '.' > "$files_tmp"
  else
    echo '[]' > "$files_tmp"
  fi

  # Build statistics object
  # byCategory
  local byCategory=$(jq -n '{}')
  for k in "${!count_type[@]}"; do
    byCategory=$(echo "$byCategory" | jq --arg k "$k" --arg v "${count_type[$k]}" '. + {($k): ($v|tonumber)}')
  done
  # byStatus
  local byStatus=$(jq -n '{}')
  for m in "${!count_maturity[@]}"; do
    byStatus=$(echo "$byStatus" | jq --arg k "$m" --arg v "${count_maturity[$m]}" '. + {($k): ($v|tonumber)}')
  done
  local stats_json=$(jq -n --arg total "$(( ${#artifacts_raw[@]} ))" --arg size "$total_size" --argjson byCategory "$byCategory" --argjson byStatus "$byStatus" '{totalFiles:($total|tonumber), byCategory:$byCategory, byStatus:$byStatus, totalSize:($size|tonumber)}')

  # knowledge_index.stats
  local ki_stats_json=$(jq -n --arg ic "$internal_count" --arg ec "$external_curated_count" --arg er "$external_raw_count" --arg draft "${count_maturity[draft]:-0}" --arg review "${count_maturity[review]:-0}" --arg stable "${count_maturity[stable]:-0}" --arg deprecated "${count_maturity[deprecated]:-0}" '{internal:($ic|tonumber), external_curated:($ec|tonumber), external_raw:($er|tonumber), maturity:{draft:($draft|tonumber), review:($review|tonumber), stable:($stable|tonumber), deprecated:($deprecated|tonumber)}, archived:0}')

  # metrics.maturity_distribution
  local maturity_distribution_json=$(echo "$ki_stats_json" | jq '.maturity')

  update_manifest "$artifacts_tmp" "$files_tmp" "$stats_json" "$ki_stats_json" "$maturity_distribution_json"
  echo "[scan] Manifest atualizado com $(jq length "$artifacts_tmp") artefatos."
  echo "[scan] Manifest atualizado com $(jq length "$artifacts_tmp") artefatos."
}

main "$@"
