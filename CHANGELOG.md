# Changelog

Formato baseado em Keep a Changelog e versionamento semântico adaptado.

> Política de versão: sempre `0.x.y` até estabilização geral. Major fixo em `0` (fase experimental).  
> Minor (x): marcos estruturais (conclusão de blocos de fases de arquitetura / automação).  
> Patch (y): correções, refactors menores, ajustes de documentação e scripts.  
> Nunca usar `1` como major enquanto o sistema não atingir estabilidade completa (governança + automação + métricas maduras).

## [Unreleased]

### Planejado

- Otimizações de performance nos scripts de validação
- Extensão do sistema de métricas para dashboards
- Integração com CI/CD pipelines externos

## [0.11.0] - 2025-10-07

### 🎯 Marco: Sistema de Governança e Conhecimento Completo

Esta versão marca a conclusão do sistema avançado de governança, continuidade de contexto e gestão de conhecimento, estabelecendo um framework completo para desenvolvimento assistido por IA.

### Added

#### 🔄 Sistema de Continuidade de Contexto (Fase 9)
- **Handoffs Estruturados**: Template padronizado (`handoff_template.json`) com validação de schema
- **Máquina de Estados**: Enum de fases governado pelo PM (INITIALIZING → DESIGN → IMPLEMENTATION → QA_REVIEW → TECH_REVIEW → PM_VALIDATION → ARCHIVED)
- **Validação Automática**: Script `validate_handoff.sh` com verificação de hash SHA-256 para artifacts
- **Utilitário de Hash**: `compute_artifact_hashes.sh` para cálculo automático de integridade
- **Diretório Centralizado**: `.sde_workspace/system/handoffs/` para histórico e latest.json
- **Delta Tracking**: Contagem automática de artifacts_new/modified nos handoffs
- **Quality Signals**: Métricas de clarification_requests e context_completeness_score
- **Enforcement Multi-Agente**: Validação de pré-condições em todos os 7 agentes
- **Checklist Automático**: Geração de saída padronizada pós-execução

#### 📚 Sistema de Resolução de Conhecimento (Fase 10) 
- **Política de Priorização**: Hierarquia obrigatória (Internal → External Curado → External Raw → Internet)
- **Gap Management**: Template `gap_template.json` e diretório `knowledge/gaps/`
- **Script de Resolução**: `resolve_knowledge.sh` com busca, ranking e logging automático
- **Códigos de Erro Específicos**: KNOWLEDGE_PRIORITY_VIOLATION, EXTERNAL_JUSTIFICATION_REQUIRED, GAP_NOT_REGISTERED
- **Enforcement de Conhecimento**: Snippets resolver(query) em todos os agentes
- **Eventos de Execução**: KNOWLEDGE_HIT_INTERNAL, GAP_CREATED para rastreabilidade
- **Métricas Operacionais**: reuse_ratio, priority_violations, gaps_opened
- **Relatório Semanal**: Agregação automática de métricas e gaps P1
- **Pré-condições**: Verificação de artefato indexado ou gap registrado

#### 🗂️ Sistema de Indexação e Manifest (Fase 11)
- **Schema Estendido**: `knowledge_manifest.schema.json` com campos de maturidade e rastreabilidade
- **Scanner Incremental**: `scan_knowledge.sh` com hash SHA-256 e atualização atômica
- **Validação Completa**: `validate_manifest.sh` (schema, órfãos, drift, tags)
- **Ciclo de Vida de Artefatos**: Scripts para promoção (`promote_artifact.sh`), supersessão (`supersede_artifact.sh`) e arquivamento (`archive_deprecated.sh`)
- **Templates Padronizados**: `metadata_header.md` para cabeçalhos YAML obrigatórios
- **Registry de Tags**: `tags_registry.json` com taxonomia inicial (architecture, runbook, decision, concept)
- **Relatório de Saúde**: `report_knowledge_health.sh` com métricas consolidadas
- **Enforcement de Indexação**: Bloqueio de uso de artefatos não indexados
- **Métricas de Integridade**: index_latency_avg, orphan_artifacts, drift_incidents

#### 🤖 Agentes Especializados (Fase 8)
- **Agente de Documentação**: `documentacao.md` para geração de specs secundárias e runbooks
- **Agente DevOps**: `devops.md` para pipelines, infraestrutura e integração CI/CD
- **Integração no Ciclo**: PM → Arquiteto → (Documentação/DevOps) → Developer → QA → Reviewer → PM

