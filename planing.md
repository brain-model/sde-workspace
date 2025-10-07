# Plano de Evolução e Correção - SDE v0.9.0 Copilot-PTBR

## Bugs Identificados e Melhorias Estruturais

### 1. Gatilho de Setup Obsoleto

**Problema:** Agentes ainda referenciam o agente 'setup' que foi excluído
**Localização:** Todos os agentes em `.sde_workspace/system/agents/`
**Impacto:** Usuários são direcionados para um agente inexistente

### 2. Copilot Instructions Específico

**Problema:** `copilot-instructions.md` contém orientações específicas para TypeScript/Backstage
**Localização:** `.sde_workspace/.github/copilot-instructions.md`
**Impacto:** Instruções não são genéricas para outros tipos de projeto

### 3. Duplicação do Diretório .github

**Problema:** Após instalação, `.github` fica duplicado (raiz + dentro `.sde_workspace`)
**Localização:** Script de instalação
**Impacto:** Confusão de qual arquivo usar e manutenção redundante
**Status:** Workaround documentado; correção definitiva pendente no script principal
**Workaround Manual:**

```bash
rm -rf .sde_workspace/.github
```

**Correção Proposta no Script:**

```bash
if [ -d ".github" ] && [ -d ".sde_workspace/.github" ]; then
 echo "Removendo duplicação do diretório .github..."
 rm -rf .sde_workspace/.github
fi
```

### 4. Arquitetura de Prompts vs Agentes

**Problema:** `setup.md` e `validador_integridade.md` são prompts, não agentes
**Localização:** `.sde_workspace/system/agents/`
**Impacto:** Organização incorreta do sistema

### 5. Ausência de Template de Handoff Padronizado

**Problema:** Não existe arquivo canônico para handoff entre agentes nos workspaces.
**Impacto:** Inconsistência na troca de contexto e automação futura prejudicada.
**Ação:** Criar `system/templates/handoff_template.json`.

### 6. Falta de Agentes Especializados para Documentação e DevOps

**Problema:** Fluxo de documentação e operações ainda depende de ações manuais.
**Impacto:** Menor cobertura de automação e padronização.
**Ação:** Criar agentes:

- `documentacao.md`: geração/síntese de specs secundárias, runbooks e notas
- `devops.md`: suporte a pipelines, verificação de infraestrutura, integração CI/CD

### 7. Refinamento do Workflow dos Agentes Existentes

**Problema:** Agentes atuais podem não validar estado anterior antes de executar próxima fase.
**Impacto:** Risco de saltos de fase ou inconsistência de artefatos.
**Ação:** Revisar cada agente para incluir checagem explícita de pré-condições e checklist de saída.

## Plano de Evolução e Correção

### 🚀 Features Principais (Major Changes)

1. **🏗️ Arquitetura SDE Completa** - Sistema `.sde_workspace/` com 4 módulos principais
2. **🤖 Sistema de Agentes** - 5 agentes especializados (arquiteto, desenvolvedor, qa, revisor, pm)
3. **📚 Base de Conhecimento** - Estrutura `knowledge/` com internal/external
4. **📋 Sistema de Especificações** - Gestão de specs com manifestos
5. **🛠️ Templates e Guias** - Templates completos e guias de desenvolvimento
6. **🌐 Localização PT-BR** - Todo sistema traduzido para português
7. **📋 Prompts Automatizados** - Setup automático e validação de integridade
8. **🔄 Sistema de Manifestos** - Controle de integridade com checksums

### Fase 1: Reorganização de Arquitetura ✅

- [x] Analisar estrutura atual e identificar problemas

### Fase 2: Criar Diretório de Prompts ✅

- [x] Criar `.sde_workspace/system/prompts/`
- [x] Mover `setup.md` para `prompts/`
- [x] Mover `validador_integridade.md` para `prompts/`
- [x] Atualizar referências nos READMEs

### Fase 3: Corrigir Gatilhos de Setup ✅

- [x] Atualizar `arquiteto.md` - remover referência ao agente setup
- [x] Atualizar `desenvolvedor.md` - redirecionar para prompt setup
- [x] Atualizar `pm.md` - corrigir instruções de primeira execução
- [x] Atualizar `qa.md` - ajustar gatilho de setup
- [x] Atualizar `revisor.md` - corrigir referências

### Fase 4: Generalizar Copilot Instructions ✅

- [x] Remover referências específicas a TypeScript/Backstage
- [x] Criar versão genérica adaptável a qualquer projeto
- [x] Manter referência aos guias de commit semântico

### Fase 5: Corrigir Duplicação do .github ✅ (Documentação) / ✅ (Script Definitivo)

