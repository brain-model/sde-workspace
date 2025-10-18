#!/usr/bin/env bash
# resolve_knowledge.sh
# Política determinística de resolução de conhecimento multi-agente.
# Prioridade rígida: Internal → External Curado → External Raw → Internet (gap).
# Eventos de governança emitidos:
#   - KNOWLEDGE_PRIORITY_VIOLATION: tentativa de pular prioridade interna
#   - EXTERNAL_JUSTIFICATION_REQUIRED: consulta externa sem justificativa explícita
#   - GAP_NOT_REGISTERED: gap referenciado inexistente
#   - GAP_REFERENCED: gap existente reutilizado com sucesso
# Uso:
#   ./resolve_knowledge.sh "<query>" [--agent <id>] [--phase <phase>] [--priority <Pn>] [--impact <descricao>] [--justification <texto>]
#        [--suggested <artefato>] [--owner <id>] [--min-source <nivel>] [--existing-gap <gap_id>] [--no-log]
# O script registra eventos em JSON no log `.sde_workspace/system/logs/knowledge_resolution.log`
# e cria gaps automaticamente em `.sde_workspace/knowledge/gaps/` quando nenhuma fonte atende.
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Uso: $0 \"<query>\" [--agent <id>] [--phase <phase>] [--priority <Pn>] [--impact <descricao>] [--justification <texto>] [--suggested <artefato>] [--owner <id>] [--min-source <nivel>] [--existing-gap <gap_id>] [--no-log]" >&2
  exit 64
fi

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[knowledge:ERROR] Dependência '$1' não encontrada" >&2
    exit 8
  fi
}

require_tool jq
require_tool grep

BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
KNOWLEDGE_DIR="$BASE_DIR/.sde_workspace/knowledge"
LOG_FILE="$BASE_DIR/.sde_workspace/system/logs/knowledge_resolution.log"

mkdir -p "$(dirname "$LOG_FILE")"

QUERY=""
AGENT="unknown"
PHASE="unknown"
PRIORITY="P1"
IMPACT="Alto"
DEFAULT_JUSTIFICATION="Gap registrado automaticamente. Atualize com detalhes específicos."
JUSTIFICATION="$DEFAULT_JUSTIFICATION"
SUGGESTED=""
OWNER="pm"
WRITE_LOG=true
MIN_SOURCE="internal"
EXISTING_GAP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      AGENT="$2"; shift 2 ;;
    --phase)
      PHASE="$2"; shift 2 ;;
    --priority)
      PRIORITY="$2"; shift 2 ;;
    --impact)
      IMPACT="$2"; shift 2 ;;
    --justification)
      JUSTIFICATION="$2"; shift 2 ;;
    --suggested)
      SUGGESTED="$2"; shift 2 ;;
    --owner)
      OWNER="$2"; shift 2 ;;
    --min-source)
      MIN_SOURCE="$2"; shift 2 ;;
    --existing-gap)
      EXISTING_GAP="$2"; shift 2 ;;
    --no-log)
      WRITE_LOG=false; shift ;;
    --*)
      echo "[knowledge:ERROR] Opção desconhecida: $1" >&2
      exit 64 ;;
    *)
      if [ -z "$QUERY" ]; then
        QUERY="$1"; shift
      else
        # suportar query com múltiplas palavras sem aspas
        QUERY="$QUERY $1"; shift
      fi ;;
  esac
done

QUERY_TRIMMED=$(echo "$QUERY" | sed 's/^ *//;s/ *$//')
if [ -z "$QUERY_TRIMMED" ]; then
  echo "[knowledge:ERROR] Query vazia" >&2
  exit 64
fi

validate_level() {
  case "$1" in
    internal|external_curated|external_raw|internet) return 0 ;;
    *) return 1 ;;
  esac
}

append_log() {
  local json_entry="$1"
  if $WRITE_LOG; then
    printf '%s\n' "$json_entry" >> "$LOG_FILE"
  fi
}

emit_event() {
  local event="$1"; shift
  local severity="$1"; shift
  local message="$1"; shift
  local payload="$1"; shift
  local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local entry
  entry=$(jq -n \
    --arg ts "$ts" \
    --arg event "$event" \
    --arg severity "$severity" \
    --arg message "$message" \
    --arg agent "$AGENT" \
    --arg phase "$PHASE" \
    --argjson extra "$payload" \
    '{timestamp_utc: $ts, event: $event, severity: $severity, message: $message, agent: $agent, phase: $phase} + $extra')
  append_log "$entry"
  printf '%s\n' "$entry"
}

if ! validate_level "$MIN_SOURCE"; then
  emit_event "KNOWLEDGE_PRIORITY_VIOLATION" "error" "Nível de fonte desconhecido" "{}"
  exit 65
fi

