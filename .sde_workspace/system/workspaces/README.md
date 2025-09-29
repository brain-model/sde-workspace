# Workspaces

Áreas de trabalho efêmeras e guiadas onde tarefas, experimentos ou execuções multi-agente acontecem de forma isolada, rastreável e reprodutível.

## Propósito

Fornecer um espaço temporário e estruturado para a materialização de uma unidade de trabalho (ex: implementação de uma tarefa, investigação técnica, experimento controlado) sem poluir diretórios normativos (`system/specs`, `knowledge`, `backlog`). Cada workspace atua como um "sandbox contextual" que pode ser arquivado ao final do ciclo.

## Quando Usar

Use um workspace quando:

- Uma tarefa entra em execução prática após aprovação de spec
- É necessário agrupar artefatos transitórios (rascunhos de código, logs, comparativos)
- Um experimento PoC precisa de isolamento antes de virar padrão
- Há necessidade de reprodutibilidade (inputs + outputs versionados localmente)

Evite workspaces quando o conteúdo já é claramente um documento normativo (vá para `system/specs`) ou conhecimento institucional (vá para `knowledge/internal`).

## Ciclo de Vida

1. `criado` → Workspace inicial é gerado com estrutura mínima
2. `em-execucao` → Artefatos temporários são produzidos (código, relatórios, notas)
3. `revisao` → Resultados avaliados; decide-se promoção ou descarte
4. `consolidado` → Artefatos relevantes promovidos (spec, knowledge, template)
5. `arquivado` → Workspace movido para `workspaces/archive/<ID>/`

Estados podem ser rastreados em um arquivo `handoff.json` ou `EXECUTION_SUMMARY.md` conforme padrão adotado.

## Estrutura Recomendada

```bash
workspaces/
 <ALIAS|ID>/
  handoff.json              # Metadados estruturados (estado, agentes, timestamps)
  EXECUTION_SUMMARY.md      # Resumo narrativo (opcional / se aplicável)
  src/                      # Código gerado ou protótipos
  tests/                    # Testes associados (quando houver)
  reports/                  # Relatórios (outputs, métricas, diffs, logs)
  notes/                    # Anotações locais transitórias (se necessário)
```

Arquivos centrais:

- `handoff.json`: ponte entre agentes; contém contexto mínimo para continuidade
- `reports/`: saída consolidada de análises, execuções, validações

## Handoff Entre Agentes

O handoff operacional entre Arquiteto → Desenvolvedora → QA → Revisora → PM pode ser explicitado no `handoff.json`, incluindo campos como:

```jsonc
{
 "id": "TST-9D1F-01",
 "sourceSpec": "spec-tst-9d1f-01-clean-backend.md",
 "status": "em-execucao",
 "agents": {
  "architect": { "completed": true, "artifact": "spec-tst-9d1f-01-clean-backend.md" },
  "developer": { "completed": false },
  "qa": { "completed": false },
  "reviewer": { "completed": false },
  "pm": { "completed": false }
 },
 "createdAt": "2025-10-06T10:00:00-03:00",
 "updatedAt": "2025-10-06T10:30:00-03:00"
}
```

## Convenções

- Nome do diretório do workspace deve incluir o identificador da tarefa (ex: `TST-9D1F-02`)
- IDs estáveis e imutáveis após criação
- Não duplicar specs: referencie a original em `system/specs`
- Promova somente artefatos consolidados; não copie lixo histórico

## Promoção de Artefatos

| Origem Workspace        | Destino Definitivo                      | Critério |
|-------------------------|------------------------------------------|---------|
| spec refinada (draft)   | `system/specs/in-review/`                | Revisão formal iniciada |
| runbook validado        | `knowledge/internal/runbooks/`           | Processo operacional reutilizável |
| insight arquitetural    | `knowledge/internal/concepts/`           | Conceito reutilizável |
| script útil genérico    | `system/templates/` ou tooling apropriado| Reuso recorrente |
| relatório QA final      | `knowledge/internal/notes/summary/`      | Valor histórico/técnico |

