#!/usr/bin/env bash
# validate_handoff.sh
# Validação estruturada de handoff usando YAJSV + checagens de domínio.
# Requer: jq, sha256sum, e opcionalmente binário yajsv disponível no PATH.
# Códigos de erro de saída:
#  0 OK
#  2 NO_HANDOFF_CONTEXT (arquivo ausente ou ilegível)
#  3 SCHEMA_VALIDATION_FAILED
#  4 PHASE_DRIFT (phase_next inválida ou transição proibida)
#  5 HASH_MISMATCH (hash calculado difere do declarado)
#  6 DELTA_SUMMARY_RULE_VIOLATION
#  7 INCOMPLETE_HANDOFF (campos essenciais ausentes)
#  8 TOOL_MISSING (dependências mínimas)
#  9 INTERNAL_SCRIPT_ERROR
# 10 YAJSV_NOT_FOUND (schema não verificado formalmente)
set -euo pipefail

HANDOFF_FILE="${1:-handoff.json}"
SCHEMA_FILE="${2:-.sde_workspace/system/schemas/handoff.schema.json}"
BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

err() { echo "[handoff:ERROR] $1" >&2; }
info() { echo "[handoff] $1" >&2; }

require_tool() {
  command -v "$1" >/dev/null 2>&1 || { err "Dependência '$1' não encontrada"; exit 8; }
}

require_tool jq
require_tool sha256sum

[ -f "$HANDOFF_FILE" ] || { err "Arquivo de handoff não encontrado: $HANDOFF_FILE"; exit 2; }
[ -s "$HANDOFF_FILE" ] || { err "Arquivo de handoff vazio: $HANDOFF_FILE"; exit 2; }

normalize_path() {
  local target="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$target"
  elif command -v readlink >/dev/null 2>&1; then
    readlink -f "$target" 2>/dev/null || echo "$target"
  elif command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY' "$target"
import os, sys
print(os.path.abspath(sys.argv[1]))
PY
  else
    echo "$target"
  fi
}

# Validação do manifest apontando para o handoff atual quando aplicável
MANIFEST_FILE="$BASE_DIR/.sde_workspace/system/specs/manifest.json"
if [ -f "$MANIFEST_FILE" ]; then
  manifest_pointer=$(jq -r '.handoffs.latest // empty' "$MANIFEST_FILE")
  if [ -z "$manifest_pointer" ]; then
    err "INCOMPLETE_HANDOFF: manifest sem ponteiro handoffs.latest"; exit 7;
  fi
  pointer_abs=$(cd "$BASE_DIR" && normalize_path "$manifest_pointer")
  handoff_abs=$(cd "$BASE_DIR" && normalize_path "$HANDOFF_FILE")
  if [ "$pointer_abs" != "$handoff_abs" ]; then
    err "PHASE_DRIFT: manifest aponta para '$manifest_pointer', mas validação está em '$HANDOFF_FILE'"; exit 4;
  fi
  info "Manifest OK: $manifest_pointer"
else
  err "INCOMPLETE_HANDOFF: manifest de specs não localizado em $MANIFEST_FILE"; exit 7
fi

# Validação básica de chaves essenciais antes do schema (para feedback rápido)
ESSENTIAL_KEYS=(meta context_core decisions artifacts_produced knowledge_references quality_signals agents_progress)
for k in "${ESSENTIAL_KEYS[@]}"; do
  jq -e ". | has(\"$k\")" "$HANDOFF_FILE" >/dev/null || { err "INCOMPLETE_HANDOFF: falta bloco '$k'"; exit 7; }
done

# Validação formal com YAJSV (se disponível) — se ausente continua (warning) para permitir testes locais mínimos
if command -v yajsv >/dev/null 2>&1; then
  if ! yajsv -s "$SCHEMA_FILE" "$HANDOFF_FILE" 2>schema_err.log; then
    err "Falha de schema: $(tr '\n' ' ' < schema_err.log)"; rm -f schema_err.log; exit 3;
  fi
  rm -f schema_err.log
  info "Schema OK (yajsv)"
else
  info "[warn] YAJSV não encontrado - pulando validação formal de schema (instale para validação completa)"
fi

# Regras de transição (phase_current -> phase_next) - leitura do enum não implementada dinamicamente ainda.
phase_current=$(jq -r '.meta.phase_current' "$HANDOFF_FILE")
phase_next=$(jq -r '.meta.phase_next' "$HANDOFF_FILE")

case "$phase_current" in
  INITIALIZING) allowed="DESIGN" ;;
  DESIGN) allowed="IMPLEMENTATION" ;;
  IMPLEMENTATION) allowed="QA_REVIEW" ;;
  QA_REVIEW) allowed="TECH_REVIEW" ;;
  TECH_REVIEW) allowed="PM_VALIDATION" ;;
  PM_VALIDATION) allowed="ARCHIVED" ;;
  ARCHIVED) allowed="" ;;
  *) err "PHASE_DRIFT: fase atual desconhecida '$phase_current'"; exit 4; ;;
esac

if [ -n "$allowed" ] && [ "$phase_next" != "$allowed" ]; then
  err "PHASE_DRIFT: transição '$phase_current' -> '$phase_next' não permitida (esperado: $allowed)"; exit 4
fi
if [ -z "$allowed" ] && [ "$phase_current" = "ARCHIVED" ] && [ "$phase_next" != "ARCHIVED" ]; then
  err "PHASE_DRIFT: ARCHIVED não deve transicionar"; exit 4
fi

# Regra delta_summary
version=$(jq -r '.meta.version' "$HANDOFF_FILE")
if [ "$version" -eq 1 ]; then
  jq -e '.delta_summary == null' "$HANDOFF_FILE" >/dev/null || { err "DELTA_SUMMARY_RULE_VIOLATION: version 1 deve ter delta_summary = null"; exit 6; }
else
  jq -e '.delta_summary != null' "$HANDOFF_FILE" >/dev/null || { err "DELTA_SUMMARY_RULE_VIOLATION: version >1 exige delta_summary"; exit 6; }
fi

# Verificação de hashes declarados
jq -c '.artifacts_produced[]' "$HANDOFF_FILE" | while read -r artifact; do
  path=$(echo "$artifact" | jq -r '.path')
  declared=$(echo "$artifact" | jq -r '.hash')
  if [ ! -f "$path" ]; then
    err "HASH_MISMATCH: arquivo ausente '$path'"; exit 5
  fi
  actual="sha256:$(sha256sum "$path" | awk '{print $1}')"
  if [ "$declared" != "$actual" ]; then
    err "HASH_MISMATCH: $path declarado=$declared calculado=$actual"; exit 5
  fi
  info "Hash OK: $path"
done

# Sinalizadores de qualidade básicos
cc_score=$(jq -r '.quality_signals.context_completeness_score' "$HANDOFF_FILE")
if awk "BEGIN {exit !($cc_score >= 0 && $cc_score <= 1)}"; then :; else err "INCOMPLETE_HANDOFF: context_completeness_score fora do intervalo"; exit 7; fi

info "HANDOFF_VALID"
exit 0
