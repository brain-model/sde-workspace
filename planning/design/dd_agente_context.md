---
id: dd-agente-context
title: Design Doc - Continuidade de Contexto Multi-Agente (Governança PM)
type: design-doc
status: draft
version: 1.0.0
created: 2025-10-06
updated: 2025-10-06
authors: ["system"]
relations: []
---

# Design Doc: Continuidade de Contexto na Troca de Agentes

## 1. Resumo Executivo

Melhorar a continuidade de contexto entre agentes (Arquiteto → Desenvolvedora → QA → Revisora → PM) impondo governança central via Product Manager (PM) e formalizando handoffs estruturados versionados.

## 2. Problema

Perda de contexto e re-explicações sucessivas durante transições de fase. Riscos:

- Divergência de decisões
- Execuções fora de ordem
- Drift entre artefatos (specs, código, testes)
- Aumento de retrabalho cognitivo

## 3. Princípio Central

O PM é a única autoridade para:

- Iniciar ciclo (pode começar sem handoff inicial)
- Criar primeiro handoff (fase INITIALIZING)
- Validar encerramento e arquivar
- Saneamento de inconsistências (escopo/fase/destino)

Demais agentes só executam se existir handoff direcionado (meta.to_agent == agente). Caso contrário: abortam com código NO_HANDOFF_CONTEXT.

## 4. Objetivos

| Objetivo | Métrica / Indicador |
|----------|---------------------|
| Reduzir pedidos de clarificação | -50% após 3 ciclos |
| Zero execução sem handoff válido | 100% bloqueios corretos |
| Pré-condições validadas | 100% das fases registradas |
| Hashes íntegros | 0 mismatches pós-fase |
| Checklist de saída presente | 100% dos handoffs version >1 |

## 5. Escopo

Inclui: template expandido, máquina de estados, validação de pré-condições, métricas, códigos de erro.
Exclui: persistência externa, automação Git, UI dedicada.

## 6. Máquina de Estados

```text
INITIALIZING (pm)
  → DESIGN (arquiteto)
  → IMPLEMENTATION (developer)
  → QA_REVIEW (qa)
  → TECH_REVIEW (revisor)
  → PM_VALIDATION (pm)
  → ARCHIVED (pm)
```

Futuro: ROLLBACK_REQUESTED, BLOCKED.

## 7. Estrutura do Handoff (Versão Expandida)

Principais blocos:

- meta (ids, fases, from_agent, to_agent, version)
- context_core (objetivo, escopo in/out, RNFs)
- decisions (id, status, rationale, refs, changed_in_this_phase)
- artifacts_produced (path, hash, type, purpose)
- pending_items / risks
- knowledge_references (internal, external, gaps)
- delta_summary (diferenças desde última versão)
- next_phase_objectives + acceptance_criteria_next_phase
- checklists_completed
- quality_signals (scores, mismatches, open_questions)

## 8. Exemplo de Handoff

```json
{
  "meta": {
    "handoff_id": "UUID",
    "timestamp_utc": "2025-10-06T12:00:00Z",
    "from_agent": "arquiteto",
    "to_agent": "desenvolvedor",
    "phase_current": "design",
    "phase_next": "implementation",
    "workspace_id": "WKS-2025-10-06-001",
    "version": 3
  },
  "context_core": {
    "business_goal": "...",
    "scope_included": ["..."],
    "scope_excluded": ["..."],
    "non_functional_priorities": ["performance", "observability"]
  },
  "decisions": [
    {
      "id": "DEC-001",
      "title": "Formato de armazenamento de manifests",
      "status": "approved",
      "rationale": "...",
      "implications": ["..."],
      "references": ["knowledge/internal/decisions-context/..."],
      "changed_in_this_phase": true
    }
  ],
  "artifacts_produced": [
    {
      "path": "system/specs/manifest.json",
      "hash": "sha256:...",
      "type": "spec",
      "purpose": "canonical_index"
    }
  ],
  "pending_items": [
    { "id": "PEND-01", "description": "Definir métricas de rollback", "blocking": false }
  ],
  "risks": [
    { "id": "RISK-01", "description": "Acoplamento excessivo no orquestrador", "mitigation": "extrair interface" }
  ],
  "knowledge_references": {
    "internal": ["knowledge/internal/concepts/..."],
    "external": ["knowledge/external/standards/..."],
    "gaps": ["Observability runbook inexistente"]
  },
  "delta_summary": {
    "since_previous_handoff": {
      "decisions_added": 1,
      "decisions_updated": 0,
      "artifacts_new": 2,
      "artifacts_modified": 1
    }
  },
  "next_phase_objectives": [
    "Implementar camada de orquestração",
    "Gerar testes de contrato iniciais"
  ],
  "acceptance_criteria_next_phase": [
    "Orquestrador com handlers registrados",
    "Tests de smoke rodando em CI local"
  ],
  "checklists_completed": [
    "design.reviewed",
    "dependencies.validated"
  ],
  "quality_signals": {
    "context_completeness_score": 0.92,
    "artifact_hash_mismatch": false,
    "open_questions": 0
  }
}
```

## 9. Fluxo Operacional

1. PM cria workspace e (se primeira fase) handoff INITIALIZING → DESIGN.
2. Agente destinatário valida: destino, fase, hashes.
3. Executa trabalho estritamente sobre artefatos declarados.
4. Gera novo handoff + delta.
5. PM encerra com phase_next=ARCHIVED após validar critérios.

## 10. Validações (Agentes Não-PM)

Falha (abort) se:

- Ausência de handoff
- meta.to_agent != agente ativo
- phase_current inesperada
- Hash divergente
- delta_summary ausente quando version > 1

Códigos de erro propostos: NO_HANDOFF_CONTEXT, PHASE_DRIFT, HASH_MISMATCH, INCOMPLETE_HANDOFF.

## 11. Métricas

- context_completeness_score ≥ 0.9
- clarification_requests_por_fase
- handoff_rejection_rate
- tempo_transicao_fase
- incidência NO_HANDOFF_CONTEXT

## 12. Backlog Técnico (Ordem)

1. Enum fases + doc
2. Expandir template handoff (INITIALIZING / ARCHIVED)
3. Criar handoff.schema.json
4. Snippet de validação em cada agente
5. Hash checker utilitário
6. Atualizar manifest.json (referência handoffs)
7. Códigos de erro padronizados
8. Script `scripts/validate_handoff.sh`
9. Registrar métricas básicas
10. Documentar fluxo de falha

## 13. Critérios de Sucesso

- 100% execuções não-PM com handoff válido
- Zero mismatch hashes após fase
- Redução 50% clarificações
- PM único iniciando/arquivando
- Manifest aponta handoff ativo

## 14. Riscos e Mitigações

| Risco | Mitigação |
|-------|-----------|
| Sobrecarga manual | Automação incremental (scripts) |
| Crescimento handoff | Retenção N=3 + compressão delta |
| Preenchimento incorreto | Schema + validação CI |
| Drift manifest ↔ handoff | Pointer canônico + verificação em script |

## 15. Incrementos (Waves)

- Wave 1: Template + enum + validação mínima
- Wave 2: Hash + schema + script
- Wave 3: Métricas + retenção
- Wave 4: Delta semântico + scoring avançado

## 16. Open Questions

- Campo para dependências inter-workspace?
- Assinatura / fingerprint do agente? (auditoria futura)
- Snapshot consolidado de decisões antigas?

## 17. Próximos Passos Imediatos

1. Aprovar este design
2. Gerar schema JSON inicial
3. Implementar snippet de validação no agente Arquiteto como piloto
4. Ajustar PM para emitir INITIALIZING → DESIGN

---
