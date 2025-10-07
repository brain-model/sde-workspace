# Template de Header YAML para Artefatos de Conhecimento

Todo artefato salvo em `.sde_workspace/knowledge/**` deve iniciar com um bloco YAML seguindo este formato. Ele garante que o scanner de conhecimento consiga indexar o arquivo e verificar rastreabilidade.

```markdown
---
id: <identificador-unico>
type: <tipo-do-artefato>
maturity: draft|review|stable|deprecated
tags: [tag-principal, outra-tag]
linked_gaps: [GAP-2025-10-06-001]
linked_decisions: [DEC-003]
created_by: architect
source_origin: internal
created_utc: 2025-10-06T12:00:00Z
updated_utc: 2025-10-06T12:00:00Z
supersedes: null
superseded_by: null
---
```

## Campos Obrigatórios

- **id**: slug único dentro da base de conhecimento. Use letras minúsculas, números e hífens.
- **type**: categoria funcional do artefato (ex.: `concept`, `decision`, `runbook`, `reference`).
- **maturity**: estágio atual (`draft`, `review`, `stable`, `deprecated`).
- **tags**: lista com pelo menos uma tag registrada em `tags_registry.json`.
- **linked_gaps** ou **linked_decisions**: pelo menos um dos campos deve conter referência válida; utilize `[]` quando não houver itens para o outro campo.
- **created_by**: agente responsável pela criação (`architect`, `developer`, `qa`, `reviewer`, `pm`, `documentation`, `devops`).
- **source_origin**: `internal`, `external_curated` ou `external_raw`.
- **created_utc** / **updated_utc**: timestamps ISO8601.

## Campos Opcionais

- **supersedes**: caminho relativo do artefato que este substitui. Use `null` quando não se aplica.
- **superseded_by**: será preenchido automaticamente pelo fluxo de supersede.

> Após editar um arquivo, execute `./.sde_workspace/system/scripts/scan_knowledge.sh` para recalcular hashes, atualizar o manifest e validar os metadados.
