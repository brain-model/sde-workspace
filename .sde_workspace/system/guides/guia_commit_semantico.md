# Guia de Commit Semântico

## 1. Missão

Este guia estabelece a convenção de commit semântico para o projeto. A prática de categorizar commits de forma estruturada cria um histórico de versionamento explícito que é legível tanto por humanos quanto por máquinas.

A aderência a este padrão é **obrigatória** e nos permite:

* Compreender rapidamente as mudanças em cada commit.
* Automatizar a geração do `CHANGELOG.md`.
* Automatizar o versionamento semântico (MAJOR, MINOR, PATCH).

## 2. Especificação

Cada mensagem de commit consiste em um **cabeçalho**, um **corpo** opcional e um **rodapé** opcional.

```plaintext

<type>[<scope>]: <description>

[optional body]

[optional footer(s)]

```

---

## 3. Estrutura do Commit

### Cabeçalho (Obrigatório)

O cabeçalho é a linha principal do commit e deve seguir estritamente o formato `type(scope): description`.

* **`type`**: Define a categoria da mudança. (Veja a tabela de tipos abaixo).
* **`scope` (opcional)**: Um substantivo entre parênteses que descreve a área de código afetada (ex: `core`, `component`, `api-billing`). Use quando a mudança estiver restrita a um módulo específico.
* **`description`**: Um resumo curto e imperativo da mudança, em minúsculas. Não capitalize a primeira letra e não termine com ponto.

#### Exemplos de Cabeçalho

```sh
# Sem scope
feat: add new swipe breadcrumb

# Com scope
feat(core): add api integration with Crush system
```

### Corpo (Opcional)

O corpo é usado para fornecer contexto adicional sobre a mudança.

* Deve ser separado do cabeçalho por uma linha em branco.
* Use para explicar o "o que" e "por que" da mudança, não o "como".

### Rodapé (Opcional)

O rodapé é usado para dois propósitos principais:

1. **Breaking Changes:** Para indicar uma mudança que quebra a compatibilidade. Inicie o rodapé com `BREAKING CHANGE:`, seguido por uma explicação clara da mudança, justificativa e notas de migração. Um `BREAKING CHANGE` sempre resulta em uma versão `MAJOR`.
2. **Referência de Tarefa:** Para vincular o commit a tarefas ou issues em um sistema de rastreamento.

#### Exemplo com Breaking Change

```plaintext
feat(core): add method X

BREAKING CHANGE: method Y has been discontinued in favor of method X due to performance improvement. To migrate, replace all calls from `Y()` to `X()`.
```

## 4. Tabela de Tipos

Esta tabela é a referência primária para os `types` de commit permitidos, seu impacto no `CHANGELOG` e `Version`.

| Tipo | CHANGELOG | Versão Gerada | Descrição |
| :--- | :--- | :--- | :--- |
| `refactor` | "Code Refactoring" | Patch `x.x.x+1` | Melhoria lógica/semântica em código pré-existente. |
| `feat` | "Features" | Minor `x.x+1.x` | Adição de nova funcionalidade. |
| `fix` | "Bug Fixes" | Patch `x.x.x+1` | Correção de bug. |
| `chore` | "Improvements" | Patch `x.x.x+1` | Uma pequena melhoria que não tem impacto direto no negócio. |
| `test` | "Tests" | Patch `x.x.x+1` | Adição ou modificação de testes de qualquer tipo. |
| `perf` | "Performance Improvements" | Patch `x.x.x+1` | Melhoria de performance. |
| `build` | "Build System" | Patch `x.x.x+1` | Adição ou mudança em scripts de build do projeto. |
| `ci` | "Continuous Integration"| Patch `x.x.x+1` | Mudanças em etapas de CI. |
| `docs` | "Documentation" | Patch `x.x.x+1` | Adição ou mudança na documentação do projeto. |
| `style` | "Styles" | Patch `x.x.x+1` | "Code style": Mudanças no estilo do código sem afetá-lo (espaços, tabs, etc.). |
| `revert` | "Reverts" | Patch `x.x.x+1` | Desfazer algo no projeto via `git revert`. |

## 5. Exemplos Práticos Completos

### Exemplo 1: Nova funcionalidade

```plaintext
feat(api): add endpoint for order status query

Implements the new GET /orders/{id}/status endpoint that returns the current order state.
This endpoint will be consumed by the new customer tracking panel.

Refs: TASK-451
```

### Exemplo 2: Correção de bug com breaking change

```plaintext
fix(auth): fix token renewal flow

The token renewal flow was failing when the access token expired at exactly the same second as verification. The logic was adjusted to include a 5-second safety margin.

BREAKING CHANGE: the `TOKEN_EXPIRATION_MARGIN` environment variable has been removed. The system now uses a fixed value internally. Deployments must remove this variable from their configurations.
```
