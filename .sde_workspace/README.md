# SDE Workspace### 🤖 Fluxo Orientado por IA

- **Setup Inteligente**: Detecção automática de tecnologias e configuração personalizada na primeira execução
- **Integração GitHub Copilot**: Aprimorado with chatmodes especializados para diferentes contextos de desenvolvimento
- **Agentes Inteligentes**: Arquiteto, Desenvolvedor, QA, Revisor, Product Manager com prompts de configuração automática
- **Indexação Automatizada**: Manifestos auto-gerado## 17. Contato & Governança para descoberta e navegação eficienteoftware Development Environment (SDE) Workspace** é um sistema multi-agente autônomo para desenvolvimento de software que fornece um ambiente estruturado com agentes especializados para transformar requisitos de negócio em código de alta qualidade através de um ciclo de desenvolvimento automatizado.

Este documento estabelece o domínio único e previsível onde especificações normativas passam por um ciclo de vida formal, conhecimento institucional fica organizado e navegável, e ferramentas/agentes podem indexar rapidamente manifestos canônicos sem heurísticas frágeis.

## 1. Visão Geral da Arquitetura

### 🏗️ Sistema de Desenvolvimento Estruturado

- **Ciclo de Vida de Especificações**: Fluxo formal para specs (draft → in-review → active → deprecated → archived)
- **Sistema Multi-Agente**: Agentes AI especializados para diferentes funções de desenvolvimento
- **Gestão de Conhecimento**: Repositórios organizados de conhecimento interno e externo
- **Baseado em Templates**: Templates padronizados para documentação consistente

### 🤖 Fluxo Orientado por IA

