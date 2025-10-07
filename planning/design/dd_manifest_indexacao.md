---
id: dd-manifest-indexacao
title: Design Doc - Indexação e Registro Canônico de Conhecimento
type: design-doc
status: draft
version: 1.0.0
created: 2025-10-06
updated: 2025-10-06
authors: ["system"]
relations: ["dd-agente-context","dd-knowledge-resolution"]
---

# Design Doc: Indexação e Registro Canônico de Conhecimento

## 1. Resumo Executivo

Formalizar um pipeline determinístico para criação, indexação e evolução de artefatos de conhecimento garantindo rastreabilidade (gaps/decisões), ausência de órfãos e consistência do `knowledge/manifest.json`.

## 2. Problema

Artefatos novos (conceitos, decisões, runbooks) são adicionados sem indexação imediata, sem hash, sem vínculo claro a uma motivação (gap/decision) e sem maturidade declarada. Isso reduz descoberta, aumenta duplicação e enfraquece governança.

## 3. Princípios

- Indexação atômica: criação e registro inseparáveis.
- Rastreabilidade obrigatória (gap_id ou decision_id).
- Consistência manifest ↔ metadata YAML.
- Hash como verificação de integridade.
- Evolução controlada via maturidade: draft → review → stable → deprecated.
- Supersede explícito para substituições.

## 4. Objetivos

| Objetivo | Métrica |
|----------|---------|
| Zero artefatos órfãos | 0 paths não indexados |
| Indexação rápida | ≤ 60s criação → manifest |
| Rastreabilidade | 100% novos com gap_id ou decision_id |
| Saúde de maturidade | ≥70% stable (excluindo transitórios) |
| Integridade | 0 hash mismatch em execução de agentes |

## 5. Escopo

Inclui: extensão do manifest, scanner incremental, validação YAML, scripts utilitários, fluxo de supersede, arquivamento.
Exclui: armazenamento externo, diff semântico automatizado multilinha, camada de busca semântica (posterior).

## 6. Modelo Estendido do Manifest

```json
{
  "knowledge_index": {
    "artifacts": [
      {
        "path": "knowledge/internal/runbooks/rollback.md",
        "type": "runbook",
        "tags": ["rollback","ops"],
        "maturity": "draft",
        "hash": "sha256:...",
        "created_utc": "2025-10-06T12:00:00Z",
        "updated_utc": "2025-10-06T12:00:00Z",
        "created_by": "arquiteto",
        "source_origin": "internal",
        "authoritative": true,
        "linked": { "gaps": ["GAP-2025-10-06-001"], "decisions": ["DEC-001"] },
        "supersedes": null
      }
    ],
    "gaps": ["GAP-2025-10-06-001"],
    "stats": { "internal": 120, "external_curated": 45, "external_raw": 30 }
  }
}
```

## 7. Metadata Inline (YAML Header)

```markdown
---
id: runbook-rollback-strategy
type: runbook
maturity: draft
tags: [rollback, recovery, ops]
linked_gaps: [GAP-2025-10-06-001]
linked_decisions: [DEC-001]
---
```

Campos obrigatórios (criação): id, type, maturity, tags, (linked_gaps OR linked_decisions).

## 8. Lifecycle

1. Trigger (gap/decision)
2. Criação draft (YAML mínimo)
3. Scanner detecta → indexa → calcula hash
4. Validação schema + cruzamento links
5. Promoção (review → stable) após uso referenciado
6. Depreciação (stable → deprecated)
7. Arquivamento (deprecated > SLA)

## 9. Scanner & Atualização

Algoritmo incremental:

- Listar arquivos alterados (mtime > last_run)
- Para cada novo/alterado: extrair YAML → validar → calcular hash
- Novo: inserir; Alterado: atualizar hash + updated_utc
- Removido: marcar removed_at (soft) até limpeza
- Divergência YAML vs manifest → flag KNOWLEDGE_METADATA_DRIFT

## 10. Scripts Utilitários

- `scripts/scan_knowledge.sh`: scan + atualização manifest + relatório
- `scripts/register_gap.sh`: cria JSON gap
- `scripts/promote_artifact.sh`: altera maturity + updated_utc
- `scripts/validate_manifest.sh`: schema + órfãos + drift

## 11. Supersede Workflow

Ao substituir:

- Novo artefato: supersedes = path antigo
- Manifest: antigo.maturity=deprecated; authoritative=false
- Relatório semanal identifica deprecated > 90 dias

## 12. Arquivamento

Regra: deprecated > 90 dias → mover para `knowledge/archive/` (mantém entrada com archived_at). Remoção física opcional e tardia.

## 13. Enforcement nos Agentes

Antes de citar artefato:

- Verificar presença + hash consistente
Ao criar:
- Exigir linked_gaps ou linked_decisions
Falha → KNOWLEDGE_UNINDEXED_ARTIFACT

## 14. Códigos de Erro

KNOWLEDGE_UNINDEXED_ARTIFACT
KNOWLEDGE_METADATA_DRIFT
KNOWLEDGE_ORPHAN_GAP
KNOWLEDGE_STALE_HASH
KNOWLEDGE_SUPERSEDE_MISSING

## 15. Métricas

- index_latency_avg
- orphan_artifacts
- gaps_without_resolution
- maturity_distribution
- drift_incidents
- hash_mismatch_rate

## 16. Checklists

Criação:

- [ ] YAML completo
- [ ] gap_id ou decision_id
- [ ] Tags válidas
- [ ] Hash no manifest
Promoção stable:
- [ ] Revisão técnica
- [ ] Referenciado em ≥1 decisão/runbook
- [ ] Sem gaps críticos pendentes

## 17. Tag Registry

Arquivo: `knowledge/internal/references/tags_registry.json`
Campos: tag, description, status(active|deprecated), aliases[]
Lint: tags desconhecidas → warning; alias usado → sugerir canonical.

## 18. Retenção & Limpeza

- Soft delete: marcar removed_at
- Limpeza trimestral de deprecated arquivados
- Estatísticas de churn (criação vs remoção)

## 19. Backlog Técnico

1. Schema manifest extendido
2. Scanner + hash
3. YAML validator
4. Gap/decision linkage enforcement
5. Scripts utilitários
6. Métricas e relatório
7. Supersede + arquivamento
8. Tag registry + lint
9. CI hook validate_manifest
10. Integração handoff (delta artifacts)

## 20. Critérios de Sucesso

- 0 órfãos após Wave 2
- 100% indexados ≤ 60s
- Drift < 2%
- ≥70% stable (excluindo notas transitórias)
- 0 hash mismatch em execuções aprovadas

## 21. Riscos & Mitigações

| Risco | Mitigação |
|-------|-----------|
| Esquecimento metadata | Gerar stub automático |
| Duplicação de tags | Tag registry + lint |
| Latência scanner | Modo watch incremental |
| Supersede inconsistente | Script dedicado + validação |

## 22. Waves

Wave 1: Schema + scanner básico
Wave 2: Enforcement + métricas
Wave 3: Supersede + arquivamento
Wave 4: Otimização / churn insights

## 23. Integração com Outros Designs

- Usa handoff delta_summary para listar artifacts_new/modificados.
- Conecta gaps (dd-knowledge-resolution).
- Suporte a governança PM (dd-agente-context).

## 24. Próximos Passos

1. Aprovar design
2. Definir schema JSON
3. Implementar scanner protótipo
4. Criar tag registry inicial
5. Integrar verificação em fluxo de agente

---