### Enhanced

#### 📋 Sistema de Agentes Existentes
- **Validação de Handoffs**: Todos os 7 agentes com snippet de validação obrigatória
- **Seções "Falhas Comuns & Mitigações"**: Códigos de erro específicos e soluções documentadas
- **Pré-condições**: Verificação automática de artefatos esperados e último handoff válido
- **Checklist de Saída**: Geração automática por agente (artefatos, manifest, handoff)
- **Enforcement Multi-camada**: Governança de conhecimento, indexação e continuidade

#### 🏗️ Infraestrutura de Governança
- **Manifest Estendido**: Ponteiro para último handoff (handoffs.latest)
- **Rastreabilidade Completa**: 100% artefatos com gap_id ou decision_id obrigatório
- **Integridade Garantida**: Hash verification em todos os workflows críticos
- **Workflow de Supersessão**: Registro bidirectional para substituições
- **Arquivamento Automático**: Deprecated > 90 dias movidos automaticamente

### Bug Fixes

#### 🔧 Correções Estruturais (Fases 1-6)
- **Gatilhos de Setup**: Correção de referências obsoletas ao "agente setup" inexistente
- **Organização de Arquivos**: Separação clara entre agentes (`.sde_workspace/system/agents/`) e prompts (`.sde_workspace/system/prompts/`)
- **Copilot Instructions**: Generalização para qualquer tipo de projeto (removido TypeScript/Backstage específico)
- **Duplicação .github**: Workaround documentado e correção no instalador
- **Template de Handoff**: Disponibilização de template canônico para troca de contexto

### Documentation

#### 📖 Documentação Abrangente
- **READMEs Atualizados**: Workflow completo, scripts, códigos de erro, checklists
- **Guias de Validação**: Procedimentos passo-a-passo para cada tipo de validação
- **Seções de Troubleshooting**: "Falhas Comuns & Mitigações" em todos os agentes
- **Fluxos Documentados**: Ciclo completo multi-agente com handoffs estruturados

### Metrics & Monitoring

#### 📊 Sistema de Métricas Operacionais
- **Conhecimento**: reuse_ratio ≥80%, priority_violations = 0, gaps P1 ≤24h
- **Indexação**: index_latency ≤60s, orphan_artifacts = 0, drift <2%
- **Continuidade**: context_completeness_score, clarification_requests, hash_mismatch = 0
- **Relatórios Automatizados**: Semanal (conhecimento), sob demanda (saúde)

### Technical Details

#### 🔧 Implementação
- **6 Novos Scripts Executáveis**: Automação completa de workflows críticos
- **2 Schemas JSON**: Validação rigorosa de handoffs e manifest
- **3 Templates**: Padronização de gaps, metadata e handoffs
- **872 Inserções, 76 Deleções**: Refatoração significativa mantendo compatibilidade
- **19 Arquivos Modificados**: Cobertura completa do sistema

#### 📋 Critérios de Aceitação Atingidos
- ✅ PM único iniciando/arquivando ciclos
- ✅ 100% execuções não-PM com handoff válido  
- ✅ Zero HASH_MISMATCH em handoffs aprovados
- ✅ 100% novos artefatos com rastreabilidade (gap_id/decision_id)
- ✅ Indexação atômica ≤60s para novos artefatos
- ✅ Zero artefatos órfãos após scanner
- ✅ Enforcement multi-agente operacional

## [0.10.0] - 2025-09-29

### Features

- Estrutura multi-agente inicial (arquiteto, desenvolvedor, qa, revisor, pm) com prompts reorganizados
- Diretório `.sde_workspace/system/prompts/` e migração de `setup.md` e `validador_integridade.md`
- Generalização de `copilot-instructions.md` para uso genérico e localização PT-BR
- Base de conhecimento estruturada (internal/external)
- Manifestos de especificações e controle de integridade inicial
- README principal e documentação reorganizada (instalação, fluxo de execução)

### Refactored

- Reorganização de scripts de instalação (`install.sh`) simplificando opções
- Reestruturação do setup Copilot (chatmodes PT-BR, unificação de diretórios)
- Ajustes de tradução e padronização de cabeçalhos

### Fixed

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

### Refactoring

- Organização inicial de diretórios para suportar múltiplos idiomas

### Maintenance

- Ajustes de formatação em listas e identação conforme lint

## [0.1.0] - 2025-09-22

### Initial Release

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
