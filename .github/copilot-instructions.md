# Diretrizes para o GitHub Copilot

Este projeto é uma instância customizada do Backstage para a Plataforma Magalu (Magma), com plugins customizados e arquitetura de monorepo com Yarn Workspaces.

## Arquitetura e Estrutura

**Monorepo Backstage:**
- `packages/app/`: Frontend React com Backstage UI
- `packages/backend/`: Backend Node.js com plugins Backstage
- `plugins/`: Plugins customizados da Magalu (magma-backend, magma-core-common, auth-backend-module-oidc, etc.)
- Versão Backstage: 1.40.2 (veja `backstage.json`)

**Padrões de Plugin:**
- Plugins customizados seguem estrutura padrão Backstage com `src/service/router.ts`
- Use `magma-core-common` para middlewares compartilhados (auth, security, rate limiting)
- Integre com serviços Backstage via `@backstage/backend-plugin-api` (LoggerService, Config, PermissionsService)

## Desenvolvimento e Build

**Scripts Principais:**
- `yarn start`: Inicia frontend e backend em modo dev
- `yarn build:all`: Build completo do monorepo
- `yarn test:all`: Testes com cobertura
- `yarn lint:all`: Lint de todos os pacotes
- `make install-plugin PLUGIN=nome`: Instala novo plugin

**Ambiente de Desenvolvimento:**
- Node 20 ou 22 (definido em `package.json`)
- Yarn 4.4.1 como package manager
- GitLab Labs como fonte principal de código
- Kind para testes K8s locais (`dev/scripts/setup_kind_environment.py`)

## Conhecimento e Documentação (CRÍTICO)

**Manifest de Indexação:**
- **SEMPRE** consulte `.sde_workspace/specs/manifest.json` como fonte única de verdade para requisitos e especificações
- Para PDFs, use o Markdown normalizado em `details.convertedMarkdown`
- Campos essenciais: `details.title`, `details.topics`, `details.date/time/timezone`

**Base de Conhecimento:**
- Consulte `~/develop/brain/knowledge_base/backstage` para padrões e decisões arquiteturais
- Especificações técnicas em `.sde_workspace/specs/`

## Commits e Qualidade

**Conventional Commits (OBRIGATÓRIO):**
- Siga rigorosamente `.sde_workspace/system/guides/semantic_commit_guide.md`
- Formato: `<type>[<scope>]: <description>`
- Tipos: feat, fix, docs, style, refactor, test, chore, ci
- Exemplo: `feat(auth): add OIDC custom provider integration`

**TypeScript e Qualidade:**
- Todo código em TypeScript
- Use serviços Backstage (`DatabaseService`, `SchedulerService`) quando disponíveis  
- Siga padrões de Clean Code
- Validação com Zod para APIs (`import { z } from 'zod'`)

## Integrações Específicas

**Magalu Stack:**
- CADUser para autenticação (`caduser` config em app-config.yaml)
- GitLab Labs para versionamento e CI/CD
- ArgoCD para deploy em staging/produção
- Templates customizados em `dev/backstage/templates/`

**Configuração por Ambiente:**
- `app-config.yaml`: Base
- `app-config.local.yaml`: Local development  
- `app-config.staging.yaml`: Staging
- `app-config.production.yaml`: Production