- [x] Identificar onde ocorre a duplicação no processo de instalação
- [x] Documentar solução para instalação correta (apenas na raiz)
- [x] Adicionar documentação de workaround temporário
- [x] Aplicar correção no script de instalação (remoção pós-cópia)
  - Nota: correção já existente em outra branch; sincronizar na próxima junção de branches para evitar regressão.

### Fase 6: Atualizar Documentação ✅

- [x] Atualizar `README.md` com nova estrutura de prompts
- [x] Corrigir referências ao agente setup
- [x] Documentar o novo fluxo de primeira execução

### Fase 7: Template de Handoff ✅

- [X] Criar `system/templates/handoff_template.json`
- [x] Documentar campos e semântica no README de `workspaces/`
- [x] Incluir referência no fluxo multi-agente (seção Handoffs adicionada)

### Fase 8: Agentes de Documentação e DevOps 🚧

- [x] Criar `documentacao.md` em `system/agents/`
- [x] Criar `devops.md` em `system/agents/`
- [x] Definir perfis, gatilhos e critérios de saída
- [x] Integrar ambos no ciclo PM → Arquiteto → Documentação / DevOps → Developer → QA → Reviewer → PM

### Fase 9: Continuidade de Contexto (dd-agente-context) 🚧

Objetivo: Implementar handoffs estruturados e máquina de estados governada pelo PM.

Tarefas:

- Infraestrutura criada: diretório `.sde_workspace/system/handoffs/` documentado (README) para centralizar `latest.json` e histórico.

- [x] Definir enum de fases no repositório (INITIALIZING, DESIGN, IMPLEMENTATION, QA_REVIEW, TECH_REVIEW, PM_VALIDATION, ARCHIVED)
- [x] Integrar agentes Documentação e DevOps como papéis de suporte (supporting_roles) no enum de fases
- [x] Expandir `handoff_template.json` com campos meta / delta_summary / quality_signals.knowledge
- [x] Criar `handoff.schema.json` (validação de tipos e obrigatórios)
- [x] Implementar script `scripts/validate_handoff.sh` (schema + hashing)
- [x] Adicionar cálculo e verificação de hash para artifacts_produced
  - Novo utilitário `scripts/compute_artifact_hashes.sh` atualiza os hashes declarados e está integrado ao teste de validação
- [x] Injetar snippet de validação no agente Arquiteto (piloto)
  - Seção "Validação de Handoff" adicionada em `.sde_workspace/system/agents/arquiteto.md`
- [x] Replicar snippet para Developer, QA, Reviewer, Documentação e DevOps
  - Seções de validação adicionadas em `desenvolvedor.md`, `qa.md`, `revisor.md`, `documentacao.md` e `devops.md`
- [x] Atualizar `pm.md` para iniciar fase INITIALIZING e encerrar em ARCHIVED
- [x] Atualizar manifest: adicionar ponteiro para último handoff (handoffs.latest)
- [x] Adicionar contagem de artifacts_new/modificados no handoff delta_summary
- [x] Criar relatório de métricas básicas (clarification_requests, context_completeness_score)
- [x] Checklist de saída por fase documentado em README de agents
- [x] Verificação de pré-condições por agente (artefatos esperados + último handoff válido)
- [x] Geração automática de checklist de saída (artefatos gerados, manifest atualizado, handoff salvo)
- [x] Validação de integridade pós-execução (handoff + manifest) acoplada ao script de validação
- [x] Atualizar instruções dos agentes com seção "Falhas Comuns & Mitigações"

Critérios de Aceitação:

- PM único iniciando/arquivando ciclos
- 100% execuções não-PM com handoff válido
- Zero HASH_MISMATCH em handoffs aprovados
- delta_summary presente em version > 1

### Fase 10: Política de Resolução de Conhecimento (dd-knowledge-resolution) ✅

Objetivo: Forçar prioridade internal → external curado → external raw → internet e registrar gaps.

Tarefas:

- [x] Implementar `scripts/resolve_knowledge.sh` (busca textual básica + ranking + logging)
- [x] Definir `gap_template.json` (estrutura de gaps)
- [x] Criar diretório `knowledge/gaps/` (se não existir)
- [x] Extender `handoff_template.json` com bloco quality_signals.knowledge
- [x] Adicionar códigos de erro: KNOWLEDGE_PRIORITY_VIOLATION, EXTERNAL_JUSTIFICATION_REQUIRED, GAP_NOT_REGISTERED
- [x] Snippet de enforcement (resolver(query) + knowledge_resolution_log) nos agentes
- [x] Registrar eventos (KNOWLEDGE_HIT_INTERNAL, GAP_CREATED) em log de execução
- [x] Atualizar README de agentes com seção "Resolução de Conhecimento"
- [x] Métricas: reuse_ratio, priority_violations, gaps_opened
- [x] Relatório semanal (script) agregando métricas / gaps P1
- [x] Incluir no snippet de resolução a checagem de pré-condições de conhecimento (artefato referenciado já indexado ou gap registrado)
- [x] Adicionar seção "Falhas Comuns & Mitigações" específica de resolução em cada agente
  