if [ "$MIN_SOURCE" != "internal" ]; then
  emit_event "KNOWLEDGE_PRIORITY_VIOLATION" "error" "Tentativa de iniciar consulta abaixo da prioridade interna" \
    "$(jq -n --arg requested_level "$MIN_SOURCE" '{requested_level: $requested_level}')"
  exit 65
fi

if [ -n "$EXISTING_GAP" ]; then
  GAP_PATH="$KNOWLEDGE_DIR/gaps/$EXISTING_GAP.json"
  if [ ! -f "$GAP_PATH" ]; then
    emit_event "GAP_NOT_REGISTERED" "error" "Gap informado não encontrado" \
      "$(jq -n --arg gap_id "$EXISTING_GAP" --arg query "$QUERY_TRIMMED" '{gap_id: $gap_id, query: $query}')"
    exit 67
  fi
  emit_event "GAP_REFERENCED" "info" "Gap referenciado com sucesso" \
    "$(jq -n --arg gap_id "$EXISTING_GAP" '{gap_id: $gap_id}')"
  cat "$GAP_PATH"
  exit 0
fi

normalize() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

readarray -t INTERNAL_DIRS <<'EOF'
internal/concepts
internal/decisions-context
internal/runbooks
internal/references
internal/notes/summary
EOF

readarray -t EXTERNAL_CURATED_DIRS <<'EOF'
external/standards
external/vendor-docs
external/research
external/sources
EOF

readarray -t EXTERNAL_RAW_DIRS <<'EOF'
external/transcripts
internal/notes/raw
EOF

search_sources() {
  local class="$1"; shift
  local -n dirs_ref="$1"
  local query="$2"
  local hits_file="$3"
  local attempts=0
  : > "$hits_file"
  for rel_path in "${dirs_ref[@]}"; do
    local target_dir="$KNOWLEDGE_DIR/$rel_path"
    if [ -d "$target_dir" ]; then
      attempts=$((attempts + 1))
      while IFS= read -r -d '' file; do
        printf '%s\n' "$file" >> "$hits_file"
      done < <(grep -Rils --binary-files=without-match -- "$query" "$target_dir" 2>/dev/null || true)
    fi
  done
  echo "$attempts"
}

create_gap() {
  local query="$1"
  local attempts_internal="$2"
  local attempts_external_cur="$3"
  local attempts_external_raw="$4"
  local timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local sanitized_ts
  sanitized_ts=$(echo "$timestamp" | tr -d ':-TZ')
  local gap_id="GAP-${sanitized_ts}"
  local gap_filename="$KNOWLEDGE_DIR/gaps/$gap_id.json"
  local status="open"

  mkdir -p "$KNOWLEDGE_DIR/gaps"

  jq -n \
    --arg id "$gap_id" \
    --arg query "$query" \
    --arg ts "$timestamp" \
    --arg phase "$PHASE" \
    --arg agent "$AGENT" \
    --arg justification "$JUSTIFICATION" \
  --arg impact "$IMPACT" \
  --arg priority "$PRIORITY" \
  --arg suggested "$SUGGESTED" \
  --arg owner "$OWNER" \
    --arg status "$status" \
    --argjson attemptsInternal "$attempts_internal" \
    --argjson attemptsExternalCur "$attempts_external_cur" \
    --argjson attemptsExternalRaw "$attempts_external_raw" \
    '{
      gap_id: $id,
      query: $query,
      timestamp_utc: $ts,
      phase: $phase,
      agent: $agent,
      justification: $justification,
      impact: $impact,
      priority: $priority,
      suggested_artifact_type: $suggested,
      owner: $owner,
      status: $status,
      linked_decisions: [],
      attempts: {
        internal: $attemptsInternal,
        external_curated: $attemptsExternalCur,
        external_raw: $attemptsExternalRaw
      }
    }' > "$gap_filename"

  echo "$gap_filename"
}

update_manifest_with_gap() {
  local gap_id="$1"
  local manifest="$KNOWLEDGE_DIR/manifest.json"
  if [ -f "$manifest" ]; then
    tmp_manifest="$(mktemp)"
    if jq '.knowledge_index.gaps |= ( . + [$gap] | unique )' --arg gap "$gap_id" "$manifest" > "$tmp_manifest" 2>/dev/null; then
      mv "$tmp_manifest" "$manifest"
    else
      rm -f "$tmp_manifest"
      echo "[knowledge:WARN] Não foi possível atualizar knowledge_index com o gap" >&2
    fi
  fi
}

