# Prompts do SDE

Este diretório contém **prompts de sistema** que são scripts de execução específicos, não agentes conversacionais.

## Prompts Disponíveis

### setup.md

**Função:** Configuração inicial automática do SDE
**Uso:** Executado automaticamente na primeira execução quando `project-analysis.md` não existe
**Responsabilidade:** Análise do projeto e adaptação da estrutura SDE para o contexto específico

### validador_integridade.md

**Função:** Sistema de validação automática de integridade
**Uso:** Executado automaticamente por todos os agentes ao acessar arquivos críticos
**Responsabilidade:** Garantir consistência da base de conhecimento e especificações

## Diferença entre Prompts e Agentes

### 🤖 Agentes (`/system/agents/`)

- Perfis conversacionais interativos
- Respondem a comandos do usuário
- Mantêm contexto de conversa
- Exemplos: arquiteto, desenvolvedor, pm, qa, revisor

### 📋 Prompts (`/system/prompts/`)

- Scripts de execução automática
- Ativados por gatilhos específicos
- Não mantêm conversa contínua
- Exemplos: setup, validador_integridade

## Integração com Agentes

Todos os agentes podem invocar prompts através de referências diretas:

- `#file:setup.md` - Para configuração inicial
- `#file:validador_integridade.md` - Para validação de integridade