Progresso 07/10/2025: script de resolução publicado, templates e diretório de gaps criados, snippets aplicados a todos os agentes com governança de conhecimento, README atualizado, métricas automatizadas e relatório semanal operacional.
Critérios de Aceitação:

- 0 KNOWLEDGE_PRIORITY_VIOLATION após estabilização (≥ 3 ciclos)
- ≥80% reuse_ratio em ciclo 3
- 100% decisões com fonte ou gap_id
- Gaps P1 com owner atribuído ≤ 24h

### Fase 11: Indexação e Manifest de Conhecimento (dd-manifest-indexacao) ✅

Objetivo: Garantir indexação atômica, integridade e rastreabilidade de artefatos de conhecimento.

Tarefas:

- [x] Definir schema JSON estendido para `knowledge/manifest.json`
- [x] Implementar `scripts/scan_knowledge.sh` (scan incremental + hash + atualização)
- [x] Implementar `scripts/validate_manifest.sh` (órfãos, drift, schema)
- [x] Criar header YAML padrão (doc de referência)
- [x] Criar `tags_registry.json` inicial
- [x] Script `promote_artifact.sh` (maturity transitions)
- [x] Enforcement: agente bloqueia uso de artefato não indexado
- [x] Implementar supersede workflow (atualização de antigo para deprecated)
- [x] Arquivamento automático de deprecated > 90 dias
- [x] Métricas: index_latency_avg, orphan_artifacts, drift_incidents
- [x] Relatório de saúde do conhecimento (semanal) consolidado
- [x] Integração handoff: delta de artifacts_new / modified
- [x] Pós-execução: validação automática do manifest e emissão de checklist de saída (integridade + hashes)
- [x] Documentar "Falhas Comuns & Mitigações" para indexação (hash mismatch, órfão, drift)

Progresso 07/10/2025: schema extendido publicado, scripts de scan/validate/promote/supersede/archive/health implementados, enforcement aplicado em todos os agentes, README consolidado com workflow completo, métricas automatizadas operacionais.

Critérios de Aceitação:

- 0 artifacts órfãos após execução do scanner
- 100% novos artifacts indexados ≤ 60s
- Drift < 2% execuções
- ≥70% stable (excluindo notas transitórias) após 5 ciclos
- 0 hash mismatch em execuções aprovadas

## Critérios de Aceitação (Atualizados)

- ✅ Todos os agentes devem redirecionar corretamente para o prompt setup
- ✅ `copilot-instructions.md` deve ser genérico para qualquer tipo de projeto
- ✅ Estrutura organizada com separação clara entre agentes e prompts
- ✅ Instalação deve resultar em `.github` apenas na raiz do projeto (script corrigido)
- ✅ Template de handoff disponível e referenciado
- ✅ Novos agentes de Documentação e DevOps integrados no ciclo
- ✅ Agentes validam pré-condições e publicam checklist de saída
- ✅ Documentação atualizada refletindo as mudanças

## Status Geral

- Concluído: Fases 1–8
- Em Progresso: Fase 9 (Continuidade), Fases 10–11 (planejamento inicial)

**Iniciado em:** 29/09/2025
**Concluído em:**
**Branch:** copilot-ptbr
**Responsável:** Sistema de Correção Automática SDE

## Resumo das Correções Aplicadas

### ✅ Estrutura Reorganizada

- Criado diretório `.sde_workspace/system/prompts/`
- Movidos `setup.md` e `validador_integridade.md` de `agents/` para `prompts/`
- Documentação clara da diferença entre agentes e prompts

### ✅ Gatilhos Corrigidos

- Todos os agentes agora redirecionam automaticamente para `#file:setup.md`
- Removidas referências ao "agente setup" inexistente
- Fluxo de primeira execução automatizado

### ✅ Copilot Instructions Generalizado

- Removidas referências específicas a TypeScript/Backstage
- Criada versão genérica aplicável a qualquer tipo de projeto
- Mantidos guias de commit semântico e estrutura SDE

### ✅ Duplicação .github Documentada / 🚧 Correção Script

- Workaround temporário disponível
- Correção definitiva pendente de aplicação no instalador
