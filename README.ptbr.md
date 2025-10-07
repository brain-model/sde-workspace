# SDE Workspace

**[ [EN](README.md) | [PT](README.ptbr.md) ]**

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

O Software Development Environment (SDE) Workspace é um ecossistema multiagente orientado a domínio que transforma requisitos de negócio em software pronto para produção. Ele organiza conhecimento institucional, automatiza governança de especificações e integra fluxos inteligentes com o GitHub Copilot.

## Por que o SDE Workspace importa

- **Fonte única da verdade**: Manifestos versionados para specs, conhecimento, prompts e workflows.
- **Fluxos nativos de IA**: Chatmodes especializados (Arquiteto, Developer, QA, Reviewer, PM, Orchestrator) provisionados automaticamente.
- **Operação confiável**: Scripts monitoram drift, validam manifestos, calculam hashes e geram relatórios de saúde semanais.

## Arquitetura em destaque

```text
.sde_workspace/
├── system/                    # Núcleo normativo (specs, prompts, templates, scripts)
│   ├── specs/                 # Specs com lifecycle (draft → archived)
│   ├── agents/                # Prompts e capacidades dos agentes
│   ├── guides/                # Guias de contribuição e fluxos
│   ├── templates/             # Modelos de specs / knowledge / relatórios
│   ├── backlog/               # Itens de trabalho estruturados
│   ├── handoffs/              # Artefatos formais de handoff entre agentes
│   ├── scripts/               # CLIs de automação (veja abaixo)
│   └── schemas/               # JSON Schemas usados pelos validadores
├── knowledge/                 # Base de conhecimento interna e externa
│   ├── internal/              # Conceitos, runbooks, referências, notas
│   ├── external/              # Normas, vendors, pesquisas, transcrições
│   └── manifest.json          # Índice gerado automaticamente
└── .github/
    └── copilot-instructions.md / chatmodes/ (apenas edições Copilot)
```

### Ciclo de vida das especificações

| Estado | Objetivo | Automação principal |
|--------|----------|---------------------|
| `draft` | Ideação inicial | Scaffold via templates |
| `in-review` | Análise colaborativa | Checklists de handoff |
| `active` | Norma vigente | Promoção no manifesto |
| `deprecated` | Orientação substituída | Agendamento de arquivamento |
| `archived` | Histórico congelado | Validação de integridade |

## Fluxo guiado por agentes

1. **Setup** detecta stack e configura a estrutura na primeira execução.
2. **PM** orquestra prioridades e encaminha tarefas entre os agentes.
3. **Arquiteto → Developer → QA → Reviewer** iteram handoffs validados.
4. **Serviços de conhecimento** indexam decisões, runbooks e gaps reutilizáveis.

## Pré-requisitos

O instalador passa a verificar dependências obrigatórias antes do clone. Instale-as previamente para evitar interrupções:

| Ferramenta | Uso | Documentação |
|------------|-----|--------------|
| `git` | Clonar o repositório | [git-scm.com/downloads](https://git-scm.com/downloads) |
| `curl` *(ou `wget`)* | Bootstrap remoto | [curl.se/download.html](https://curl.se/download.html) |
| `jq` | Processamento JSON nos scripts | [jqlang.github.io/jq/download](https://jqlang.github.io/jq/download/) |
| `yq` | Parse de front-matter YAML | [github.com/mikefarah/yq](https://github.com/mikefarah/yq/#install) |
| `sha256sum` | Hash de artefatos & validação de manifestos | [GNU coreutils](https://www.gnu.org/software/coreutils/coreutils.html#sha256sum-invocation) |

Opcionais recomendados:

- `yajsv` para validação JSON Schema ([github.com/neilpa/yajsv](https://github.com/neilpa/yajsv))
- Em macOS, instale `coreutils` (`brew install coreutils`) para disponibilizar `sha256sum`

Se algo estiver ausente, o `install.sh` encerra com mensagem explicativa e links oficiais.

## Instalação rápida

```bash
curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/master/boot.sh | bash
```

Durante o processo escolha entre:

1. `default-ptbr` – estrutura base em Português Brasil
2. `default-enus` – estrutura base em Inglês
3. `copilot-ptbr` – base + chatmodes do Copilot (pt-BR)
4. `copilot-enus` – base + chatmodes do Copilot (en-US)

As edições Copilot populam `.github/chatmodes/` e `.github/copilot-instructions.md` sem sobrescrever arquivos existentes.

### Instalação manual

```bash
git clone https://github.com/brain-model/sde-workspace.git
cd sde-workspace
./install.sh
```

O instalador realiza sparse checkout de `.sde_workspace/` para o flavour escolhido e mescla chatmodes somente quando necessário.

## Scripts de automação

Todos os utilitários CLI ficam em `.sde_workspace/system/scripts/` e compartilham códigos de saída consistentes (0 sucesso / 8 dependência ausente). Destaques:

| Script | Finalidade | Dependências chave |
|--------|------------|--------------------|
| `scan_knowledge.sh` | Reconstroi `knowledge/manifest.json` com hashes & métricas | `jq`, `yq`, `sha256sum` |
| `validate_manifest.sh` | Valida schema, tags, drift e órfãos | `jq`, `yajsv` (opcional) |
| `report_knowledge_health.sh` | Relatório de saúde (md/json) | `jq` |
| `report_knowledge_metrics.sh` | Calcula reuse ratio, violações de prioridade, gaps | `jq` |
| `report_knowledge_weekly.sh` | Sumário semanal + gaps P1 abertos | `jq` |
| `resolve_knowledge.sh` | Resolve conhecimento determinístico e cria gaps | `jq`, `grep` |
| `compute_artifact_hashes.sh` | Atualiza hashes de artefatos de handoff | `jq`, `sha256sum` |
| `validate_handoff.sh` | Validação completa de handoff | `jq`, `sha256sum`, `yajsv`* |
| `apply_handoff_checklist.sh` | Completa checklists por fase | `jq` |
| `archive_deprecated.sh` | Arquiva artefatos deprecated > 90 dias | `jq`, `date` |

*`yajsv` habilita validação formal de schema; sem ele o script segue com aviso.

Cada script imprime mensagens `[tool:ERROR]` ao detectar dependências ausentes—corrija o ambiente e rode novamente.

## Governança de conhecimento

- **Front-matter padronizado** garante metadata consistente em specs e documentos.
- **Gestão de gaps** (`resolve_knowledge.sh`) eleva perguntas sem resposta para `.sde_workspace/knowledge/gaps/` com rastreabilidade.
- **Relatórios periódicos** tornam visíveis indicadores de reutilização, drift e backlog crítico.

## Contribuição & suporte

- Leia o [Guia de Contribuição](CONTRIBUTING.ptbr.md) para workflow, commits semânticos e processo de revisão.
- Acompanhe decisões arquiteturais e roadmap em [CHANGELOG.ptbr.md](CHANGELOG.ptbr.md).
- Precisa de ajuda? Abra uma [issue](https://github.com/brain-model/sde-workspace/issues) e consulte os guias em `.sde_workspace/system/guides/`.

## Licença

Distribuído sob licença MIT. Consulte o arquivo [LICENSE](LICENSE) para detalhes.
