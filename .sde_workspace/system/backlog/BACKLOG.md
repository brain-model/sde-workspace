# Backlog

## TST-9D1F: [AUTH] Integrar ao plugin RBAC

- Status: Proposed
- Prioridade: Alta
- Tipo: Feature
- Área: Autenticação/Autorização (Backstage)
- Origem: Conversas de time e specs no `./.sde_workspace/specs/`

### Contexto (DB)

Conectar o plugin de frontend `plugins/rbac-front` ao backend (`rbac-backend`) para consultar e exibir Sistemas e Grupos provenientes do `CAD user` (via token fixo em variável de ambiente) e exibir Policies internas mantidas no Backstage. Claims/identidade do usuário estão fora do escopo neste momento. Apenas recursos com prefixo `magma_` devem ser considerados.

### Objetivo (DB)

Exibir no frontend a lista de Sistemas e respectivos Grupos (filtrados por prefixo `magma_`) e as Policies internas associadas aos grupos, com contratos claros, paginação e filtros essenciais, preservando segurança e observabilidade.

### Escopo (Inclui) (DB)

- Implementar `rbac-backend` no Backstage com endpoints esperados pelo frontend:
  - `GET /api/rbac/roles?query=&page=&pageSize=&system?`
  - `GET /api/rbac/policies?query=&page=&pageSize=&groupPath?`
- Integração com `CAD user` usando token fixo (`CADUSER_TOKEN`) para listar Grupos com prefixo `magma_` (timeouts, retries e mapeamento para o modelo `Role`).
- Persistência SEMPRE em banco: Policies e associações armazenadas no DB do Backstage (sem fallback in-memory).
- Seed inicial obrigatório: criar roles básicas no namespace `magma` com policies/permissions incluídas, cobrindo ao menos `['dev','tl','admin']`.
- Manter Policies internamente no Backstage (fonte interna), leitura via API (sem CRUD público por ora).
- Atualização do `rbac-front` para consumir os endpoints e renderizar Roles → Policies.
- Paginação e filtros básicos (por nome/identificador; opcional filtro por sistema) no backend e frontend.
- Observabilidade (logs estruturados, métricas de latência/erros), e propagação de correlação (trace-id) quando disponível.

### Fora de Escopo (DB)

- Claims e enriquecimento de token do usuário (qualquer dinâmica baseada em identidade/claims).
- CRUD completo (criar/editar/excluir) de policies e/ou grupos.
- Gestão de atribuição de policies a usuários (foco é associação grupo↔policy consultiva).

### Requisitos Funcionais (DB)

- Backend expõe:
  - `GET /api/rbac/roles?query=&page=&pageSize=&system?` (Roles mapeando grupos do CAD user, filtrados por `magma_`)
  - `GET /api/rbac/policies?query=&page=&pageSize=&groupPath?` (Policies internas associadas a grupos)
- Frontend consome os endpoints acima e exibe listas, estados de loading/erro e paginação.

### Requisitos Não-Funcionais (DB)

- Segurança: autenticar chamadas ao `CAD user` via `CADUSER_TOKEN`; sanitização/validação de parâmetros; não logar segredos.
- Performance: p95 < 300ms para listagens com paginação típica (pageSize<=50) sob condições normais.
- Observabilidade: métricas (requisições, latência, erros) e logs estruturados. Tratamento de falhas do `CAD user` (retries com backoff; opcional circuit breaker).
- Operação: migrations aplicadas automaticamente no boot do plugin; seed inicial garantido idempotente (só insere se ausente).

### Integrações (DB)

- `CAD user`: endpoint(s) de consulta de Sistemas/Grupos. Mapear URLs, headers e autenticação via `CADUSER_TOKEN` (variável de ambiente). Tratar limites de rate e códigos 4xx/5xx; aplicar filtro de prefixo `magma_`. No backend, mapear Grupos → `Role`.
- Backstage: usar serviços core (`DatabaseService`) e padrões do ecossistema para o repositório de Policies (leitura) e execução de migrations/seed.

### Dados/Modelos (Domínio RBAC)

- Role: `{ id, name, description? }` (representa um Grupo do CAD user com prefixo `magma_`; `description` pode incluir o sistema/origem)
- Policy: `{ id, name, effect, resources[], actions[], groups[] }`
- Paginação: `{ items[], page, pageSize, total }`

### Critérios de Aceitação

- Dado que o `CAD user` está acessível e `CADUSER_TOKEN` válido, quando acessar o frontend RBAC, então devo ver a lista de Roles (mapeando Grupos `magma_`) e, ao selecionar/filtar, devo ver as Policies internas associadas, com paginação, filtros e estados de carregamento/erro.
- Logs e métricas disponíveis para as rotas RBAC no backend.
- Erros do `CAD user` são exibidos como mensagens amigáveis no frontend e registrados no backend.
- Spec Document atualizado pelo Arquiteto e referenciado no `manifest.json` (convertedMarkdown quando for PDF).

### Referências

