# SDE Workspace

**Software Development Environment (SDE) Workspace** é um sistema multi-agente autônomo para desenvolvimento de software que fornece um ambiente estruturado com agentes especializados para transformar requisitos de negócio em código de alta qualidade através de um ciclo de desenvolvimento automatizado.

Este documento estabelece o domínio único e previsível onde especificações normativas passam por um ciclo de vida formal, conhecimento institucional fica organizado e navegável, e ferramentas/agentes podem indexar rapidamente manifestos canônicos sem heurísticas frágeis.

## 1. Visão Geral da Arquitetura

### 🏗️ Sistema de Desenvolvimento Estruturado

- **Ciclo de Vida de Especificações**: Fluxo formal para specs (draft → in-review → active → deprecated → archived)
- **Sistema Multi-Agente**: Agentes AI especializados para diferentes funções de desenvolvimento
- **Gestão de Conhecimento**: Repositórios organizados de conhecimento interno e externo
- **Baseado em Templates**: Templates padronizados para documentação consistente

### 🤖 Fluxo Orientado por IA

- **Integração GitHub Copilot**: Aprimorado com chatmodes especializados para diferentes contextos de desenvolvimento
- **Agentes Inteligentes**: Architect, Developer, QA, Reviewer, Product Manager e Orchestrator
- **Indexação Automatizada**: Manifestos auto-gerados para descoberta e navegação eficiente

### 📚 Organização do Conhecimento

- **Fontes Externas**: Standards, documentação de fornecedores, papers de pesquisa, transcrições
- **Conhecimento Interno**: Conceitos, runbooks, contextos de decisão, guias de integração
- **Controle de Versão**: Rastreamento completo de mudanças e histórico para todas as especificações
- **Busca & Descoberta**: Indexação baseada em manifesto para localização rápida de conteúdo

## 1.1. Instalação e Configurações

### Instalação Rápida

Para instalar o SDE Workspace, use um único comando:

```bash
curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/master/boot.sh | bash
```

### Opções de Configuração

O instalador apresenta 4 opções de configuração:

1. **default-ptbr** - Português Brasil (versão padrão)
2. **default-enus** - English US (versão padrão)  
3. **copilot-ptbr** - Português Brasil (versão GitHub Copilot)
4. **copilot-enus** - English US (versão GitHub Copilot)

**Diferenças:**

- **Versões padrão**: Instalam apenas a estrutura core `.sde_workspace` com agentes, guias e templates
- **Versões Copilot**: Incluem chatmodes adicionais do GitHub Copilot em `.github/chatmodes/` para assistência AI aprimorada

### Estrutura Instalada

Após a instalação, você terá:

```bash
.sde_workspace/                    # Estrutura principal
├── system/                       # Sistema normativo central
│   ├── specs/                   # Especificações com gestão de ciclo de vida
│   ├── agents/                  # Definições e prompts de agentes AI
│   ├── guides/                  # Guias de desenvolvimento e fluxos de trabalho
│   ├── templates/               # Templates de documentos e artefatos
│   ├── backlog/                 # Itens de trabalho estruturados
│   └── workspaces/              # Áreas de trabalho guiado temporárias
├── knowledge/                    # Base de conhecimento classificada
│   ├── external/                # Fontes e documentação externa
│   └── internal/                # Conhecimento institucional
└── .github/
    └── copilot-instructions.md  # Configuração do Copilot
```

Para versões Copilot, também haverá:

```bash
.github/chatmodes/               # Modos de agente AI especializados
├── architect.chatmode.md        # Agente focado em arquitetura
├── developer.chatmode.md        # Agente focado em desenvolvimento
├── orchestrator.chatmode.md     # Agente de orquestração
├── pm.chatmode.md              # Agente de gerenciamento de produto
├── qa.chatmode.md              # Agente de garantia de qualidade
└── reviewer.chatmode.md        # Agente de revisão de código
```

## 2. Arquitetura da Estrutura

