#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VALIDATOR="${BASE_DIR}/.sde_workspace/system/scripts/validate_handoff.sh"
SCHEMA="${BASE_DIR}/.sde_workspace/system/schemas/handoff.schema.json"
HASHER="${BASE_DIR}/.sde_workspace/system/scripts/compute_artifact_hashes.sh"
MANIFEST="${BASE_DIR}/.sde_workspace/system/specs/manifest.json"
MANIFEST_BACKUP="$(mktemp)"

cp "$MANIFEST" "$MANIFEST_BACKUP"

restore_manifest() {
  mv "$MANIFEST_BACKUP" "$MANIFEST"
}

trap restore_manifest EXIT

set_manifest_pointer() {
  local target="$1"
  local tmp
  tmp="$(mktemp)"
  jq --arg ptr "$target" '.handoffs.latest = $ptr' "$MANIFEST" > "$tmp"
  mv "$tmp" "$MANIFEST"
}

if [ ! -x "$VALIDATOR" ]; then
  echo "Tornando script de validação executável" >&2
  chmod +x "$VALIDATOR" || true
fi

if [ ! -x "$HASHER" ]; then
  echo "Tornando utilitário de hash executável" >&2
  chmod +x "$HASHER" || true
fi

mkdir -p tmp_handoff_test
cd tmp_handoff_test

echo "Criando arquivo de artefato dummy..."
echo 'conteudo exemplo' > artifact.txt

cat > handoff_ok.json <<EOF
{
  "meta": {
    "handoff_id": "handoff-2025-10-06T12:00:00Z-architect",
    "timestamp_utc": "2025-10-06T12:00:00Z",
    "from_agent": "architect",
    "to_agent": "developer",
    "phase_current": "DESIGN",
    "phase_next": "IMPLEMENTATION",
    "previous_handoff_id": null,
    "workspace_id": "WKS-20251006-001",
    "version": 1
  },
  "context_core": {
    "business_goal": "Reduzir latência",
    "scope_included": ["api"],
    "scope_excluded": ["ui"],
    "non_functional_priorities": ["performance"]
  },
  "decisions": [
    {"id": "DEC-1", "title": "Stack", "status": "approved", "rationale": "Performance", "changed_in_this_phase": true}
  ],
  "artifacts_produced": [
    {"path": "artifact.txt", "hash": "sha256:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", "type": "doc", "purpose": "demo"}
  ],
  "pending_items": [],
  "risks": [],
  "knowledge_references": {"internal": [], "external": [], "gaps": []},
  "delta_summary": null,
  "next_phase_objectives": ["Implementar módulo"],
  "acceptance_criteria_next_phase": ["Build executa"],
  "checklists_completed": ["design.reviewed"],
  "quality_signals": {"context_completeness_score": 0.9, "artifact_hash_mismatch": false, "open_questions": 0, "clarification_requests": 0},
  "agents_progress": {"architect": {"completed": true}, "developer": {"completed": false}, "qa": {"completed": false}, "reviewer": {"completed": false}, "pm": {"completed": false}, "documentation": {"completed": false}, "devops": {"completed": false}},
  "notes": []
}
EOF

"$HASHER" handoff_ok.json --write >/dev/null

# Caso de erro: hash incorreto + transição inválida DESIGN -> QA_REVIEW
echo 'outro conteudo' > artifact_broken.txt
cat > handoff_bad.json <<EOF
{
  "meta": {
    "handoff_id": "handoff-2025-10-06T12:05:00Z-architect",
    "timestamp_utc": "2025-10-06T12:05:00Z",
    "from_agent": "architect",
    "to_agent": "developer",
    "phase_current": "DESIGN",
    "phase_next": "QA_REVIEW",
    "previous_handoff_id": null,
    "workspace_id": "WKS-20251006-001",
    "version": 1
  },
  "context_core": {
    "business_goal": "Reduzir latência",
    "scope_included": ["api"],
    "scope_excluded": ["ui"],
    "non_functional_priorities": ["performance"]
  },
  "decisions": [
    {"id": "DEC-1", "title": "Stack", "status": "approved", "rationale": "Performance", "changed_in_this_phase": true}
  ],
  "artifacts_produced": [
    {"path": "artifact_broken.txt", "hash": "sha256:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", "type": "doc", "purpose": "demo"}
  ],
  "pending_items": [],
  "risks": [],
  "knowledge_references": {"internal": [], "external": [], "gaps": []},
  "delta_summary": null,
  "next_phase_objectives": ["Implementar módulo"],
  "acceptance_criteria_next_phase": ["Build executa"],
  "checklists_completed": ["design.reviewed"],
  "quality_signals": {"context_completeness_score": 0.95, "artifact_hash_mismatch": false, "open_questions": 0, "clarification_requests": 0},
  "agents_progress": {"architect": {"completed": true}, "developer": {"completed": false}, "qa": {"completed": false}, "reviewer": {"completed": false}, "pm": {"completed": false}, "documentation": {"completed": false}, "devops": {"completed": false}},
  "notes": []
}
EOF

set +e
echo "== Caso Sucesso =="
set_manifest_pointer "$(pwd)/handoff_ok.json"
"$VALIDATOR" "$(pwd)/handoff_ok.json" "$SCHEMA" || echo "Falhou inesperadamente"

echo "== Caso Erro (espera falhar) =="
set_manifest_pointer "$(pwd)/handoff_bad.json"
"$VALIDATOR" "$(pwd)/handoff_bad.json" "$SCHEMA" || echo "(Falha esperada)"
set -e

echo "Finalizado. Artefatos em $(pwd)"
