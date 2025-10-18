# Diretrizes para o GitHub Copilot

Este repositório é um catálogo de **templates Backstage IAAS** multi-stack. O SDE provê governança rígida via agentes especializados; mantenha as etapas da máquina de estados em `.sde_workspace/system/agents/`.

## 🗺️ Visão Geral e Estrutura

- Estrutura principal:
  - `python/` (FastAPI, Agent ADK, MCP client/server) – projetos via Cookiecutterhttps://www.youtube.com/watch?v=JnfyjwChuNU&list=RDJnfyjwChuNU&start_radio=1
  - `java/springboot/` – template Spring Boot 3.5.3 com Maven Wrapperhttps://www.youtube.com/watch?v=JnfyjwChuNU&list=RDJnfyjwChuNU&start_radio=1
  - `k8s/` – manifesto Crossplane + ArgoCD para clusters MKE
  - `misc/`, `api/`, `component/`, `system/` – demais templates Backstage
- Arquivos `template.yaml` seguem o formato `scaffolder.backstage.io/v1beta3` com steps `fetch:template`, `publish:gitlab`, `catalog:register`.
- Consulte `.sde_workspace/knowledge/project-analysis.md` e `technology-stack.md` para panorama completo.

## ⚙️ Workflows Críticos

- **Provisionamento Backstage**: execute templates via Scaffolder; mantenha parâmetros obrigatórios (`component_id`, `owner`, `system`).
- **Publicação GitLab**: steps `publish:gitlab` criam repositórios privados. Ajuste pipelines após o bootstrap garantindo lint/test.
- **TechDocs**: cada template expõe `backstage.io/techdocs-ref`; lembre-se de gerar documentação MkDocs onde aplicável.
- **Governança de Conhecimento**: novos artefatos devem conter frontmatter conforme `.sde_workspace/knowledge/internal/templates/metadata_header.md` e ser indexados no `manifest.json`.

## ✅ Qualidade e Testes

- **Python (Poetry)**:
  - Instalação: `poetry install`
  - Testes: `poetry run pytest` (usar flags `--cov` já configuradas)
- **Agent App (ADK)**: validar secrets e dependências de LiteLLM/Google ADK antes de subir para produção.
- **Java (Maven Wrapper)**:
  - Build/teste: `./mvnw clean verify`
  - Garante compatibilidade Java 17 e Spring Boot 3.5.3.
- **Cookiecutter**: após gerar projeto, remova `cookiecutter.json` (step já automatizado) e execute lint/test localmente para validar os artefatos.

## 📦 Padrões Arquiteturais

- FastAPI segue Clean/Hexagonal Architecture (`core/`, `infrastructure/`, `use_case/`).
- Agent App utiliza `app/root_agent.py` e `agent_factory` para construir agentes moduláveis (Google ADK + LiteLLM).
- Spring Boot template oferece endpoints básicos e Actuator para observabilidade; adicione dependências extras via `pom.xml`.
- Templates K8s combinam Crossplane (provisionamento) e ArgoCD (GitOps); mantenha sincronização entre ambos.

## 📚 Conhecimento e Gaps

- Gap aberto `GAP-2025-10-07T12:15:00Z`: necessário consolidar políticas internas de segurança/compliance para os templates. Priorize a criação de runbook correspondente.
- Registre novos recursos externos em `.sde_workspace/knowledge/external-resources.md` e mantenha tags compatíveis com `tags_registry.json`.

## 🔐 Controle de Versão e Processos

- Commits devem seguir `.sde_workspace/system/guides/guia_commit_semantico.md`.
- Mantenha branch coverage e relatórios Sonar (`sonar-project.properties`) quando integrados.
- Qualquer transição de fase na máquina de estados exige atualização do `handoff.json` correspondente e validação via scripts em `.sde_workspace/system/scripts/`.

## 🤖 Agentes Especializados

- **Arquiteto**: decisões estruturais/ADR.
- **Developer**: implementação e ajustes nos templates.
- **QA**: validação de quality gates (lint, testes, scaffolder run).
- **Reviewer**: revisão técnica antes do MR.
- **PM**: orquestração e governança (estado das tarefas, gaps, manifestos).

> Executar novamente o prompt de setup somente quando `.sde_workspace/knowledge/project-analysis.md` estiver ausente ou desatualizado.
