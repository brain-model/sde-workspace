---
id: repo-mermaid-upstream
type: repository
maturity: draft
tags: ["repository", "mermaid", "diagram", "vendor"]
linked_gaps: ["GAP-2025-10-07T12:15:00Z"]
linked_decisions: []
created_by: pm
source_origin: external_curated
created_utc: 2025-10-09T00:00:00Z
updated_utc: 2025-10-09T00:00:00Z
supersedes: null
superseded_by: null
artifacts:
  - type: readme
    path: vendor-docs/mermaid/README.md
    description: README upstream mermaid-js
  - type: docs
    path: vendor-docs/mermaid/docs/
    description: Documentação principal mermaid-js
---

# Repositório Mermaid (Upstream)

Fonte externa incorporada parcialmente (README + docs) para referência de padrões de diagramação (Mermaid syntax, configuração, theming, extensões e integração CLI).

## Escopo Importado

- `README.md`: visão geral, instalação e exemplos de uso
- `docs/`: sintaxe detalhada, configuração, theming, integração, segurança, contribuições

## Justificativa

Mermaid é adotado como notação padrão para diagramas (workflows, arquiteturas e estados) no ecossistema Magma. Ter a documentação versionada localmente:

1. Garante resiliência a mudanças upstream
2. Permite indexação/offline e eventual processamento sem custo de requests externos
3. Facilita curadoria de um "golden subset" de práticas

## Próximos Passos Sugeridos

- Avaliar criação de um resumo interno (summary) com guidelines adaptadas
- Marcar seções prioritárias para onboarding (syntax-reference, configuration, theming)
- Definir política de atualização (ex: sincronizar a cada release minor upstream)
