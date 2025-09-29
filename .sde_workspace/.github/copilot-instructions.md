# Diretrizes para o GitHub Copilot

Este projeto utiliza um **Software Development Environment (SDE)** com workflow de agentes de IA especializados para desenvolvimento de software.

## Regras Gerais

**Estrutura do Projeto:**
- O SDE está configurado em `.sde_workspace/` com agentes, prompts, conhecimento e especificações
- Consulte a base de conhecimento em `.sde_workspace/knowledge/` para contexto do projeto
- Siga as especificações em `.sde_workspace/system/specs/` para decisões arquiteturais

**Qualidade de Código:**
- Siga as melhores práticas de Clean Code para a linguagem principal do projeto
- Mantenha consistência com padrões arquiteturais já estabelecidos no projeto
- Aplique princípios SOLID e padrões de design apropriados

**Controle de Versão:**
- As mensagens de commit devem seguir estritamente as regras definidas em `.sde_workspace/system/guides/guia_commit_semantico.md`
- Commits devem ser atômicos e bem documentados

**Agentes Disponíveis:**
- **Arquiteto**: Decisões de arquitetura e design de sistema
- **Desenvolvedor**: Implementação de código e funcionalidades  
- **QA**: Testes, qualidade e validações
- **Revisor**: Análise de código e conformidade
- **PM**: Gestão de tarefas e planejamento

Para configuração inicial ou adaptação do SDE ao projeto, o sistema executará automaticamente o prompt de setup quando necessário.
