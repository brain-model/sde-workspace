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

## Resolução de Conhecimento

Todos os agentes devem invocar `resolve_knowledge.sh` antes de recorrer a fontes externas. O fluxo mínimo é:

1. **Definir o handoff ativo**

   ```bash
   export HANDOFF=.sde_workspace/system/handoffs/latest.json
   ```

2. **Executar a consulta determinística**

   ```bash
   ./.sde_workspace/system/scripts/resolve_knowledge.sh "<consulta>" \
     --agent <agent_id> \
     --phase "$(jq -r '.meta.phase_current' "$HANDOFF")" \
     --justification "Motivo explícito da pesquisa" \
     --suggested <tipo_de_artefato>
   ```

3. **Interpretar o retorno JSON**: registre artefatos em `knowledge_references`, incremente contadores em `quality_signals.knowledge` e, se um `gap_id` for emitido, adicione-o a `knowledge/gaps/` e ao handoff.

4. **Eventos de governança**: o script emite eventos adicionais no log `knowledge_resolution.log`.
   - `KNOWLEDGE_PRIORITY_VIOLATION`: tentativa de iniciar consulta abaixo do nível interno.
   - `EXTERNAL_JUSTIFICATION_REQUIRED`: consulta externa sem justificativa customizada.
   - `GAP_NOT_REGISTERED`: gap informado não existe no diretório.
   - `GAP_REFERENCED`: reutilização bem-sucedida de gap existente.

5. **Reutilização de gaps**: use `--existing-gap <id>` para reler lacunas abertas. Se o arquivo não existir, o script encerra com o evento `GAP_NOT_REGISTERED`.

6. **Prioridade rígida**: o parâmetro `--min-source` rejeita tentativas de pular níveis e gera `KNOWLEDGE_PRIORITY_VIOLATION`.

7. **Justificativas obrigatórias**: personalize `--justification` quando precisar subir para fontes externas; caso contrário, `EXTERNAL_JUSTIFICATION_REQUIRED` será registrado.

8. **Métricas e relatórios**: gere indicadores com `./.sde_workspace/system/scripts/report_knowledge_metrics.sh --days 7 --raw` e consolide um resumo em Markdown com `./.sde_workspace/system/scripts/report_knowledge_weekly.sh`. Publique os resultados no handoff atual em `quality_signals.knowledge.reports`.