- Specs: ver `./.sde_workspace/specs/manifest.json` (tópicos `auth`, `rbac`, `caduser`).
- Código: `plugins/rbac-front` e `packages/backend`.
- Padrões: `~/develop/brain/knowledge_base/backstage`.

### Próximos Passos

1. Arquiteto: produzir Spec Document a partir deste item de backlog usando o template em `system/templates/spec_template.md`.
2. Orquestrador: criar workspace `.sde_workspace/workspaces/TST-9D1F_integracao-rbac/` com `handoff.json` em `AWAITING_DEVELOPMENT`.
3. Developer: implementar backend e integração com frontend conforme Spec.
4. QA → Reviewer: validar e revisar conforme fluxo.

## TST-9D1F-DB: [AUTH] Persistência do RBAC no Database

- Status: Proposed
- Prioridade: Média-Alta
- Tipo: Feature
- Área: Autorização (Backstage)
- Origem: Evolução de TST-9D1F; necessidade de durabilidade e governança

### Contexto

O `PolicyStore` atual é in-memory (volátil). Precisamos armazenar de forma persistente as Policies internas e seus vínculos com grupos (paths) no banco do Backstage, usando `DatabaseService`. O objetivo é garantir durabilidade entre deploys, permitir auditoria básica e futura evolução para CRUD controlado, sem alterar os contratos públicos do backend no curto prazo.

### Objetivo

Persistir Policies internas do plugin RBAC e suas associações com grupos no banco de dados do Backstage, mantendo os mesmos contratos de leitura:

- `GET /api/rbac/policies?query=&page=&pageSize=&groupPath?`

E pavimentar o caminho para auditoria e gestão futura.

### Escopo (Inclui)

- Modelagem e criação de tabelas via migrations gerenciadas pelo `DatabaseService`:
  - `rbac_policies(id, name, effect, resources(json), actions(json), created_at, updated_at)`
  - `rbac_policy_groups(policy_id, group_path)` (N:1 com `rbac_policies`)
- Implementar um `PolicyRepository` usando `DatabaseService`/Knex para leitura paginada/filtrada (query, groupPath).
- Substituir `PolicyStore` in-memory por implementação backed-by-DB mantendo a mesma interface de leitura (feature-flag para fallback in-memory em dev).
- Migrations idempotentes e versionadas dentro do plugin.
- Seed de desenvolvimento opcional (dados mínimos) controlado por flag/env.

### Fora de Escopo

- CRUD completo (criar/editar/excluir) via API pública no momento.
- Sincronização automática bidirecional com fontes externas (CAD user) — continua apenas leitura e mapeamento.
- Auditoria avançada e RBAC administrativo (somente fundação técnica neste item).

### Requisitos Funcionais

- Responder `GET /api/rbac/policies` a partir do DB com os mesmos filtros/paginação do in-memory atual.
- Suportar filtro `groupPath` por substring do caminho completo do grupo.
- Manter compatibilidade de resposta com o frontend existente.

### Requisitos Não-Funcionais

- Usar `DatabaseService` do Backstage e padrões do ecossistema.
- Migrations seguras, idempotentes e com rollback possível.
- Índices nos campos de busca (`name`, `id`) e `group_path` para p95 < 300ms (pageSize<=50).
- Logs estruturados, sem vazamento de segredos.

### Integrações

- Backstage: `DatabaseService` (Knex) e configuração `backend.database` existente.
- Scheduler (opcional futuro): preparar extensão para seed/sync periódico se necessário.

### Dados/Modelos (DB)

- Policy: `{ id, name, effect, resources[], actions[], groups[] }` (persistido)
- PageResponse: `{ items[], page, pageSize, total }`

### Critérios de Aceitação (DB)

- Dados persistem entre reinícios do backend (sem perda de `policies` e seus `groups`).
- `GET /api/rbac/policies` retorna dados do banco com paginação e filtros equivalentes; não há fallback in-memory.
- Após primeiro boot em um banco vazio, existem roles básicas com namespace `magma` e policies/permissions pré-carregadas para `dev`, `tl`, `admin`.
- Migrations aplicam/criam as tabelas esperadas e são auditáveis em ambientes.
- Observabilidade básica presente (logs das operações e falhas de DB).

### Referências (DB)

- Tarefa base: `TST-9D1F`.
- Specs/Manifest: `./.sde_workspace/specs/manifest.json` (tópicos `auth`, `rbac`, `backstage`).
- Padrões: `~/develop/brain/knowledge_base/backstage` (DatabaseService, Knex, migrations em plugins).

### Próximos Passos (DB)

1. Arquiteto: detalhar Spec de dados e migrações (DDL, índices, relacionamentos, flags de seed).
2. Developer: implementar/ajustar migrations + `PolicyRepository`, remover fallback in-memory e garantir seed inicial default `magma:{dev,tl,admin}` com suas policies/permissions.
3. QA: validar respostas equivalentes (in-memory vs DB), performance e integridade dos filtros.
4. Reviewer: revisar segurança (injeções, transações) e padrões Backstage.
