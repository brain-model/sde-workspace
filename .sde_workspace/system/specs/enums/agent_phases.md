# Enum de Fases Multi-Agente

Fonte primária para a máquina de estados de handoffs. O PM é o gatekeeper de transições.

## Fases

| Fase | Owner | Próximas Permitidas | Papéis de Suporte | Descrição | Critérios de Saída (Exit Criteria) |
|------|-------|---------------------|------------------|-----------|------------------------------------|
| INITIALIZING | pm | DESIGN | documentacao (opcional) | Bootstrap do ciclo, definição de objetivo, criação de handoff inicial. | Handoff v1 criado; objetivo de negócio claro; scope_in/out inicial; ponteiro manifest não-nulo |
| DESIGN | architect | IMPLEMENTATION | documentacao | Refinamento da solução e decisões arquiteturais chave. | Decisões registradas; artefatos de spec versionados; riscos iniciais mapeados; checklist design.reviewed |
| IMPLEMENTATION | developer | QA_REVIEW | devops, documentacao | Implementação dos artefatos de código e testes básicos. | Código principal commitado; testes smoke passando local; artifacts_produced hashes calculados; checklist implementation.complete |
| QA_REVIEW | qa | TECH_REVIEW | documentacao | Validação funcional mínima e verificação de critérios de aceitação. | Testes de validação executados; defeitos críticos bloqueadores registrados; checklist qa.validated |
| TECH_REVIEW | reviewer | PM_VALIDATION | documentacao | Revisão técnica e de qualidade (padrões, performance, riscos). | Comentários de revisão incorporados ou registrados; nenhum blocker técnico restante; checklist review.approved |
| PM_VALIDATION | pm | ARCHIVED | documentacao | Validação de aderência a objetivo de negócio e completude documental. | Métricas revisadas; delta_summary consistente; nenhum pending blocking; checklist pm.validated |
| ARCHIVED | pm | (nenhuma) | (nenhuma) | Ciclo finalizado; contexto congelado para auditoria. | Manifest aponta handoff final; hashes íntegros; registro de métricas persistido |

## Regras de Transição

1. Transições somente ocorrem via handoff emitido pelo owner da fase atual.
2. PM controla entrada em INITIALIZING e saída para ARCHIVED.
3. Retrocessos (rollback) ainda não suportados (futuro: ROLLBACK_REQUESTED).
4. Agente não-PM deve abortar se `phase` do último handoff não corresponde à fase esperada para sua atuação.
5. Papéis de suporte não alteram `phase`; produzem artefatos e atualizam `artifacts_produced` mantendo `phase` original (incrementam `version`).

### Janelas de Ativação de Papéis de Suporte

- documentacao: pode atuar em qualquer fase até PM_VALIDATION inclusive, desde que haja handoff válido apontando necessidade de síntese / promoção documental.
- devops: típico durante IMPLEMENTATION (preparação de pipeline) e eventualmente DESIGN (planejamento inicial) sob demanda sinalizada pelo PM.

Ao atuar, o handoff de suporte deve:

1. Referenciar `previous_handoff_id`.
2. Incrementar `version`.
3. Preencher `delta_summary` (artifacts_new / artifacts_modified relacionados ao suporte).
4. Manter `phase_current` inalterado.

## Validações Obrigatórias Antes de Emitir Novo Handoff

- Hash de todos os `artifacts_produced` calculado e estável.
- `delta_summary` obrigatório para `version > 1`.
- `quality_signals.context_completeness_score >= 0.9` antes de PM_VALIDATION.
- Para atuação de suporte: obrigatória presença de justificativa em `delta_summary.reason` indicando motivo da intervenção (ex: "adicionado pipeline CI baseline").

## Próximos Incrementos

- Suporte a estados BLOCKED e ROLLBACK_REQUESTED
- Enriquecimento de quality_signals (ex: drift_risk_score)
