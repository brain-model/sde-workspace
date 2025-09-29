---
id: template-project-analysis
title: Template de Análise de Projeto SDE
type: template
status: active
version: 1.0.0
created: 2025-09-28
updated: 2025-09-28
---

# Análise de Projeto - [NOME_DO_PROJETO]

## 📊 Resumo Executivo

**Data da Análise:** [DATA]
**Tipo de Projeto:** [WEB_APP|MOBILE_APP|CLI_TOOL|LIBRARY|MICROSERVICE|DATA_PIPELINE|ML_PROJECT]
**Complexidade:** [SIMPLES|MODERADA|ALTA]
**Arquitetura Principal:** [MONOLITICO|MICROSERVICOS|SERVERLESS|EVENT_DRIVEN]

## 🔍 Tecnologias Detectadas

### Linguagens de Programação
- **Principal:** [LINGUAGEM] (Confiança: [ALTA|MEDIA|BAIXA])
- **Secundárias:** [LISTA_DE_LINGUAGENS]

### Frameworks e Bibliotecas

#### Frontend
- [FRAMEWORK]: versão [X.X.X]
- [BIBLIOTECAS_RELEVANTES]

#### Backend
- [FRAMEWORK]: versão [X.X.X]
- [BIBLIOTECAS_RELEVANTES]

#### Banco de Dados
- [TIPO_BD]: [NOME_BD]
- ORMs/Drivers: [LISTA]

### Ferramentas de Build/Deploy
- Build: [FERRAMENTA] ([ARQUIVO_CONFIG])
- Containerização: [SIM|NAO] ([DOCKERFILE|DOCKER_COMPOSE])
- CI/CD: [GITHUB_ACTIONS|GITLAB_CI|JENKINS|OUTROS]
- Infraestrutura: [KUBERNETES|TERRAFORM|ANSIBLE|OUTROS]

### Ferramentas de Teste
- Framework de Teste: [JEST|PYTEST|JUNIT|OUTROS]
- Coverage: [FERRAMENTA]
- E2E Testing: [CYPRESS|SELENIUM|PLAYWRIGHT|OUTROS]

## 📁 Estrutura do Projeto

### Organização de Diretórios
```
[ESTRUTURA_PRINCIPAL_DETECTADA]
```

### Padrões Arquiteturais Identificados
- [ ] Clean Architecture
- [ ] MVC/MVP/MVVM
- [ ] Hexagonal Architecture
- [ ] Domain Driven Design
- [ ] CQRS
- [ ] Event Sourcing
- [ ] Repository Pattern
- [ ] Factory Pattern
- [ ] Observer Pattern

## 🎯 Recomendações de Configuração SDE

### Instruções para AI Coding Agents

#### Copilot Instructions Detectadas
- **Existente:** [SIM|NAO] - `.github/copilot-instructions.md`
- **Outras Convenções AI:** [LISTA_ARQUIVOS_DETECTADOS]
- **Conteúdo Valioso a Preservar:** [DESCRICAO]

#### Instruções Geradas/Atualizadas
- **Big Picture Arquitetural:** [COMPONENTES_PRINCIPAIS]
- **Workflows Críticos:** [COMANDOS_ESPECIFICOS]
- **Convenções Específicas:** [PADROES_UNICOS_PROJETO]
- **Pontos de Integração:** [APIS_SERVICOS_EXTERNOS]

### Templates Especializados Sugeridos

#### ADRs (Architecture Decision Records)
- `adr-[TECNOLOGIA_PRINCIPAL].md`
- `adr-database-choice.md`
- `adr-framework-selection.md`

#### Specs de Desenvolvimento
- `spec-api-design.md`
- `spec-data-model.md`
- `spec-integration-patterns.md`

### Base de Conhecimento Recomendada

#### Documentação Oficial (Para Download)
- [ ] [LINGUAGEM_PRINCIPAL] Official Documentation
- [ ] [FRAMEWORK_PRINCIPAL] Documentation
- [ ] [DATABASE] Documentation
- [ ] [BUILD_TOOL] Documentation

#### Standards e Best Practices
- [ ] [LINGUAGEM] Style Guide
- [ ] [FRAMEWORK] Best Practices
- [ ] API Design Guidelines
- [ ] Testing Strategies
- [ ] Security Guidelines

### Recursos Educacionais Gratuitos

#### Documentação e Guias
1. **[TECNOLOGIA]**: [URL_OFICIAL]
   - Tipo: Documentação Oficial
   - Relevância: Alta
   - Atualização: Contínua

2. **[FRAMEWORK]**: [URL_OFICIAL]
   - Tipo: Documentação + Tutoriais
   - Relevância: Alta
   - Atualização: Contínua

#### Repositórios de Referência
1. **[NOME_REPO]**: [URL_GITHUB]
   - Tipo: Exemplo de Implementação
   - Tecnologias: [LISTA]
   - Stars: [NUMERO]

#### Comunidades e Fóruns
1. **[NOME_COMUNIDADE]**: [URL]
   - Tipo: [FORUM|DISCORD|SLACK]
   - Membros: [NUMERO]
   - Atividade: [ALTA|MEDIA|BAIXA]

## ⚙️ Configurações Propostas

### Estrutura de Knowledge Personalizada

```bash
knowledge/
├── external/
│   ├── standards/
│   │   ├── [LINGUAGEM]-style-guide.md
│   │   ├── [FRAMEWORK]-best-practices.md
│   │   └── api-design-guidelines.md
│   ├── vendor-docs/
│   │   ├── [TECNOLOGIA1]/
│   │   ├── [TECNOLOGIA2]/
│   │   └── [TECNOLOGIA3]/
│   └── research/
│       ├── [AREA1]-patterns.md
│       └── [AREA2]-architecture.md
└── internal/
    ├── concepts/
    │   ├── [DOMINIO]-glossary.md
    │   └── architecture-decisions.md
    └── runbooks/
        ├── development-workflow.md
        ├── deployment-process.md
        └── troubleshooting-guide.md
```

### Templates Customizados
- [ ] Spec template adaptado para [CONTEXTO]
- [ ] ADR template com seções específicas
- [ ] QA report template com testes [TIPO]
- [ ] Review template focado em [LINGUAGEM]

## 📋 Checklist de Aplicação

### Fase 1: Preparação
- [ ] Backup da configuração atual
- [ ] Análise do `.github/copilot-instructions.md` existente (se houver)
- [ ] Criação da estrutura de knowledge proposta
- [ ] Download da documentação oficial prioritária

### Fase 2: Customização
- [ ] Geração/atualização do `.github/copilot-instructions.md`
- [ ] Criação de templates especializados
- [ ] Configuração de guias personalizados
- [ ] Atualização dos manifestos

### Fase 3: Validação
- [ ] Teste dos templates criados
- [ ] Verificação da estrutura de knowledge
- [ ] Validação dos links e recursos

## 🚀 Próximos Passos

1. **Revisar e aprovar** as recomendações acima
2. **Customizar** sugestões conforme necessário
3. **Aplicar** configurações aprovadas
4. **Validar** o funcionamento do SDE customizado

## 📝 Observações Adicionais

[NOTAS_ESPECIFICAS_DO_PROJETO]
[CONSIDERACOES_ESPECIAIS]
[LIMITACOES_IDENTIFICADAS]

---

**Análise realizada por:** Agente Setup SDE v1.0
**Confiança da análise:** [ALTA|MEDIA|BAIXA]
**Requer validação humana:** [SIM|NAO]