- **Integração GitHub Copilot**: Aprimorado com chatmodes especializados para diferentes contextos de desenvolvimento
- **Agentes Inteligentes**: Arquiteto, Developer, QA, Reviewer, Product Manager e Orchestrator
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
├── arquiteto.chatmode.md        # Agente focado em arquitetura
├── arquiteto.chatmode.md        # Agente focado em arquitetura
├── desenvolvedor.chatmode.md        # Agente focado em desenvolvimento
├── orchestrator.chatmode.md     # Agente de orquestração
├── pm.chatmode.md              # Agente de gerenciamento de produto
├── qa.chatmode.md              # Agente de garantia de qualidade
└── revisor.chatmode.md        # Agente de revisão de código
```

### 🚀 Primeira Execução - Setup Automático

Na primeira execução de qualquer agente, o SDE detectará automaticamente que precisa ser configurado e executará o **Prompt de Setup**. Este processo:

1. **Analisa seu projeto** detectando:
   - Linguagens de programação utilizadas
   - Frameworks e bibliotecas principais
   - Ferramentas de build e deployment
   - Padrões arquiteturais
   - Estrutura de diretórios

2. **Gera recomendações personalizadas** para:
   - Templates de documentação específicos
   - Base de conhecimento externa relevante
   - Padrões e guias de estilo apropriados
   - Recursos de aprendizado gratuitos

3. **Configura o ambiente SDE** com:
   - Estrutura de conhecimento adaptada
   - Templates especializados
   - Referências de documentação oficial
   - Guias específicos da tecnologia detectada
   - **Instruções otimizadas para GitHub Copilot**

4. **Produz artefatos de knowledge**:
   - `.github/copilot-instructions.md` - Instruções otimizadas para AI coding agents
   - `project-analysis.md` - Análise completa do projeto
   - `technology-stack.md` - Resumo das tecnologias detectadas  
   - `external-resources.md` - Lista curada de recursos recomendados

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
  "description": "Knowledge base manifest for project platform documentation and internal notes",
  "repositories": {
    "internal": {
      "type": "knowledge-base",
      "governance": "contextual-information",
      "description": "Internal curated knowledge and meeting notes"
    },
    "project-docs": {
      "type": "official-documentation", 
      "governance": "reference-documentation",
      "description": "Official project documentation from upstream repository",
      "path": ".sde_workspace/knowledge/external/vendor-docs/project"
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

## 16. FAQ Rápido

### 🤖 Agentes Disponíveis

#### Prompt de Setup (Execução Automática)

- **Função**: Configuração inicial automática do SDE  
- **Quando executado**: Automaticamente na primeira execução quando `project-analysis.md` não existe
- **Características**:
  - Detecta tecnologias e padrões do projeto
  - Gera configuração personalizada
  - Recomenda recursos de documentação  
  - Configura estrutura de knowledge adaptada
  - **Gera/atualiza `.github/copilot-instructions.md` automaticamente**
  - Preserva instruções existentes mesclando com novas descobertas
- **Localização**: `.sde_workspace/system/prompts/setup.md`

#### Agente Arquiteto

- **Função**: Design de sistemas e especificações técnicas
- **Entrada**: Requisitos de produto ou itens de backlog
- **Saída**: Documentos de especificação técnica detalhados
- **Processo**: Graph-of-Thought (GoT) para design de arquitetura

#### Agente Developer

- **Função**: Implementação de código e versionamento
- **Entrada**: Documentos de especificação aprovados
- **Saída**: Código implementado, branches Git, Merge Requests
- **Processo**: Ciclo de desenvolvimento com Git workflows avançados

#### Agente QA

- **Função**: Garantia de qualidade e testes
- **Entrada**: Código implementado em branches
- **Saída**: Relatórios de QA e validação de qualidade
- **Processo**: Análise adversarial e testes abrangentes

#### Agente Reviewer

- **Função**: Revisão técnica de código
- **Entrada**: Merge Requests prontos para review
- **Saída**: Code review detalhado e feedback técnico
- **Processo**: Análise de Clean Code, arquitetura e segurança

#### Agente PM (Product Manager)

- **Função**: Orquestração do fluxo de trabalho
- **Entrada**: Estado das tarefas em desenvolvimento
- **Saída**: Roteamento e coordenação entre agentes
- **Processo**: Máquina de estados para gestão de workflow

### 🔄 Fluxo de Trabalho dos Agentes

1. **Setup** → Configuração inicial (apenas primeira vez)
2. **PM** → Orquestração e priorização
3. **Arquiteto** → Design e especificações
4. **Developer** → Implementação
5. **QA** → Validação e testes
6. **Reviewer** → Code review
7. **PM** → Arquivamento e próxima tarefa

### ⚡ Verificação Automática de Setup

Todos os agentes verificam automaticamente se existe o arquivo `project-analysis.md`. Se não existir:

1. Executam automaticamente o prompt de configuração inicial
2. Redirecionam para `#file:setup.md` para análise do projeto
3. Garantem que o SDE está configurado antes de prosseguir com as tarefas

Esta verificação garante que o ambiente está sempre otimizado para o projeto específico.

### 🛡️ Sistema de Validação de Integridade

Todos os agentes executam validações automáticas de integridade sempre que acessam arquivos em `/knowledge` ou `/system`:

#### Validações Automáticas

- **Frontmatter Completo**: Verifica se todos os campos obrigatórios estão presentes
- **Manifestos Sincronizados**: Confirma que arquivos estão listados nos manifestos
- **Localização Consistente**: Valida se arquivos estão nas pastas corretas
- **Referências Válidas**: Verifica links e referências internas

#### Auto-Correção Inteligente

- **Frontmatter Ausente**: Gera automaticamente baseado em heurísticas
- **Manifestos Desatualizados**: Adiciona/atualiza entradas automaticamente  
- **Checksums Incorretos**: Recalcula e atualiza automaticamente
- **Inconsistências**: Sugere correções com confirmação do usuário

#### Mensagens de Validação

```bash
🔍 VALIDAÇÃO DE INTEGRIDADE DETECTOU PROBLEMAS:
- Arquivo sem frontmatter: AUTO-CORRIGIDO
- Manifesto desatualizado: AUTO-CORRIGIDO  
- Referência quebrada: MARCADO PARA REVISÃO

✅ Base de conhecimento íntegra e confiável!
```

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
