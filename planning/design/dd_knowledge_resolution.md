---
id: dd-knowledge-resolution
title: Design Doc - Política Forçada de Resolução de Conhecimento Multi-Agente
type: design-doc
status: draft
version: 1.0.0
created: 2025-10-06
updated: 2025-10-06
authors: ["system"]
relations: ["dd-agente-context"]
---

# Design Doc: Política Forçada de Resolução de Conhecimento

## 1. Resumo Executivo

Estabelecer uma política obrigatória e determinística de uso da base de conhecimento para todos os agentes (exceto PM na fase INITIALIZING), impondo prioridade rígida: Internal → External Curado → External Raw → Internet. Garante redução de redundância, rastreabilidade de fontes e criação estruturada de lacunas (gaps) quando informação não existe.

## 2. Problema

Agentes consultam fontes externas precocemente, ignoram conteúdo institucional existente e não registram lacunas sistematicamente. Isso provoca inconsistência, retrabalho, baixa reutilização e crescimento desordenado de artefatos duplicados.

## 3. Princípios

- Knowledge-first institucional: sempre tentar resolver com conteúdo interno curado.
- Escalonamento disciplinado de fontes.
- Toda ausência vira gap estruturado.
- Nenhuma decisão sem referência ou gap_id.
- Transparência: cada resolução gera knowledge_resolution_log.
- Bloqueio imediato em violações.

## 4. Objetivos

| Objetivo | Métrica |
|----------|---------|
| Aumentar reaproveitamento | reuse_ratio ≥ 80% (ciclo 3) |
| Reduzir consultas externas redundantes | -50% consultas internet ciclo 3 |
| Eliminar decisões órfãs | 100% decisões com referência/gap_id |
| Garantir disciplina de prioridade | 0 KNOWLEDGE_PRIORITY_VIOLATION estável |
| Rastrear lacunas | 100% gaps registrados com owner P1 |

## 5. Escopo

Inclui: algoritmo determinístico, registro de gaps, extensão de manifest, métricas, códigos de erro, snippet de validação, log estruturado.
Exclui: busca semântica vetorial, sincronização automática de fontes externas, classificação preditiva de gaps.

## 6. Taxonomia de Fontes (Prioridade)

1. Internal (curado): knowledge/internal/(concepts|decisions-context|runbooks|references|notes/summary)
2. External curado: knowledge/external/(standards|vendor-docs|research|sources)
3. External raw: transcripts, raw notes
4. Internet: fontes abertas (justificativa obrigatória)

## 7. Algoritmo Determinístico (resolver)

```pseudo
resolver(query):
  norm = normalizar(query)
  hits_internal = buscar(index, tipo=INTERNAL_CURADO, q=norm)
  if suficiente(hits_internal): return HIT_INTERNAL
  hits_ext_cur = buscar(index, tipo=EXTERNAL_CURADO, q=norm)
  if suficiente(hits_ext_cur): return HIT_EXTERNAL_CURADO
  hits_ext_raw = buscar(index, tipo=EXTERNAL_RAW, q=norm)
  if suficiente(hits_ext_raw): return HIT_EXTERNAL_RAW
  gap = registrar_gap(norm)
  exigir_justificativa_internet(gap.id)
  return PERMITIR_INTERNET
```

Critério suficiente: (tag exata) OR (similaridade título ≥ limiar) OR (referência em decisions-context ativo).

## 8. Estrutura de Registro de Gap

```json
{
  "gap_id": "GAP-2025-10-06-001",
  "query": "ex: rollback metrics standard",
  "timestamp_utc": "2025-10-06T13:00:00Z",
  "phase": "design",
  "agent": "arquiteto",
  "justification": "Nenhum runbook de rollback padronizado encontrado.",
  "impact": "Alto",
  "priority": "P1",
  "suggested_artifact_type": "runbook",
  "owner": "pm",
  "status": "open",
  "linked_decisions": [],
  "attempts": {
    "internal": 2,
    "external_curated": 1,
    "external_raw": 0
  }
}
```

Campos obrigatórios P1/P2: justification, impact. P3 pode ter justification mínima.

## 9. Extensão de Manifest (knowledge_index)