## Boas Práticas

- Mantenha o workspace enxuto: remova resíduos após consolidação
- Versione apenas o necessário para reprodutibilidade
- Use diffs em `reports/` para comparar evoluções de abordagem
- Registre decisões emergentes breves em `decision notes` dentro do summary
- Finalize sempre com um `EXECUTION_SUMMARY.md` ou atualizar `handoff.json` para `arquivado`

## Automação (Futuro Planejado)

- Geração automática de `handoff.json`
- Validação de consistência (referência a spec existente, estado válido)
- Sumarização automática de logs em `reports/`
- Detecção de artefatos promovíveis (heurísticas + confirmação)

## Exemplo de `EXECUTION_SUMMARY.md`

```markdown
# Execution Summary: TST-9D1F-01

## Objetivo
Limpar backend removendo código legado e preparando camadas para integração futura.

## Ações Principais
- Refatoração de módulos X e Y
- Introdução de camada de abstração Z
- Remoção de dependências obsoletas

## Riscos / Pendências
- Validar impacto em jobs assíncronos
- Confirmar compatibilidade com pipeline CI

## Próximos Passos
1. Executar suíte de regressão ampliada
2. Preparar spec de integração de permissionamento

## Decisões Emergentes
- Adotado padrão de DTOs versionados para endpoints críticos

## Resultado
Estrutura mais modular e cobertura de testes +8%.
```

## Erros Comuns a Evitar

- Colocar conteúdo normativo definitivo aqui (mover para `system/specs`)
- Usar workspace como dumping ground de arquivos binários grandes sem propósito
- Falta de fechamento formal (workspace fica órfão sem summary)

## Checklist de Encerramento

- [ ] Artefatos promovíveis avaliados
- [ ] Resumo final criado (`EXECUTION_SUMMARY.md`) ou `handoff.json` atualizado
- [ ] Referências cruzadas adicionadas nas specs/knowledge promovidas
- [ ] Diretório limpo de resíduos não necessários

---

Este diretório apoia o fluxo multi-agente fornecendo isolamento e rastreabilidade sem comprometer a curadoria dos domínios normativos do SDE Workspace.

---

## Handoffs (Modelo Estruturado)

### Visão Geral

O handoff é o contrato de passagem de contexto entre agentes. Ele reduz perda de informação, explicita decisões e prepara o próximo passo. A versão inicial (v1) foca em estrutura sem validação rígida; a partir da Fase 9 serão aplicadas validações de schema, hashing de artefatos e enum de fases.

### Exemplo (v1)

```jsonc
{
  "version": 1,
  "id": "handoff-2025-10-06T13:00:00Z-architect",
  "timestamp": "2025-10-06T13:00:00Z",
  "from_agent": "architect",
  "to_agent": "developer",
  "phase": "INITIALIZING",
  "previous_handoff_id": null,
  "source_spec": "spec-tst-9d1f-01-clean-backend.md",
  "summary": "Refino de escopo concluído. Endpoints normalizados. Riscos mapeados.",
  "context": {
    "specs": ["specs/spec-tst-9d1f-01-clean-backend.md"],
    "decisions": ["ADR-001"],
    "references": ["knowledge/internal/concepts/padrao-mapeamento.md"],
    "risks": [ { "id": "RISK-001", "severity": "medium", "description": "Acoplamento em módulo legado" } ]
  },
  "artifacts_produced": [
    { "path": "specs/spec-tst-9d1f-01-clean-backend.md", "hash": "<sha256>", "type": "spec" }
  ],
  "decisions": [ { "id": "ADR-001", "status": "accepted", "summary": "Usar padrão DTO versionado" } ],
  "pending_questions": [],
  "next_actions": [ { "owner": "developer", "description": "Implementar endpoints base", "priority": "high" } ],
  "metrics": { "clarification_requests": 0, "context_completeness_score": 0.85 },
  "agents_progress": { "architect": { "completed": true, "artifact": "specs/spec-tst-9d1f-01-clean-backend.md" }, "developer": { "completed": false } },
  "quality_signals": {},
  "delta_summary": null,
  "notes": []
}
```