require_external_justification() {
  local source="$1"
  local trimmed
  trimmed=$(printf '%s' "$JUSTIFICATION" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  if [ "$source" = "internal" ]; then
    return
  fi
  if [ -z "$trimmed" ] || [ "$JUSTIFICATION" = "$DEFAULT_JUSTIFICATION" ]; then
    emit_event "EXTERNAL_JUSTIFICATION_REQUIRED" "warning" "Justificativa obrigatória para uso de fontes externas" \
      "$(jq -n --arg final_source "$source" --arg query "$QUERY_TRIMMED" '{final_source: $final_source, query: $query}')"
  fi
}

QUERY_NORMALIZED=$(normalize "$QUERY_TRIMMED")
hits_file="$(mktemp)"
internal_attempts=$(search_sources "internal" INTERNAL_DIRS "$QUERY_NORMALIZED" "$hits_file")
if [ -s "$hits_file" ]; then
  mapfile -t hits <"$hits_file"
  result_source="internal"
  event="KNOWLEDGE_HIT_INTERNAL"
  resolution_path='["internal"]'
  final_hits=$(printf '%s\n' "${hits[@]}" | head -n 5 | jq -R -s -c 'split("\n")[:-1]')
  log_entry=$(jq -n \
    --arg query "$QUERY_TRIMMED" \
    --argjson path "$resolution_path" \
    --arg source "$result_source" \
    --argjson hits "$final_hits" \
    --arg agent "$AGENT" \
    --arg phase "$PHASE" \
    --arg event "$event" \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '{timestamp_utc: $ts, event: $event, query: $query, agent: $agent, phase: $phase, resolution_path: $path, final_source: $source, artifacts_used: $hits, gaps_created: []}')
  append_log "$log_entry"
  printf '%s\n' "$log_entry"
  rm -f "$hits_file"
  exit 0
fi

external_cur_attempts=$(search_sources "external_curated" EXTERNAL_CURATED_DIRS "$QUERY_NORMALIZED" "$hits_file")
if [ -s "$hits_file" ]; then
  mapfile -t hits <"$hits_file"
  result_source="external_curated"
  event="KNOWLEDGE_HIT_EXTERNAL_CURATED"
  resolution_path='["internal","external_curated"]'
  final_hits=$(printf '%s\n' "${hits[@]}" | head -n 5 | jq -R -s -c 'split("\n")[:-1]')
  log_entry=$(jq -n \
    --arg query "$QUERY_TRIMMED" \
    --argjson path "$resolution_path" \
    --arg source "$result_source" \
    --argjson hits "$final_hits" \
    --arg agent "$AGENT" \
    --arg phase "$PHASE" \
    --arg event "$event" \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '{timestamp_utc: $ts, event: $event, query: $query, agent: $agent, phase: $phase, resolution_path: $path, final_source: $source, artifacts_used: $hits, gaps_created: []}')
  append_log "$log_entry"
  require_external_justification "external_curated"
  printf '%s\n' "$log_entry"
  rm -f "$hits_file"
  exit 0
fi

external_raw_attempts=$(search_sources "external_raw" EXTERNAL_RAW_DIRS "$QUERY_NORMALIZED" "$hits_file")
if [ -s "$hits_file" ]; then
  mapfile -t hits <"$hits_file"
  result_source="external_raw"
  event="KNOWLEDGE_HIT_EXTERNAL_RAW"
  resolution_path='["internal","external_curated","external_raw"]'
  final_hits=$(printf '%s\n' "${hits[@]}" | head -n 5 | jq -R -s -c 'split("\n")[:-1]')
  log_entry=$(jq -n \
    --arg query "$QUERY_TRIMMED" \
    --argjson path "$resolution_path" \
    --arg source "$result_source" \
    --argjson hits "$final_hits" \
    --arg agent "$AGENT" \
    --arg phase "$PHASE" \
    --arg event "$event" \
    --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '{timestamp_utc: $ts, event: $event, query: $query, agent: $agent, phase: $phase, resolution_path: $path, final_source: $source, artifacts_used: $hits, gaps_created: []}')
  append_log "$log_entry"
  require_external_justification "external_raw"
  printf '%s\n' "$log_entry"
  rm -f "$hits_file"
  exit 0
fi

# Nenhuma fonte retornou resultado → criar gap
GAP_FILE=$(create_gap "$QUERY_TRIMMED" "$internal_attempts" "$external_cur_attempts" "$external_raw_attempts")
GAP_ID=$(basename "$GAP_FILE" .json)
update_manifest_with_gap "$GAP_ID"

event="GAP_CREATED"
resolution_path='["internal","external_curated","external_raw","internet"]'
log_entry=$(jq -n \
  --arg query "$QUERY_TRIMMED" \
  --argjson path "$resolution_path" \
  --arg source "gap" \
  --arg agent "$AGENT" \
  --arg phase "$PHASE" \
  --arg event "$event" \
  --arg gap "$GAP_ID" \
  --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  '{timestamp_utc: $ts, event: $event, query: $query, agent: $agent, phase: $phase, resolution_path: $path, final_source: $source, artifacts_used: [], gaps_created: [$gap], internet_justification: null}')
append_log "$log_entry"
require_external_justification "internet"
printf '%s\n' "$log_entry"
rm -f "$hits_file"

exit 0