```bash
.sde_workspace/
  README.md                  ← Este documento
  system/                    ← Núcleo normativo e automações
    specs/                   ← Specs com lifecycle
      draft/
      in-review/
      active/
      deprecated/
      archived/
    agents/                  ← Config/prompts de agentes (curado)
    backlog/                 ← Itens de trabalho estruturados (curado)
    guides/                  ← Guias meta (como usar a estrutura / fluxos)
    templates/               ← Modelos de criação de specs/artefatos
    workspaces/              ← Áreas efêmeras de trabalho guiado (pode ser regenerado)
  knowledge/                 ← Base de conhecimento classificada
    external/                ← Fontes que vêm de fora da organização
      sources/
        raw/                 ← Artefatos originais (PDF, txt) — imutáveis
        processed/           ← Normalizações (markdown derivado) — gerado
      standards/             ← Normas de mercado (resumos internos)
      vendor-docs/           ← Materiais de fornecedores (curadoria)
      research/              ← Pesquisas, whitepapers, benchmarks externos
      transcripts/           ← Transcrições de reuniões externas / eventos
    internal/                ← Conhecimento institucional
      concepts/              ← Glossário e definições de domínio
      runbooks/              ← Procedimentos operacionais (execução)
      references/            ← Listas, catálogos, índices internos
      notes/
        raw/                 ← Notas brutas (captura rápida)
        summary/             ← Notas consolidadas/refinadas
      decisions-context/     ← Contextos narrativos de decisões (apoio às specs)
      integracao/            ← Integrações (fluxos, mapeamentos)
      templates/             ← Modelos de artefatos internos não normativos
      onboarding/            ← Guias de entrada e trilhas de aprendizado
```

Observações:

- Diretórios raiz `archive/` e `backlog/` NÃO existem nesta versão; qualquer alias externo só será criado quando a automação exigir.
- Conteúdo obsoleto permanece dentro de `system/specs/archived/` ou é movido para pastas históricas específicas definidas caso a caso.
- `system/guides/` diferencia-se de `runbooks/`: guides explicam COMO contribuir / navegar; runbooks explicam COMO operar/processar atividades de runtime.

## 3. Ciclo de Vida de Specs

Estados possíveis em `system/specs/`:

| Estado      | Objetivo | Critérios de Transição |
|-------------|----------|------------------------|
| draft       | Ideação inicial | Estrutura mínima + escopo claro |
| in-review   | Avaliação colaborativa | Revisores designados + feedback tratado |
| active      | Norma vigente | Aprovada e referenciada em implementações |
| deprecated  | Substituída / fase-out | Nova versão ou abordagem ativa publicada |
| archived    | Histórico congelado | Não deve mais ser referenciada operacionalmente |

Arquivamento move o arquivo para `archived/` preservando frontmatter e checksum.

## 4. Frontmatter Padrão

### Para Specs (system/specs/)

Cada spec deve iniciar with bloco YAML:

```markdown
---
id: spec-<slug>
title: <Título Descritivo>
type: (design-doc|adr|arch-analysis|process-spec|test-spec)
status: (draft|in-review|active|deprecated|archived)
version: 1.0.0
topics: [dominio, arquitetura, ...]
created: YYYY-MM-DD
updated: YYYY-MM-DD
supersedes: <id-anterior|null>
supersededBy: <id-posterior|null>
relations: [ids correlatos]
---
```

### Para Knowledge (knowledge/internal/)

Cada arquivo de knowledge deve usar esquema padronizado de 7 campos:

```markdown
---
id: <identificador-estavel>
title: <Título Legível>
category: (concept|meeting-notes|decision|design-document|chat-transcript|journey|note-raw)
created: YYYY-MM-DDTHH:MM:SS-03:00
updated: YYYY-MM-DDTHH:MM:SS-03:00
source: <origem-ou-url>
tags: ["tema1", "tema2", "curated|needs-curation"]
---
```

**Restrições**:

- `id` imutável (derivado do slug inicial).
- Atualize `updated` a cada modificação substantiva.
- Versionamento semântico incrementado em mudanças incompatíveis (specs apenas).

## 5. Manifesto de Indexação

### Specs Manifest

Arquivo: `system/specs/manifest.json` (gerado automaticamente). Contém lista de objetos:

```json
{
  "version": 2,
  "generatedAt": "2025-09-25T12:00:00Z",
  "specs": [
    {
      "id": "spec-nome",
      "path": "system/specs/active/spec-nome.md",
      "checksum": "sha256:...",
      "status": "active",
      "type": "design-doc",
      "topics": ["..."],
      "version": "1.2.0",
      "updated": "2025-09-10"
    }
  ]
}
```

### Knowledge Manifest

Arquivo: `knowledge/manifest.json` (gerado automaticamente). Indexa base de conhecimento:

```json
{
  "version": "2.0",
  "generatedAt": "2025-09-26T17:06:46.411497",
  "description": "Knowledge base manifest for Backstage platform documentation and internal notes",
  "repositories": {
    "internal": {
      "type": "knowledge-base",
      "governance": "contextual-information",
      "description": "Internal curated knowledge and meeting notes"
    },
    "backstage": {
      "type": "official-documentation", 
      "governance": "reference-documentation",
      "description": "Official Backstage documentation from upstream repository",
      "path": ".sde_workspace/knowledge/external/vendor-docs/backstage"
    }
  },
  "files": [...]
}
```

