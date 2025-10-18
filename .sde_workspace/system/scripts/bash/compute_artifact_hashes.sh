#!/usr/bin/env bash
# compute_artifact_hashes.sh
# Atualiza o bloco artifacts_produced de um handoff calculando hashes sha256 reais.
# Uso:
#   compute_artifact_hashes.sh <handoff.json> [--write]
# Opções:
#   --write, -w       Atualiza o arquivo original em vez de imprimir no stdout
#   --only-missing    Atualiza apenas entradas sem campo hash ou com hash vazio
#   --pretty          Imprime JSON formatado (padrão)
#   --raw             Imprime JSON compacto em uma linha
# Dependências: jq, sha256sum
# Saída: JSON atualizado ou arquivo sobrescrito
set -euo pipefail

usage() {
  cat <<'EOF'
Uso: compute_artifact_hashes.sh <handoff.json> [opções]

Opções:
  --write, -w       Atualiza o arquivo original em vez de imprimir no stdout
  --only-missing    Atualiza somente entradas sem hash definido
  --raw             Imprime JSON compacto (sobrepõe --pretty)
  --pretty          Imprime JSON formatado (padrão)
  --help            Mostra esta mensagem

Exemplos:
  # Gerar JSON atualizado sem tocar no arquivo
  compute_artifact_hashes.sh handoff.json

  # Atualizar apenas hashes ausentes e gravar no arquivo
  compute_artifact_hashes.sh handoff.json --only-missing --write
EOF
}

err() { echo "[artifact-hash:ERRO] $1" >&2; }
info() { echo "[artifact-hash] $1" >&2; }

require_tool() {
  command -v "$1" >/dev/null 2>&1 || { err "Dependência '$1' não encontrada"; exit 8; }
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

WRITE=false
ONLY_MISSING=false
PRETTY=true
HANDOFF=""

while [ $# -gt 0 ]; do
  case "$1" in
    --write|-w)
      WRITE=true
      ;;
    --only-missing)
      ONLY_MISSING=true
      ;;
    --raw)
      PRETTY=false
      ;;
    --pretty)
      PRETTY=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*)
      err "Opção desconhecida: $1"
      usage
      exit 1
      ;;
    *)
      if [ -z "$HANDOFF" ]; then
        HANDOFF="$1"
      else
        err "Apenas um arquivo de handoff é suportado"
        usage
        exit 1
      fi
      ;;
  esac
  shift
done

if [ -z "$HANDOFF" ]; then
  err "Informe o caminho para o handoff JSON"
  usage
  exit 1
fi

require_tool jq
require_tool sha256sum

if [ ! -f "$HANDOFF" ]; then
  err "Arquivo não encontrado: $HANDOFF"
  exit 2
fi
if [ ! -s "$HANDOFF" ]; then
  err "Arquivo vazio: $HANDOFF"
  exit 2
fi

if ! jq -e '.artifacts_produced and (.artifacts_produced | type == "array")' "$HANDOFF" >/dev/null; then
  err "Handoff não possui artifacts_produced como array"
  exit 3
fi

TMP_FILE=$(mktemp "$(basename "$HANDOFF").XXXX")
trap 'rm -f "$TMP_FILE" "$TMP_FILE.tmp"' EXIT
cp "$HANDOFF" "$TMP_FILE"
HANDOFF_DIR=$(cd "$(dirname "$HANDOFF")" && pwd)

updated_count=0
skipped_missing=0

while IFS= read -r artifact; do
  path=$(echo "$artifact" | jq -r '.path // empty')
  current_hash=$(echo "$artifact" | jq -r '.hash // empty')

  if [ -z "$path" ]; then
    err "Entrada artifacts_produced sem 'path' detectada. Abortando."
    exit 4
  fi

  if [[ "$path" = /* ]]; then
    resolved_path="$path"
  else
    resolved_path="$HANDOFF_DIR/$path"
  fi

  if [ ! -f "$resolved_path" ]; then
    err "Arquivo de artefato não encontrado: $path"
    exit 5
  fi

  sha_value=$(sha256sum "$resolved_path" | awk '{print $1}')
  new_hash="sha256:${sha_value}"

  if [ "$ONLY_MISSING" = true ] && [ -n "$current_hash" ]; then
    info "Mantendo hash existente para $path"
    skipped_missing=$((skipped_missing + 1))
    continue
  fi

  if [ "$current_hash" = "$new_hash" ]; then
    info "Hash já atualizado para $path"
    skipped_missing=$((skipped_missing + 1))
    continue
  fi

  info "Atualizando hash de $path"
  jq --arg path "$path" --arg hash "$new_hash" '
    .artifacts_produced |= map(if .path == $path then .hash = $hash else . end)
  ' "$TMP_FILE" > "$TMP_FILE.tmp"
  mv "$TMP_FILE.tmp" "$TMP_FILE"
  updated_count=$((updated_count + 1))
done < <(jq -c '.artifacts_produced[]?' "$HANDOFF")

info "Entradas atualizadas: $updated_count"
info "Entradas mantidas: $skipped_missing"

if [ "$WRITE" = true ]; then
  mv "$TMP_FILE" "$HANDOFF"
  info "Arquivo atualizado: $HANDOFF"
else
  if [ "$PRETTY" = true ]; then
    jq '.' "$TMP_FILE"
  else
    cat "$TMP_FILE"
  fi
fi

exit 0
