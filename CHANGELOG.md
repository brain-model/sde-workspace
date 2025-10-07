# Changelog

Formato baseado em Keep a Changelog e versionamento semântico adaptado.

> Política de versão: sempre `0.x.y` até estabilização geral. Major fixo em `0` (fase experimental).  
> Minor (x): marcos estruturais (conclusão de blocos de fases de arquitetura / automação).  
> Patch (y): correções, refactors menores, ajustes de documentação e scripts.  
> Nunca usar `1` como major enquanto o sistema não atingir estabilidade completa (governança + automação + métricas maduras).

## [Unreleased]

### Planejado

- Implementação completa da Fase 9 (continuidade de contexto) — handoffs com schema e validação
- Scripts: `validate_handoff.sh`, `resolve_knowledge.sh`, `scan_knowledge.py`, `validate_manifest.sh`, `promote_artifact.sh`
- Enforcement de resolução de conhecimento (prioridade de fontes + gaps)
- Indexação canônica de conhecimento e supersede workflow
- Relatórios semanais (métricas de conhecimento e saúde de indexação)

### Em Progresso

- Template de handoff criado (Fase 7)
- Planejamento de agentes Documentação e DevOps (Fase 8)
- Redistribuição de workflow antigo dentro das novas fases 9–11

## [0.9.0] - 2025-09-29

### Adicionado

- Estrutura multi-agente inicial (arquiteto, desenvolvedor, qa, revisor, pm) com prompts reorganizados
- Diretório `.sde_workspace/system/prompts/` e migração de `setup.md` e `validador_integridade.md`
- Generalização de `copilot-instructions.md` para uso genérico e localização PT-BR
- Base de conhecimento estruturada (internal/external)
- Manifestos de especificações e controle de integridade inicial
- README principal e documentação reorganizada (instalação, fluxo de execução)

### Refatorado

- Reorganização de scripts de instalação (`install.sh`) simplificando opções
- Reestruturação do setup Copilot (chatmodes PT-BR, unificação de diretórios)
- Ajustes de tradução e padronização de cabeçalhos

### Corrigido

- Remoção de referências ao agente inexistente `setup`
- Correção de duplicidades de chatmodes e normalização de instruções
- Documentação do problema de duplicação `.github` + workaround

### Base de Commits (Resumo)

- feat: initial commit (sistema autônomo inicial)
- feat: setup de chatmodes e instruções Copilot
- docs/readme: melhorias de instalação e idioma
- refactor: reorganização de estrutura e instalação
- feat: simplificação do install script
- feat: sincronização branch PT-BR e tradução
- fix: ajustes de tradução e inclusão de pm.chatmode
- feat: criação do plano de evolução (migração para estrutura faseada)

## [0.5.0] - 2025-09-24

### Adicionado

- Script de instalação interativo com seleção de branch/idioma
- Chatmodes PT-BR iniciais para Arquiteto, Dev, QA e Revisor

### Refatorado

- Organização inicial de diretórios para suportar múltiplos idiomas

### Corrigido

- Ajustes de formatação em listas e identação conforme lint

## [0.1.0] - 2025-09-22

### Adicionado

- Commit inicial do sistema: setup Copilot + geração de chatmodes + instruções

---

## Racional de Recalibração de Versões

A numeração anterior mencionava implicitamente uma versão "1.x" na comunicação, porém o sistema ainda está em fase de consolidação arquitetural e governança — portanto foi adotada a política experimental contínua `0.x.y`. O marco atual consolida a infraestrutura multi-agente e baseline de documentação → definido como `0.9.0` (próximo salto para `0.10.0` quando: handoffs validados + enforcement de resolução + indexação canônica operante).

## Próximos Marcos (Roadmap de Versionamento)

- 0.10.0: Handoffs validados + política de resolução enforce + manifest index incremental
- 0.11.0: Métricas automatizadas + relatórios semanais + supersede workflow
- 0.12.0: Agentes Documentação e DevOps ativos + integração total de ciclo
- 0.20.0: Consolidação de maturidade (estabilidade de hashes <2% drift + cobertura de gaps crítica)

[Unreleased]: ./CHANGELOG.md#unreleased
[0.9.0]: ./CHANGELOG.md#090---2025-09-29
[0.5.0]: ./CHANGELOG.md#050---2025-09-24
[0.1.0]: ./CHANGELOG.md#010---2025-09-22
