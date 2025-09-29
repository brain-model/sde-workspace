# Guia de Checklists por Fase

Para garantir rastreabilidade e consistência entre handoffs, cada fase da máquina de estados deve registrar saídas explícitas no campo `checklists_completed` do handoff. Utilize os identificadores abaixo como padrão mínimo e adicione itens específicos da tarefa quando necessário.

## INITIALIZING → DESIGN (PM)

- `pm.initializing.scope_confirmed`
- `pm.initializing.handoff_seeded`
- `manifest.updated`

## DESIGN → IMPLEMENTATION (Arquiteto)

- `design.reviewed`
- `design.context_validated`
- `handoff.saved`

## IMPLEMENTATION → QA_REVIEW (Developer)

- `implementation.tests_green`
- `implementation.artifacts_synced`
- `handoff.saved`

## QA_REVIEW → TECH_REVIEW (QA)

- `qa.tests_executed`
- `qa.evidences_attached`
- `handoff.saved`

## TECH_REVIEW → PM_VALIDATION (Reviewer)

- `review.diff_inspected`
- `review.feedback_registered`
- `handoff.saved`

## PM_VALIDATION → ARCHIVED (PM)

- `pm.validation.metrics_recorded`
- `pm.validation.archive_ready`
- `manifest.updated`

## ARCHIVED (PM Pós-Arquivamento)

- `pm.archived.history_snapshot`
- `pm.archived.metrics_published`

> **Dica:** sempre que gerar um novo handoff, certifique-se de executar `validate_handoff.sh` e atualizar o manifest (`handoffs.latest`). Em seguida, registre os itens acima para sinalizar que a fase está pronta para a próxima execução.

> **Automação:** utilize `./.sde_workspace/system/scripts/apply_handoff_checklist.sh <handoff.json> <phase_current>` para popular automaticamente os itens obrigatórios da fase.
