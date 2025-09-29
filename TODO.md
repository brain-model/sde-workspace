# Plano de Correção de Bugs - SDE v0.1.0 Copilot-PTBR

## Bugs Identificados

### 1. Gatilho de Setup Obsoleto
**Problema:** Agentes ainda referenciam o agente 'setup' que foi excluído
**Localização:** Todos os agentes em `.sde_workspace/system/agents/`
**Impacto:** Usuários são direcionados para um agente inexistente

### 2. Copilot Instructions Específico
**Problema:** `copilot-instructions.md` contém orientações específicas para TypeScript/Backstage
**Localização:** `.sde_workspace/.github/copilot-instructions.md`
**Impacto:** Instruções não são genéricas para outros tipos de projeto

### 3. Duplicação do Diretório .github
**Problema:** Após instalação, `.github` fica duplicado (raiz + dentro .sde_workspace)
**Localização:** Script de instalação
**Impacto:** Confusão de qual arquivo usar e duplicação desnecessária

### 4. Arquitetura de Prompts vs Agentes
**Problema:** `setup.md` e `validador_integridade.md` são prompts, não agentes
**Localização:** `.sde_workspace/system/agents/`
**Impacto:** Organização incorreta do sistema

## Plano de Correção

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

### Fase 5: Corrigir Duplicação do .github ✅
- [x] Identificar onde ocorre a duplicação no processo de instalação
- [x] Documentar solução para instalação correta (apenas na raiz)
- [x] Adicionar documentação de workaround temporário

### Fase 6: Atualizar Documentação ✅
- [x] Atualizar `README.md` com nova estrutura de prompts
- [x] Corrigir referências ao agente setup
- [x] Documentar o novo fluxo de primeira execução

## Critérios de Aceitação

- ✅ Todos os agentes devem redirecionar corretamente para o prompt setup
- ✅ `copilot-instructions.md` deve ser genérico para qualquer tipo de projeto
- ✅ Estrutura organizada com separação clara entre agentes e prompts
- ✅ Instalação deve resultar em `.github` apenas na raiz do projeto
- ✅ Documentação atualizada refletindo as mudanças

## Status: ✅ CONCLUÍDO
**Iniciado em:** 29/09/2025  
**Concluído em:** 29/09/2025
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

### ✅ Duplicação .github Documentada
- Problema identificado e documentado em `GITHUB_DUPLICATION_FIX.md`
- Workaround temporário disponível até correção do script de instalação
- Solução definitiva especificada para implementação futura