# Guia de Commit Semantico

## 1. Missao

Este guia estabelece a convencao de commit semantico para o projeto. A pratica de categorizar commits de forma estruturada cria um historico de versionamento explicito que e legivel tanto por humanos quanto por maquinas.

A aderencia a este padrao e **obrigatoria** e nos permite:

* Entender rapidamente mudancas em cada commit.
* Automatizar geracao de `CHANGELOG.md`.
* Automatizar versionamento semantico (MAJOR, MINOR, PATCH).

## 2. Especificacao

Cada mensagem de commit consiste em um **cabecalho**, um **corpo** opcional e um **rodape** opcional.

```plaintext

<tipo>[<escopo>]: <descricao>

[corpo opcional]

[rodape(s) opcional(is)]

```

---

## 3. Estrutura do Commit

### Cabecalho (Obrigatorio)

O cabecalho e a linha principal do commit e deve seguir rigorosamente o formato `tipo(escopo): descricao`.

* **`tipo`**: Define a categoria da mudanca. (Veja a tabela de tipos abaixo).
* **`escopo` (opcional)**: Um substantivo entre parenteses que descreve a area do codigo afetada (ex.: `core`, `component`, `api-billing`). Use quando a mudanca e restrita a um modulo especifico.
* **`descricao`**: Um resumo curto e imperativo da mudanca, em minusculo. Nao capitalize a primeira letra e nao termine com ponto.

#### Exemplos de Cabecalho

```sh
# Sem escopo
feat: adiciona novo breadcrumb deslizante

# Com escopo
feat(core): adiciona integracao da api com sistema Crush
```

### Corpo (Opcional)

O corpo e usado para fornecer contexto adicional sobre a mudanca.

* Deve ser separado do cabecalho por uma linha em branco.
* Use para explicar o "o que" e "por que" da mudanca, nao o "como".

### Rodape (Opcional)

O rodape e usado para dois propositos principais:

1. **Breaking Changes:** Para indicar uma mudanca que quebra compatibilidade. Inicie o rodape com `BREAKING CHANGE:`, seguido de uma explicacao clara da mudanca, justificativa e notas de migracao. Um `BREAKING CHANGE` sempre resulta em uma versao `MAJOR`.
2. **Referencia de Tarefa:** Para linkar o commit a tarefas ou issues em um sistema de rastreamento.

#### Exemplo com Breaking Change

```plaintext
feat(core): adiciona metodo X

BREAKING CHANGE: metodo Y foi descontinuado em favor do metodo X devido a melhoria de performance. Para migrar, substitua todas as chamadas de `Y()` para `X()`.
```

## 4. Tabela de Tipos

Esta tabela e a referencia primaria para `tipos` de commit permitidos, seu impacto no `CHANGELOG` e `Versao`.

| Tipo | CHANGELOG | Versao Gerada | Descricao |
| :--- | :--- | :--- | :--- |
| `refactor` | "Refatoracao de Codigo" | Patch `x.x.x+1` | Melhoria logica/semantica em codigo pre-existente. |
| `feat` | "Features" | Minor `x.x+1.x` | Adicao de nova funcionalidade. |
| `fix` | "Correcao de Bugs" | Patch `x.x.x+1` | Correcao de bug. |
| `chore` | "Melhorias" | Patch `x.x.x+1` | Uma pequena melhoria que nao tem impacto direto no negocio. |
| `test` | "Testes" | Patch `x.x.x+1` | Adicao ou modificacao de testes de qualquer tipo. |
| `perf` | "Melhorias de Performance" | Patch `x.x.x+1` | Melhoria de performance. |
| `build` | "Sistema de Build" | Patch `x.x.x+1` | Adicao ou mudanca em scripts de build do projeto. |
| `ci` | "Integracao Continua"| Patch `x.x.x+1` | Mudancas em etapas de CI. |
| `docs` | "Documentacao" | Patch `x.x.x+1` | Adicao ou mudanca em documentacao do projeto. |
| `style` | "Estilos" | Patch `x.x.x+1` | "Estilo de codigo": Mudancas no estilo do codigo sem afeta-lo (espacos, tabs, etc.). |
| `revert` | "Reverts" | Patch `x.x.x+1` | Desfazer algo no projeto via `git revert`. |

## 5. Exemplos Praticos Completos

### Exemplo 1: Nova feature

```plaintext
feat(api): adiciona endpoint para consulta de status de pedido

Implementa o novo endpoint GET /orders/{id}/status que retorna o estado atual do pedido.
Este endpoint sera consumido pelo novo painel de acompanhamento do cliente.

Refs: TASK-451
```

### Exemplo 2: Correcao de bug com breaking change

```plaintext
fix(auth): corrige fluxo de renovacao de token

O fluxo de renovacao de token estava falhando quando o access token expirava exatamente no mesmo segundo da verificacao. A logica foi ajustada para incluir uma margem de seguranca de 5 segundos.

BREAKING CHANGE: a variavel de ambiente `TOKEN_EXPIRATION_MARGIN` foi removida. O sistema agora usa um valor fixo internamente. Deployments devem remover esta variavel de suas configuracoes.
```