### Evolução (v2+ Planejado)

- `delta_summary`: Contará artifacts_new, artifacts_modified, decisions_added/updated.
- `quality_signals.knowledge`: Métricas de resolução (hits internas vs externas, gaps registrados).
- Enum para `phase` (INITIALIZING, DESIGN, IMPLEMENTATION, QA_REVIEW, TECH_REVIEW, PM_VALIDATION, ARCHIVED).
- Hash obrigatório e validado para cada entrada de `artifacts_produced`.

### Tabela de Campos

| Campo | Tipo | Obrigatório | Estabilidade | Notas |
|-------|------|-------------|--------------|-------|
| version | int | sim | estável | >=1; incrementa por novo handoff criado |
| id | string | sim | estável | `handoff-<ISO>-<agent>` |
| timestamp | string (ISO8601) | sim | estável | UTC |
| from_agent | string | sim | estável | Emissor do handoff |
| to_agent | string | sim | estável | Próximo agente esperado |
| phase | string | sim | muda Fase 9 | Passará a enum validada |
| previous_handoff_id | string/null | sim | estável | Null apenas no primeiro |
| source_spec | string | sim | estável | Caminho da spec principal |
| summary | string | sim | estável | Até ~6 linhas |
| context.specs | array[string] | sim | estável | Referências a specs |
| context.decisions | array[string] | opcional | estável | IDs de decisões |
| context.references | array[string] | opcional | estável | Outros docs internos |
| context.risks | array[obj] | opcional | expandindo | severity: low/medium/high |
| artifacts_produced | array[obj] | opcional | expandindo | Hash validado a partir Fase 9 |
| decisions | array[obj] | opcional | estável | Resumo inline de decisões |
| pending_questions | array[string] | opcional | estável | Perguntas para próximo agente |
| next_actions | array[obj] | opcional | estável | Backlog imediato |
| metrics | object | opcional | expandindo | context_completeness_score (0..1) |
| agents_progress | object | opcional | expandindo | Estado sintético por agente |
| quality_signals | object | reservado | futuro | Preenche Fase 9–10 |
| delta_summary | object/null | reservado | futuro | Ativo se version > 1 |
| notes | array[string] | opcional | estável | Observações livres |

### Regras Operacionais (v1)

1. PM cria primeiro handoff (previous_handoff_id = null).
2. Cada agente ao concluir sua fase gera um novo handoff apontando para o anterior.
3. `summary` deve ser factual e não narrativo prolixo.
4. Se `artifacts_produced` vazio, justificar em `notes`.

### Checklist de Criação

- [ ] Preencheu summary objetivo
- [ ] Referenciou spec principal em source_spec
- [ ] Atualizou artifacts_produced com caminhos relativos
- [ ] Preencheu risks (se houver)
- [ ] Definiu próximo agente em to_agent

### Preparação para Validação (Fase 9)

Será introduzido: `handoff.schema.json` + script `validate_handoff.sh` validando:

- Estrutura (JSON Schema)
- Hash dos artefatos referenciados
- Enum de phase
- Consistência previous_handoff_id

### FAQ

Q: Por que JSON e não YAML?  
A: Estrutura mais rígida para consumo por scripts e tooling incremental.

Q: Por que hash cedo se ainda não validamos?  
A: Garante retrocompatibilidade quando validação for ativada; já incentiva disciplina.

Q: Posso editar handoff anterior?  
A: Evite. Gere novo handoff incremental — o histórico deve ser apendado, não reescrito.

---