**Importante**: Não editar manifestos manualmente. Ferramenta regeneradora fará validações (unicidade de id, estado coerente, checksum atualizado).

## 6. Operação & Fluxo de Contribuição

1. Criar nova spec em `system/specs/draft/` utilizando um modelo de `system/templates/`.
2. Preencher frontmatter completo (exceto campos gerados).
3. Submeter PR para revisão → mover para `in-review/` quando existir revisão ativa.
4. A aprovação promove para `active/` (atualizar status + mover diretório + regenerar manifesto).
5. Obsolescência: mover para `deprecated/` (adicionar `supersededBy`).
6. Encerramento definitivo: mover para `archived/` mantendo vínculos.

Automação (futuro / planejado): validação de frontmatter, geração de manifesto e cálculo de checksums via script CI.

## 7. Base de Conhecimento (Knowledge)

Princípios:

- Separar origem externa vs institucional.
- Normalizar apenas o necessário (markdown em `processed/`).
- Não editar arquivos em `external/sources/raw/`.
- Consolidar notas: mover de `notes/raw` para `notes/summary` quando refinadas.

## 8. O Que Você Pode Editar

Editável (criar/alterar/remover via PR):

- `system/specs/*/*.md` (exceto manifesto)
- `system/guides/*`
- `system/backlog/*`
- `system/templates/*`
- `system/agents/*` (prompts / configs)
- `knowledge/internal/**/*`
- `knowledge/external/standards`, `vendor-docs`, `research`, `transcripts` (conteúdo sintetizado)

Não Editar Diretamente:

- `system/specs/manifest.json`
- `knowledge/manifest.json`
- Arquivos em `knowledge/external/sources/raw/`
- Artefatos derivados em `knowledge/external/sources/processed/` (regen automatizada)
- Checksums ou campos gerados nos manifestos

## 9. Convenções de Nomenclatura

- Slug: lowercase, separador `-`, sem acentos. Ex: `observability-pipeline-design`.
- Arquivo de spec: `spec-<slug>.md` (id interno reutiliza slug).
- Documentos knowledge: `<slug>.md` (ou formato original em `raw/`).
- PDFs mantêm nome fonte + data opcional: `fornecedor-produto-whitepaper-2025.pdf`.

## 10. Estrutura de Templates

`system/templates/` deve conter pelo menos:

- `spec-design-doc.md`
- `spec-adr.md`
- `spec-arch-analysis.md`
- `spec-process-spec.md`
- `spec-test-spec.md`
- `knowledge-note.md`
- `knowledge-runbook.md`

Cada template inclui frontmatter mínimo e seções obrigatórias com comentários guia.

## 11. Roadmap (Resumo)

- [x] ✅ **Script de geração de manifesto v2** - `dev/scripts/generate_knowledge_manifest.py`
- [x] ✅ **Frontmatter knowledge normalizado** - Schema 7 campos implementado
- [x] ✅ **Manifest knowledge funcional** - `knowledge/manifest.json` com repositórios  
- [x] ✅ **Agentes atualizados** - Product Manager + 4 agentes com novos manifests
- [ ] Validação automática de frontmatter (schema)
- [ ] CI para calcular checksums diffs
- [ ] Symlink/alias de backlog consolidado
- [ ] Indexação incremental para agentes

## 12. Boas Práticas

- Pequenas PRs por spec ou conjunto lógico.
- Atualize `topics` para melhorar busca semântica.
- Relacione specs correlatas via `relations` para navegação contextual.
- Promova deprecated rapidamente quando existir substituto aprovado.

## 13. FAQ Rápido

| Pergunta | Resposta |
|----------|----------|
| Posso editar os manifestos? | Não. Regenerados automaticamente pelos scripts. |
| Onde coloco transcript bruto? | `knowledge/external/transcripts/` ou `sources/raw/` se for arquivo original. |
| Onde entra um diagrama exportado? | Na mesma pasta do markdown correspondente ou `knowledge/internal/references/` se for genérico. |
| Como lido com PDF externo? | Coloque em `sources/raw/` e gere markdown em `processed/`. |
| Quando mover para archived? | Quando for somente histórico, sem uso operacional. |
| Qual a diferença entre os manifestos? | `specs/manifest.json` = documentos normativos; `knowledge/manifest.json` = conhecimento contextual. |

## 14. Contato & Governança

Revisores padrão definidos em `CODEOWNERS` (futuro). Enquanto ausente, use PR com pelo menos 1 aprovação de arquitetura + 1 de operação.