```json
{
  "knowledge_index": {
    "artifacts": [
      { "path": "knowledge/internal/runbooks/rollback.md", "type": "runbook", "tags": ["rollback","ops"], "authoritative": true, "last_hash": "sha256:...", "last_review": "2025-10-05" }
    ],
    "gaps": ["GAP-2025-10-06-001"],
    "stats": { "internal": 120, "external_curated": 45, "external_raw": 30 }
  }
}
```

## 10. Enforcement (Obrigatório)

Antes de gerar qualquer: decisão, spec, runbook, teste relevante ou recomendação de arquitetura:

1. Executar resolver(query base).
2. Registrar knowledge_resolution_log no output (fonte usada, ids, gaps, justificativa se internet).
3. Verificar prioridade: se fonte inferior consultada antes de exaurir superior → abortar.
4. Sem justificativa internet → abortar.

## 11. Códigos de Erro

- KNOWLEDGE_PRIORITY_VIOLATION – salto de prioridade.
- EXTERNAL_JUSTIFICATION_REQUIRED – justificativa ausente.
- GAP_NOT_REGISTERED – decisão cita gap inexistente.
- KNOWLEDGE_INDEX_OUTDATED – artifact usado não presente/atualizado no index.

## 12. knowledge_resolution_log (Formato)

```json
{
  "query": "criar rollback strategy",
  "resolution_path": ["internal", "external_curated"],
  "final_source": "external_curated",
  "artifacts_used": ["knowledge/external/standards/xyz.md"],
  "gaps_created": ["GAP-2025-10-06-001"],
  "internet_justification": null,
  "timestamp_utc": "2025-10-06T13:05:10Z"
}
```

## 13. Métricas

- reuse_ratio = internal_hits / total_consultas
- external_avoid_rate
- priority_violations
- gaps_resolution_time
- orphan_gaps (abertos > SLA)
- duplicate_concept_incidents

## 14. Checklist de Saída (Complemento)

- [ ] knowledge_resolution_log anexado
- [ ] Nenhuma consulta internet sem justificativa
- [ ] Decisões novas referenciam fonte ou gap_id
- [ ] Gaps P1 possuem owner atribuído

## 15. Backlog Técnico (Ordem)

1. Definir vocabulário e tags canônicas.
2. Implementar knowledge_index no manifest.
3. Criar script `scripts/resolve_knowledge.sh` (busca textual + ranking simples).
4. Template `gap_template.json` (estrutura acima).
5. Snippet de enforcement para agentes.
6. Logging estruturado (event codes).
7. Métricas agregadas por ciclo (JSON em reports/).
8. Relatório semanal (compilado pelo PM).
9. Prioritização automática inicial (heurística impacto x frequência).
10. Retenção e limpeza de gaps closed > X dias.

## 16. Critérios de Sucesso

- ≥80% reuse_ratio em ciclo 3.
- 0 priority_violations (estável).
- 100% decisões com referência/gap_id.
- Redução 50% internet queries.
- 100% gaps P1 resolvidos ou em progresso ≤ 2 ciclos.

## 17. Riscos & Mitigações

| Risco | Mitigação |
|-------|-----------|
| Overhead manual | Automação via script resolver |
| Gaps triviais massivos | Auto-classificação P3 + triagem PM |
| Falsy misses (fonte não encontrada) | Revisão de tags semanal |
| Saturação de logs | Agregação e compressão periódica |

## 18. Waves de Implementação

- Wave 1: Index + gap + enforcement mínimo.
- Wave 2: Métricas + relatório + heurística suficiência.
- Wave 3: Priorização automática + limpeza.
- Wave 4: Otimizações (ranking contextual / semântico).

## 19. Integração com Handoffs

Adicionar em quality_signals.knowledge: counters (internal_hits, external_curated_hits, external_raw_hits, internet_queries, gaps_opened, priority_violations). Atualizados a cada handoff.

## 20. Open Questions

- Introduzir estados de maturidade (draft, stable) para ranking?
- Normalizar sinônimos (glossário central)?
- Integrar com embeddings (futuro)?

## 21. Próximos Passos Imediatos

1. Validar este design (PM + documentação).
2. Implementar knowledge_index inicial.
3. Gerar script resolver (protótipo).
4. Injetar snippet enforcement no agente Arquiteto (piloto).

---
