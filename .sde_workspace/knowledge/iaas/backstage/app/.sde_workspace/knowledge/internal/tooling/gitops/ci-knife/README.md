# ci-knife

![ci-knife](docs/swiss_knife.jpg)

**CI Knife** é uma ferramenta de `CI/CD` que provê um conjunto de comandos para `facilitar/padronizar` os deploys de aplicações no _**Labs**_.

- Para utilizar basta configurar um `job` que utiliza a `imagem docker` com o comando necessário.
- imagem docker: [ci-knife](gcr.io/magalu-cicd/ci-knife)
- Caso use o _**ci-knife**_ no gitlab, recomenda-se não usar com a imagem apontado para o `latest`, pois o cache do gitlab vai sempre pegar a versão usada na última build.

#### exemplo de uso no `.gitlab-ci.yml`

- no exemplo abaixo um _**job**_ foi configurado no _**stage**_ de teste para validar se as mensagens de `commit` estão no padrão esperado usando o `commitlint`

```yml
commitlint:
  image: gcr.io/magalu-cicd/ci-knife:v1.10.2
  stage: test
  script: ci-knife commitlint
```

- você também pode utilizar a variável global do gitlab `CIKNIFE_IMAGE`, exemplo:

```yml
commitlint:
  image: $CIKNIFE_IMAGE
  stage: test
  script: ci-knife commitlint
```

- você também pode passar uma branch de origem de analize, exemplo:

```yml
commitlint:
  image: $CIKNIFE_IMAGE
  stage: test
  script: ci-knife commitlint --source main
```

[veja mais exemplos aqui](https://gitlab.luizalabs.com/luizalabs/ci-knife/blob/master/example/)

# Sumário

- [ci-knife](#ci-knife)
      - [exemplo de uso no `.gitlab-ci.yml`](#exemplo-de-uso-no-gitlab-ciyml)
- [Sumário](#sumário)
- [Comandos disponíveis](#comandos-disponíveis)
  - [**commitlint**](#commitlint)
    - [exemplo](#exemplo)
    - [opções](#opções)
  - [**mr-review**](#mr-review)
    - [exemplo (.gitlab-ci.yml)](#exemplo-gitlab-ciyml)
    - [variáveis de ambiente](#variáveis-de-ambiente)
  - [**mr-code-review**](#mr-code-review)
    - [variáveis de ambiente](#variaveis-mr-code-review)
  - [**mr-sla**](#mr-sla)
    - [parâmetros mr-sla](#parâmetros-mr-sla)
    - [exemplos de uso](#exemplos-de-uso)
  - [**check-mr-approved**](#check-mr-approved)
    - [exemplo check mr approved](#exemplo-check-mr-approved)
    - [variáveis de ambiente](#variáveis-de-ambiente-1)
  - [**create-release**](#create-release)
    - [exemplo](#exemplo-1)
    - [opções](#opções-1)
    - [variáveis de ambiente](#variáveis-de-ambiente-2)
    - [Atualizando versão em arquivos](#atualizando-versão-em-arquivos)
  - [**create-gmud**](#create-gmud)
    - [exemplo](#exemplo-2)
    - [opções](#opções-2)
    - [variáveis de ambiente](#variáveis-de-ambiente-3)
  - [**argocd-deploy / argocd-rollback**](#argocd-deploy--argocd-rollback)
    - [Comando](#comando)
      - [Opções](#opções-3)
    - [variáveis de ambiente](#variáveis-de-ambiente-4)
  - [**argocd-sync**](#argocd-sync)
    - [Comando](#comando-1)
      - [opções](#opções-4)
    - [variáveis de ambiente](#variáveis-de-ambiente-5)
  - [**sonar-scanner**](#sonar-scanner)
    - [exemplo](#exemplo-3)
    - [opções](#opções-5)
    - [variáveis de ambiente](#variáveis-de-ambiente-6)
  - [**security-scanner**](#security-scanner)
  - [**security-result**](#security-result)
  - [**create-docker-image** / **publish-docker-tag**](#create-docker-image--publish-docker-tag)
    - [**create-docker-image**](#create-docker-image)
      - [exemplo no gitlab](#exemplo-no-gitlab)
      - [opções](#opções-6)
      - [variáveis de ambiente](#variáveis-de-ambiente-7)
    - [**publish-docker-tag**](#publish-docker-tag)
      - [exemplo no gitlab](#exemplo-no-gitlab-1)
      - [opções](#opções-7)
      - [variáveis de ambiente](#variáveis-de-ambiente-8)
  - [**api-contract-test**](#api-contract-test)
    - [exemplo](#exemplo-4)
    - [Opções](#opções-8)
  - [**magalint**](#magalint)
    - [Exemplo](#exemplo-5)
    - [Opções](#opções-9)
  - [**gcs-deploy / gcs-rollback**](#gcs-deploy--gcs-rollback)
    - [exemplo](#exemplo-6)
    - [Staging](#staging)
    - [opções](#opções-10)
    - [variáveis de ambiente](#variáveis-de-ambiente-9)
    - [Configurando o acesso ao bucket](#configurando-o-acesso-ao-bucket)
    - [Configuração adicional para projetos já existentes](#configuração-adicional-para-projetos-já-existentes)
      - [Informações do arquivo](#informações-do-arquivo)
  - [**script-deploy / script-rollback**](#script-deploy--script-rollback)
    - [exemplo comando](#exemplo-comando)
    - [opções comando](#opções-comando)
    - [variáveis de ambiente configuraveis](#variáveis-de-ambiente-configuraveis)
  - [**api-contract-verify**](#api-contract-verify)
    - [exemplo](#exemplo-7)
    - [Opções](#opções-11)
  - [**api-catalog**](#api-catalog)
    - [exemplo](#exemplo-8)
    - [opções](#opções-12)
  - [**azion-purge**](#azion-purge)
    - [exemplo](#exemplo-9)
    - [exemplo type urls](#exemplo-type-urls)
    - [opções](#opções-13)
  - [**renovate**](#renovate)
    - [Exemplo](#exemplo-5)
    - [Opções](#opções-9)
- [Commit semântico](#commit-semântico)
  - [Forma simples:](#forma-simples)
    - [Exemplos:](#exemplos)
  - [Forma com escopo:](#forma-com-escopo)
    - [Exemplos:](#exemplos-1)
  - [Breaking change](#breaking-change)
    - [Exemplos:](#exemplos-2)
  - [Tipos possíveis](#tipos-possíveis)
- [Freezing](#freezing)
  - [Como preencher a variável de freezing?](#como-preencher-a-variável-de-freezing-)
  - [Como fazer deploy mesmo estando em freezing?](#como-fazer-deploy-mesmo-estando-em-freezing-)
- [Deploy fora do horário permitido](#deploy-fora-do-horário-permitido)
  - [Como fazer deploy fora do horário permitido?](#como-fazer-deploy-fora-do-horário-permitido)
- [Templates](#templates)
  - [Reports (Sonar e Fortify) # Depreciado](#reports-sonar-e-fortify--depreciado)
    - [Fortify](#fortify)
  - [Reports Security](#reports-security)
  - [Deploy ArgoCD](#deploy-argocd)
    - [Ambiente de Integração](#ambiente-de-integração)
  - [API Catalog](#api-catalog-1)
  - [Deploy Kong](#deploy-kong)
  - [Validação Segurança em MRs](#validação-segurança-em-mrs--)
  - [Validação projetos CICD](#validação-projetos-cicd--)
- [Dicas para implantação em projetos](#dicas-para-implantação-em-projetos)
  - [Git](#git)
  - [Projetos com package.json](#projetos-com-packagejson)
  - [CHANGELOG](#changelog)
  - [Usando variáveis de ambiente](#usando-variáveis-de-ambiente)
    - [GCHAT](#gchat)
    - [SLACK](#slack)
- [Colaborando com o projeto](#colaborando-com-o-projeto)
  - [Dúvidas, problemas, sugestões...](#dúvidas-problemas-sugestões)
  - [Merge Request](#merge-request)
    - [Gerando imagem de teste](#gerando-imagem-de-teste)
  - [Gerando uma nova versão do ci-knife (deploy)](#gerando-uma-nova-versão-do-ci-knife-deploy)
    - [Gerando uma versão](#gerando-uma-versão)
    - [Disponibilizando e comunicando](#disponibilizando-e-comunicando)

# Comandos disponíveis

## **commitlint**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Valida as mensagens de commit de acordo com padrões de `commit semântico`, deve ser usado apenas em merge requests ou em branchs que não a master, pois a lista de commits é determinada pela diferença da branch e a master.

#### exemplo

```sh
ci-knife commitlint -b branch-name -r ./commit-rules.js
```

#### opções

- `-b, --branch <branch-name>` : Nome da **branch** que deve ser analisada, por padrão usa a variável _CI_MERGE_REQUEST_SOURCE_BRANCH_NAME_ (para merge request) ou _CI_COMMIT_REF_NAME_ (para branch) do gitlabci
- `-s, --source <branch-name`: Nome da **branch** que deve ser usada como base, por padrão usa a variável CI_DEFAULT_BRANCH (do próprio [gitlabci](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html)).
- `-r, --rules <file-path>` : arquivo de regras do _commitlint_, por padrão utiliza o pacote de regras: ['@commitlint/config-conventional'](https://github.com/conventional-changelog/commitlint/blob/master/@commitlint/config-conventional/index.js)
- `-t, --commit-title` : Essa opção inclui o título do MR para ser analisado, se está de acordo com as regras do _commitlint_.

## **mr-review**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Envia à um canal de mensagens (gchat) uma mensagem contendo o link de um MR do projeto, também pode sortear revisores para esse MR.

#### exemplo (.gitlab-ci.yml)

```yaml
  review:
    image: $CIKNIFE_IMAGE
    stage: test
    script: ci-knife mr-review
    only:
        - merge_requests
```

#### variáveis de ambiente

Variável          | Descrição                                                                | Obrigatoriedade
------------------|--------------------------------------------------------------------------|--------------------------------------------------------------------------
`GCHAT_MR_WEBHOOK` | endereço do Webhook do canal onde o link do MR será enviado             | Obrigatório
`MR_REVIEWERS`  | lista de id usuário no GChat : username do gitlab, múltiplos usuários podem ser adicionados separando por `\|\|` exemplo: `123:maria\|\|456:joao`, você tambem pode usar o valor `all` para marcar todos os usuários do canal | apenas se você quiser marcar usuários sorteados para revisão
`MR_REVIEWERS_NUMBER`   | número de pessoas a serem sorteadas para a revisão do MR. Com a opção `all` na variável `MR_REVIEWERS` esta opção de quantidade será ignorada. | se não informado serão considerados 3
`MR_REVIEWERS_GROUPS`  | Nome do(s) handler(s) no gchat, separados por `\|\|`. Exemplo: `squad-xpto\|\|squad-abc`. Esta variável tem prioridade sobre a variável MR_REVIEWERS (ou seja, se informada ambas, apenas a `MR_REVIEWERS_GROUPS` será considerada); o grupo será chamado com o pokeball do bot agile tools; portanto, o canal configurado no `GCHAT_MR_WEBHOOK` deve ter o app AgileGoat adicionado. | Opcional
`MR_NOTIFY_EXIT_IN_DRAFT`  | Quando preenchida com `true` caso o MR esteja em rascunho (modo draft) é feito o exit do comando, necessitando que seja reexecutado o job quando o MR estiver pronto para revisão, garantindo que a notificação sempre ocorra. | Opcional
`MR_MAX_CHANGES` | Verifica se o MR ultrapassou um máximo de alterações definidas pelo time | Opcional

## **mr-code-review**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

O comando `mr-code-review` realiza a revisão automática de código em um Merge Request (MR) utilizando um modelo de linguagem (LLM). Exemplo:

```yaml
  review:
    image: $CIKNIFE_IMAGE
    stage: test
    script: ci-knife mr-code-review
     # feature experimental, não deve barrar as entregas
    allow_failure: true 
    rules:
    # neste exemplo a analise fica opcional em draft e automatica em não draft
    - if: $CI_MERGE_REQUEST_IID && $CI_MERGE_REQUEST_TITLE =~ /^(\[Draft\]|\(Draft\)|Draft:)/
      when: manual
    - if: $CI_MERGE_REQUEST_IID
      when: always
```

1. **Resolve comentários antigos do LLM**:
   - Remove ou marca como resolvidos os comentários antigos gerados pelo LLM no MR atual.

2. **Obtém os arquivos modificados**:
   - Recupera a lista de arquivos alterados no MR.

3. **Revisa os arquivos modificados**:
   - Para cada arquivo (limitado pelo valor de `CODE_REVIEW_MAX_FILES`), realiza a revisão utilizando o LLM e registra o progresso no log.

4. **Se encontrado sugestões registra no MR**:
   - Comenta no arquivo analisado a sugestão possível de ser aplicada.

5. **A analise não acontece se**:
   - Não encontrou sugestões para o arquivo
   - O arquivo teve alterações apenas em espaçamento ou não teve alterações relevantes

### Variáveis de Ambiente <a name="variaveis-mr-code-review"></a>

| **Variável**                     | **Descrição**                                                                                     | **Valor Padrão**         | **Obrigatório** |
|----------------------------------|---------------------------------------------------------------------------------------------------|--------------------------|-----------------|
| `CIKNIFE_LLM_TEMPERATURE`        | Temperatura do modelo LLM, controlando a criatividade das respostas.                             | `0.1`                    | Não             |
| `CIKNIFE_LLM_MAX_TOKENS`         | Número máximo de tokens permitidos na resposta do LLM.                                           | `1000`                   | Não             |
| `CIKNIFE_LLM_MODEL`              | Modelo LLM utilizado para a análise.                                                             | `gemini-2.0-flash`       | Não             |
| `CIKNIFE_LLM_EXTRA_INSTRUCTIONS` | Instruções adicionais que serão enviadas ao LLM durante a análise.                               | `''`                     | Não             |
| `CIKNIFE_LLM_REPLACE_INSTRUCTIONS` | Instruções que substituem as instruções padrão enviadas ao LLM.                                | `''`                     | Não             |
| `CIKNIFE_LLM_LANGUAGE_REVIEW`    | Linguagem/tecnologias do projeto a ser analisado. Se não informado o próprio modelo irá inferir. | `''`                     | Não             |
| `CIKNIFE_PROJECT_SQUAD`          | Nome do squad associado ao projeto. Se não informado recupera o valor do dependency.yaml         | `''`                     | Não             |
| `CIKNIFE_PROJECT_VERTICAL`       | Nome da vertical associada ao projeto. Se não informado recupera o valor do dependency.yaml      | `''`                     | Não             |
| `CIKNIFE_PROJECT_TRIBE`          | Nome da tribo associada ao projeto. Se não informado recupera o valor do dependency.yaml         | `''`                     | Não             |
| `CIKNIFE_PROJECT_ORG`            | Nome da organização associada ao projeto. Se não informado recupera o valor do dependency.yaml   | `''`                     | Não             |
| `CIKNIFE_PROJECT_ORG`            | Nome da organização associada ao projeto. Se não informado recupera o valor do dependency.yaml   | `''`                     | Não             |
| `CIKNIFE_CODE_REVIEW_MAX_FILES`  | Maximo de arquivos a serem analisados no code review.                                            | `100`                    | Não             |
| `CIKNIFE_CODE_REVIEW_DEBUG`      | Habilita logs do retorno do LLM                                                                  | `false`                  | Não             |
| `CIKNIFE_CODE_REVIEW_BLOCK_EXTENSIONS`  | Extensões para ignorar na análise do MR, além das defaults ja configuradas no ciknife.    | ``                       | Não             |
| `CIKNIFE_CODE_REVIEW_BLOCK_PATTERNS`  | Padrões de arquivos (regex) para ignorar na análise do MR, além dos defaults já configurados no ciknife. Ex: `\.env,package-lock\.json` | ``                       | Não             |
| `CIKNIFE_LLM_SERVER_URL`         | URL do servidor LLM utilizado para realizar as análises.                                         | -                        | Configurado globalmente  |
| `CIKNIFE_LLM_SERVER_TOKEN`       | Token de autenticação para acessar o servidor LLM.                                               | `''`                     | Configurado globalmente  |

## **mr-sla**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Verifica se os Merge Requests (MRs) abertos já ultrapassaram o SLA (Service Level Agreement) acordado em horas. Este comando ajuda a monitorar o tempo de vida dos MRs e garantir que eles sejam revisados e fechados dentro do prazo esperado.

Ira notificar os MRs com review expirado no canal configurado em `GCHAT_GMUD_WEBHOOK`.

Se escolhido a opção close, ira fechar os MRs abertos e sem atualização ha mais de X tempo (configurado com os parâmetros abaixo).

### Parâmetros mr-sla

| **Parâmetro**             | **Descrição**                                                                                                               | **Valor Padrão**              | **Obrigatório** |
|---------------------------|-----------------------------------------------------------------------------------------------------------------------------|-------------------------------|-----------------|
| `-r, --review-sla-hours`  | SLA acordado para revisão em horas. . Se não informado usa o valor `MR_SLA_REVIEW_HOURS`.                                   | 24 horas                      | Não             |
| `-c, --close-sla-hours`   | SLA acordado para fechamento em horas. Se não informado usa o valor `MR_SLA_CLOSE_HOURS`.                                   | 24 * 30, que equivale a 1 mês | Não             |
| `-g, --group-id`          | Se informado avalia todos os MRs do grupo informado (pode ser definido também com variável `MR_SLA_GROUP_ID`)               | `null`      | Não             | Não             |
| `-p, --project-ids`       | Se informado avalia todos os MRs dos projetos informados (ids) (pode ser definido também com variável `MR_SLA_PROJECT_IDS`) | `null`                        | Não             |
| `-m, --max-notifications` | Maximo de vezes que ira notificar um MR atrasado. Default usa a env  `MR_SLA_MAX_NOTIFICATIONS`.                            |  `3`                          | Não             |
| `-t, --group-title`       | Título que será exibido para grupos de repositórios e multiplos projetos. Também via variável `MR_SLA_GROUP_TITLE`          |  `MULTIPLOS PROJETOS`         | Não             |
|                           | Ignora branches com o padão definido com a env `MR_SLA_IGNORE_BRANCHES`.                                                    |  `/^renovate\//`              | Não             |

### Exemplos de Uso

```bash
# Verifica os MRs abertos com o SLA padrão configurado
ci-knife mr-sla

# Verifica os MRs abertos com um SLA de 24 horas para revisão
ci-knife mr-sla mr-sla --review-sla-hours 24

# Verifica os MRs abertos e fecha os que ultrapassaram o SLA de 720 horas = 1 mes
ci-knife mr-sla --close-sla-hours 720

# Verifica os MRs de um grupo específico
ci-knife mr-sla --group-id 12345

# Verifica os MRs de múltiplos projetos com 1 job centralizado
ci-knife mr-sla --project-ids 123 456 789
````

> \* Você pode combinar grupos de projetos (`group-id`) e ids de projetos isolados separados por espaço (`project-ids`), caso use essas opções vale lembrar que o projeto atual não é incluido automaticamente, caso não utilize essas opções o comando irá considerar o projeto atual automaticamente.

## **check-mr-approved**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Verifica se o MR informado ou o MR atual contém as aprovações mínimas necessárias para prosseguir com o merge, seguindo as boas práticas de desenvolvimento do labs.

São consideradas aprovações os approves no botão do Gitlab, os emojis de joinha(thumbusp) atribuídos ao MR não serão considerados. Os aprovadores devem ser no mínimo dois usuários distintos (configurável) e diferentes do autor do job/MR.
Também é possível definir quem são os responsáveis pelo projeto e exigir um número mínimo de aprovações deste grupo. (ver no tópico "variáveis" abaixo).

### Parâmetros mr-sla

| **Parâmetro** | **Descrição**                                                                                  | **Valor Padrão** | **Obrigatório** |
|---------------|------------------------------------------------------------------------------------------------|------------------|-----------------|
| `-m, --mr`    | send mr id, example: -m 15, if not informed, it will try to get the current merge_request_iid. | MR atual         | Não             |
| `--no-msg`    | don`t send slack or gchat msg                                                                  | false            | Não             |


#### exemplo check mr approved

```yaml
  review:
    image: $CIKNIFE_IMAGE
    stage: validation
    script: ci-knife check-mr-approved
    only:
        - merge_requests
```

Caso deseje executar a validação fora de um pipeline em merge request, é necessário informar o MR ID através do argumento `-m 123` ou `--mr 123`.

#### variáveis de ambiente

Variável          | Descrição
------------------|--------------------------------------------------------------------------
`MR_MINIMUM_APPROVAL` | Mínimo de aprovações necessárias (2 por padrão)
`MR_MINIMUM_OWNERS_APPROVAL`  | Mínimo de aprovações pelos responsáveis pelo projeto (necessita da env CODE_OWNERS)
`MR_CHANGES_RESET_APPROVALS`  | Zera as aprovações caso o MR receba novas alterações após a aprovação (`false` por padrão)
`MR_MAX_CHANGES` | Verifica se o MR ultrapassou um máximo de alterações definidas pelo time
`CODE_OWNERS`   | usernames do Gitlab dos responsáveis pelo projeto separados por \|\| (exemplo: `vinicius.komninakis\|\|rafael.marinho`)
`OWNERS_APPROVAL_SKIP_BUGS` | (boolean) diz se a aprovação dos responsáveis deve ser ignorada em caso de Bug (para atuação de times de SRE, por padrão é true)
`GIT_API_BOT_TOKEN` | token gerado no projeto para reset das aprovações em caso de mudança.

## **create-release**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

O comando abaixo executa as seguintes ações:

- Gera automaticamente o `CHANGELOG`
- Atualiza a versão do _**npm**_ (caso seja projeto `nodejs`)
- Publica o pacote _**npm**_
- Gera `tag` do git.

#### exemplo

```sh
ci-knife create-release
```

#### opções

- `-d, --dry-run` : roda em modo teste, não publicando e/ou commitando as alterações, apenas loga o _**CHANGELOG**_ que seria gerado.
- `-n, --no-npm` : não publica pacote npm (apenas atualizará a versão do **package.json** se houver).
- `-s, --no-ssh` : não utiliza a variável _SSH_PRIVATE_KEY_ para gerar a autenticação para o git.
- `-w, --without-npm`: utilizar em projetos com _stack_ diferente de nodejs (sem o **package.json**)
- `-r, --no-release`: não subir o changelog na lista de releases do gitlab
- `-b, --branch <branch-name>` : Nome da **branch** que onde o CHANGELOG será criado, por padrão será usada a varenv CI_DEFAULT_BRANCH, baseado no gitlabci.
- `-p, --no-prefix` : gerar a tag sem `v` antes da versão
- `--debug` : roda em modo debug exibindo passo a passo e informações capturadas no processo.

#### variáveis de ambiente

Variável          | Descrição                                                                | Obrigatoriedade
------------------|--------------------------------------------------------------------------|--------------------------------------------------------------------------
`SSH_PRIVATE_KEY` | chave privada para acesso de escrita ao repositório git                  | só é necessário se não quiser usar usuário do `ci-knife` ver [dica](#git)
`GIT_USER_EMAIL`  | email do git ao qual pertence a chave (*criar um usuário para a squad)   | só é necessário se não quiser usar usuário do `ci-knife` ver [dica](#git)
`GIT_USER_NAME`   | usuário do git ao qual pertence a chave (*criar um usuário para a squad) | só é necessário se não quiser usar usuário do `ci-knife` ver [dica](#git)
`GIT_API_TOKEN`   | personal access token do gitlab com acesso a API                         | só é necessário se não quiser usar usuário do `ci-knife` ver [dica](#git)
`NPM_USERNAME`    | usuário de acesso ao registry npm (*usuário do gitlab / criar um usuário para a squad)             | Caso use npm publish |
`NPM_EMAIL`       | email de acesso ao registry npm (*usuário do gitlab / criar um usuário para a squad)               | Caso use npm publish |
`NPM_PASSWORD`    | senha de acesso ao registry npm (*personal access token do gitlab / criar um usuário para a squad) | Caso use npm publish |
`NPM_REGISTRY`    | endereço do registry privado de npm                                                                | Caso use npm publish |
`NPM_SCOPE`       | escopo da biblioteca ex.: @magalu/meu-pacote                                                       | Para npm com escopo  |

### Atualizando versão em arquivos

Esta funcionalidade permite atualizar a versão da `release` em outros arquivos (package.json é alterado automaticamente pelo semantic-release).

Para isto você deve criar o arquivo `release-replacements.json` na raiz do seu projeto, ele deve conter um array com um objeto para cada padrão de replace.
O objeto deve conter ao menos os campos

- files: string ou array de string contendo o caminho do(s) arquivo(s)
- from: pattern da string a ser procurada
- to: pattern do replace com objeto do semantic-release (ex.: `nextRelease.version`)

Exemplo:

```json
[
  {
    "files": ["foo/__init__.py"],
    "from": "__VERSION__ = \".*\"",
    "to": "__VERSION__ = \"${nextRelease.version}\""
  }
]
```

Para mais detalhes ver a biblioteca:
<https://github.com/google/semantic-release-replace-plugin>

## **create-gmud**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Gera automaticamente a `GMUD`, de acordo com o `CHANGELOG` e avisa no canal do time (caso configurado)

#### exemplo

```
ci-knife create-gmud
```

#### opções

- `-m, --no-msg` : não enviar mensagem com o link da gmud.
- `-t, --type <type>` : utilizado para a criação de gmuds com templates diferentes do padrão. Necessário informar o tipo do **template** que deseja utilizar. Opções: ['existingProject', 'expedite', 'newProject']

#### variáveis de ambiente

Variável                  | Descrição                                                                         | Obrigatoriedade
--------------------------|-----------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------
`GIT_API_TOKEN`           | personal access token do gitlab com acesso a API (*criar um usuário para a squad) | só é necessário se não quiser usar usuário do `ci-knife` ver [dica](#git)
`GMUD_REPO_ID`            | id do repositório onde será criada a issue                                        | só é necessário se não for o repo padrão `https://gitlab.luizalabs.com/luizalabs/gmud/issues`
`GMUD_REVIEWER`           | grupo do gitlab responsável pela revisão                                          | só é necessário se não for `@luizalabs/squad\-gmud`
`GMUD_APP`                | nome do app a ser exibido na GMUD                                                 | caso não definido será usado o nome do repositório
`GMUD_RISK`               | risco no deploy da aplicação                                                      | sim
`GMUD_UNAVAILABILITY`     | o deploy gera uma indisponibilidade?                                              | sim
`GMUD_DIFF_FIRST_VERSION` | o deploy gera uma indisponibilidade?                                              | só é necessário se não for o padrão `Primeira Release.`
`GMUD_TESTS`              | Texto sobre como o projeto está testado                                           | sim
`GMUD_DESIGN_DOC`         | Link do design docs do projeto                                                    |
`GMUD_EXPEDITE_REASON`    | Motivo da alteração precisar entrar urgentemente em produção                      |
`GMUD_EXPEDITE_LEADER`    | Usuário do líder da equipe                                                        |
`SLACK_GMUD_CHANNEL`      | canal do slack que será avisado sobre GMUD com o link                             | sim (se utilizar o slack para enviar as mensagens)
`SLACK_TOKEN`             | Token para uso da Api do slack                                                    | só é necessário se for usar um customizado
`GCHAT_GMUD_WEBHOOK`      | endereço do webhook do Google Chat do canal onde será enviado o link da GMUD      | sim (se utilizar o Google Chat para enviar as mensagens)
`SONAR_PROJECT_KEY`       | Id do projeto no sonar                                                            | se não for definido será o nome do repositório
`SONAR_URL`               | url do sonar                                                                      | só é necessário se não for o padrão `sonarqube.luizalabs.com`
`FORTIFY_URL`             | (`Depreciado`) url do fortify (url completa da versão `master` do fortify) | sim
`ATENA_ORIGIN_FROM_STRATEGY`  | Qual estratégia será utilizada entre `default_branch` ou `tag`. | Caso não definido será usado o valor `tag`
`ATENA_PIPELINE_BASE_URL`  | URL base da pipeline de Atenas. Se não informado usará a configuração global | não

> \* todas as variáveis são `não obrigatórias`

[veja aqui alguns exemplos](https://gitlab.luizalabs.com/luizalabs/ci-knife/blob/master/example/)

## **argocd-deploy / argocd-rollback**

<div  style="margin-top: -20px; text-align: right"><a  href="#ci-knife">voltar ao topo</a></div>

Realiza o deploy no ArgoCD, para isso o ele cria uma imagem docker, depois a publica no repositório de images docker do Magalu. A imagem abaixo ilustra todo este fluxo.

---

![Fluxo de deploy usando o comando argocd-deploy](docs/flow-argocd-deploy.png)

### Comando

```sh
# gitlab.ci.yml
  deploy:
    image: $CIKNIFE_IMAGE
    tags:
      - global-docker-tls
    services:
      - docker:26-dind
    script: ci-knife argocd-deploy

  rollback:
    image: $CIKNIFE_IMAGE
    script: ci-knife argocd-rollback
```

Obs.: Como este job cria uma imagem docker ele precisa do service `docker:26-dind` e da tag do certificado para o docker `global-docker-tls`

[veja mais exemplos aqui](https://gitlab.luizalabs.com/luizalabs/ci-knife/blob/master/example/)

#### Opções

- -a, --apps
  - Nome dos aplicativos que vão ser deployados, exemplo: `odin-api odin-wk`
  - Esse valor pode ser informado através da variável de ambiente `ARGOCD_APPS`
  - Caso não informado será o nome do projeto (var do gitlabci `CI_PROJECT_NAME`)
- -e, --namespace
  - Caminho do repositório onde está localizado as configurações do ArgoCD, exemplo: `cicd/tribe-webstore-transacional-servicos/squad-magamais`
  - Esse valor pode ser informado através da variável de ambiente `ARGOCD_NAMESPACE`
- --docker-repository
  - Docker Repository onde será publicado a imagem docker, exemplo: `gcr.io/magalu-cicd/squad-magamais/bragi`
  - Esse valor pode ser informado através da variável de ambiente `DOCKER_REPO`
- --docker-image
  - com essa opção será criada a imagem Docker/tag antes de fazer o deploy
- --docker-tag
  - com essa opção será criada uma tag da imagem Docker antes de fazer o deploy
- --docker-build-args
  - com essa opção pode ser passada uma lista de variáveis de ambiente para o Dockerfile, exemplo: `--docker-build-args ENVIRONMENT=sandbox TOKEN=${TOKEN}`
- -f, --file
  - permite informar o endereço customizado para o Dockerfile (exemplo: `--file ./packages/server/Dockerfile`)
  - o padrão do ci-knife é buscar na raiz do projeto
- -s, --source
  - versão da imagem Docker a partir da qual será gerada a tag, exemplo: `123456`
  - Esse valor será pego por padrão da variável `CI_COMMIT_SHORT_SHA`
- -b, --branch
  - Branch em que deve-se fazer o deploy, exemplo: `master`, `production`, `sandbox`, `stage`, `staging`, `hml`, etc.
  - Esse valor pode ser informado através da variável de ambiente `ARGOCD_BRANCH`
- -p, --path
  - pasta do repositório de CICD em que deve ser feito o deploy, exemplo: `sandbox`, `production`
  - alternativa a criação de múltiplas branches
  - Esse valor pode ser informado através da variável de ambiente `ARGOCD_PATH`, o seu valor default é `/`
- -pp, --prefixPath
  - Prefixo da pasta do repositório de CICD em que fazemos o deploy/rollback, exemplo: `production/magalu-ops-comercial`
  - ao juntar com o namespace seria algo como: `production/magalu-ops-comercial/gru`, seu valor default é `vazio`.
- -t, --tag
  - Versão que está sendo deployada, exemplo `v1.0.0`
  - Quando deployado através de um pipeline de **TAG** esse valor é o nome da tag. Já outros pipeline é usado o commit, exemplo: `84526c3d`
- -m, --no-msg
  - Não envia mensagem sobre o deploy.
- -n, --new-relic
  - Notifica o new relic de que um deploy foi realizado. Para funcionar precisa setar a variável `NEW_RELIC_APP_ID`. **Só funciona para deploys de tags**
- --check-gmud
  - Valida se a GMUD está aprovada antes de realizar o deploy.
- -v, --variation
  - adiciona na mensagem a informação da variação que está sendo entregue, múltiplas variações entregues seguidas terão as mensagens agrupadas em uma thread (apenas no slack, dentro do período de tempo configurado `SLACK_THREAD_TIMEOUT`). Essa opção geralmente é usada quando são entregues múltiplas imagens docker (builds diferentes) através do mesmo repo/GMUD (ex.: 2 front-ends com temas diferentes), já que se for a mesma imagem docker o comando padrão já permite que sejam passados um array de apps.
- --sync
  - após atualizar a versão dos apps força a sincronização com o ArgoCD;
  - obrigatório uso das variáveis `ARGOCD_SERVER` e `ARGOCD_AUTH_TOKEN`, mais detalhes no comando `argocd-sync`.

### variáveis de ambiente

Variável         | Descrição
-----------------|----------------------
`DOCKER_REPO`    | Opcional, caso não exista a imagem sera criada no padrão: `${IMAGE_REGISTRY}/nome-do-repositorio-do-git`
`ARGOCD_NAMESPACE` | Opcional, seta o namespace onde está os apps que estão sendo deployados, exemplo: `cicd/tribe-webstore-transacional-servicos/squad-magamais`
`ARGOCD_APPS` | Opcional, seta os apps que iram ser deployados separado por espaço, exemplo: `bragi-api bragi-worker`
`ARGOCD_BRANCH` | Opcional, em qual branch deve-se fazer o deploy, exemplo: `master`, `production`, `sandbox`, `stage`, `staging`, `hml`, etc.
`ARGOCD_PATH` | Opcional, pasta do repositório de CICD em que deve ser feito o deploy, exemplo: `sandbox`, `production`.
`ARGOCD_PREFIX_PATH` | Opcional, pasta de prefixo do repositório de CICD em que deve ser feito o deploy, exemplo:  `production/magalu-ops-comercial`.
`ARGOCD_VARIATION` | Opcional, nome customizado da variação que vai ser entregue (múltiplos builds).
`GCHAT_DEPLOY_WEBHOOK`    | Endereço do webhook do canal do Google Chat para mensagens de deploy (só é necessário se for avisar em um canal diferente do `#producao-deploys`)
`SLACK_DEPLOY_CHANNEL`    | Id do canal do slack para mensagens de deploy (só é necessário se for avisar em um canal diferente do `#producao-deploys`)
`SLACK_TEAM_ID`           | Id do time a ser marcado no canal (para múltiplos times separar por `\|\|`) (obrigatório a menos que use a opção `--no-msg`)
`SLACK_THREAD_TIMEOUT`    | Agrupa as mensagens no canal dentro do tempo passado em minutos (default 60 minutos)
`SLACK_TOKEN`  | Token para uso da Api do slack (só é necessário se for usar um customizado)
`NEW_RELIC_APP_ID`        | Id do app no New relic (ícone de informação do lado do nome do app tem essa info). _**Só funciona para deploys de tags**_.
`CHECK_GMUD_APPROVED`        | Valida se a GMUD está aprovada antes de realizar o deploy. (Valor default 'false').

## **argocd-sync**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Faz com que a App seja sincronizada no ArgoCD com o repositório de CICD, muito útil em projetos que precisam quem a App esteja atualizada antes do próximo job do pipeline, por exemplo.

### Comando

```sh
# gitlab.ci.yml
  deploy:
    image: $CIKNIFE_IMAGE
    script: ci-knife argocd-sync --apps my-app
```

#### opções

- -a, --apps
  - Nome dos aplicativos que serão sincronizados, exemplo: `odin-api odin-wk`
  - Esse valor pode ser informado através da variável de ambiente `ARGOCD_APPS`

### variáveis de ambiente

Variável | Descrição
------------- | -----------------
`ARGOCD_APPS` | seta os apps que serão sincronizados separado por espaço (exemplo: `bragi-api bragi-worker`), é obrigatória se você não utilizou a opção `--apps`
`ARGOCD_SERVER` | obrigatória, domínio do ArgoCD, exemplo: `argocd-hml.ipet.sh`
`ARGOCD_AUTH_TOKEN` | o apiKey do ArgoCD para que o ci-knife possa autenticar

## **sonar-scanner**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Roda o `SonarScanner` e envia os dados ao `SonarQube`

#### exemplo

```sh
ci-knife sonar-scanner
```

#### opções

- `-g, --generate-report` : Mostrar o relatório de [Code Quality Widget](https://docs.gitlab.com/ee/user/project/merge_requests/code_quality.html#code-quality-widget) do Gitlab diretamente na área do widget. (Valor default 'false') (Somente para o modo de análise do sonar `publish`) .

#### variáveis de ambiente

Variável                      | Descrição
------------------------------|-----------------------------------------------|
`SONAR_URL`                   | Url do sonarqube (possui valor default global)
`SONAR_TOKEN`                 | Token de login do sonarqube  (possui valor default global)
`SONAR_ANALYSIS_MODE`         | preview, publish (preview by default)
`SONAR_PROJECT_KEY`           | slug do projeto, ex.: ci-knife (caso não definido será o nome do repositório)
`SONAR_DEBUG`                 | ativa modo debug
`SONAR_SOURCES`               | path onde está o código
`SONAR_LANGUAGE`              | linguagem da aplicação
`SONAR_MERGE_REQUEST_ID`      | (Staging) id do merge request
`SONAR_MERGE_REQUEST_BRANCH`  | (Staging) branch do merge request
`SONAR_MERGE_REQUEST_BASE`    | (Staging) branch target do merge request
`SONAR_QUALITY_WAIT`          | (Staging) define se espera resultado do quality gateway para falhar ou não ex.: true

Além disso você deve criar um arquivo `sonar-project.properties` na raiz do projeto, com parâmetros complementares, exemplo:

```properties
sonar.projectKey=ci-knife
sonar.projectName=CI Knife
sonar.sources=src/
sonar.language=js
sonar.sourceEncoding=UTF-8
sonar.test.inclusions=**/*.test.ts
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

> \* Você pode omitir do arquivo de `properties` os parâmetros que já foram configurados via variável de ambiente

> ** Apesar de possível, **não** é recomendado o uso da propriedade `sonar.login` versionada junto ao arquivo de configuração.

## **security-scanner**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Cria e envia o código fonte do projeto para uma solicitação de análise com viés de segurança no projeto `Santuário de Atena`.

> \* É necessário que o projeto possua em sua raiz, o arquivo `dependency.yaml` com as informações de segurança atualizadas. Para mais informações acesse o [link](https://magazine.atlassian.net/wiki/spaces/SDLABS/pages/3201695953/Pipeline+De+Seguran+a+-+Implementa+o+no+GitLab.).

#### exemplo

```sh
ci-knife security-scanner
```

## **security-result**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Consulta o resultado da última análise de segurança na API do Atena e expõe o resultado no output do job.

- Exibe o resultado da análise em formato de tabela no output do job.
- Jobs com vulnerabilidades críticas são destacados em vermelho.
- O comando falha (lança um erro) se qualquer job tiver um status diferente de `success` ou se não houver resultados de análise.

#### exemplo

```sh
ci-knife security-result
```

#### opções

- `-b, --branch <branch>` : (Opcional) Especifica a branch para consultar a análise no santuário de atena. Se não for informada, será utilizada a branch padrão do projeto (`CI_DEFAULT_BRANCH`).

## **create-docker-image** / **publish-docker-tag**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

### **create-docker-image**

Cria uma imagem docker no `gcr.io/magalu-cicd` (Google Container Registry do Magalu).
O comando irá gerar uma imagem com o id da pipeline, caso esteja rodando em uma `tag` o comando irá gerar tags da versão.
Exemplo, se a versão for `v1.0.4`, irá:

- gerar a versão `v1.0.4`
- atualizará a versão `v1.0`
- atualizará a versão `v1`
- atualizará a versão `latest`

#### exemplo no gitlab

```sh
docker image:
  image: gcr.io/magalu-cicd/ci-knife:vX.X.X
  tags:
      - global-docker-tls
  services:
    - docker:26-dind
  stage: docker image
  script:
    - ci-knife create-docker-image
  when: manual
```

> obs.: é necessário uso do service `docker:26-dind` (Docker-in-Docker) e da tag `global-docker-tls` para que o runner adicione o certificado

#### opções

- --docker-repository
  - Docker Repository onde será publicado a imagem docker, exemplo: `gcr.io/magalu-cicd/squad-magamais/bragi`
  - Esse valor pode ser informado através da variável de ambiente `DOCKER_REPO`

- --docker-build-args
  - com essa opção pode ser passada uma lista de variáveis de ambiente para o Dockerfile, exemplo: `--docker-build-args ENVIRONMENT=sandbox TOKEN=${TOKEN}`
- -f, --file
  - permite informar o endereço customizado para o Dockerfile (exemplo: `--file ./packages/server/Dockerfile`)
  - o padrão do ci-knife é buscar na raiz do projeto
- -t, --tag
  - Versão que está sendo deployada, exemplo `v1.0.0`
  - Quando deployado através de um pipeline de **TAG** esse valor é o nome da tag. Já outros pipeline é usado o commit, exemplo: `84526c3d`

#### variáveis de ambiente

Variável         | Descrição
-----------------|----------------------|
`DOCKER_REPO`    | Opcional, caso não exista a imagem sera criada no padrão: `${IMAGE_REGISTRY}/nome-do-repositorio-do-git`
`IMAGE_REGISTRY` | Opcional, seta o endereço do registry da imagem, valor padrão: `gcr.io/magalu-cicd`

### **publish-docker-tag**

Cria uma tag docker baseada em uma imagem docker já existente.
Muito util quando você quer criar a imagem e testar antes de gerar de fato a tag.

#### exemplo no gitlab

```sh
docker image:
  image: gcr.io/magalu-cicd/ci-knife:vX.X.X
  tags:
      - global-docker-tls
  services:
    - docker:26-dind
  stage: docker image
  script:
    - ci-knife create-docker-image --tag "$CI_COMMIT_SHORT_SHA"
  only: ['tags']

docker tag:
  image: gcr.io/magalu-cicd/ci-knife:vX.X.X
  tags:
      - global-docker-tls
  services:
    - docker:26-dind
  stage: docker tag
  script:
    - ci-knife publish-docker-tag
  only: ['tags']
```

> obs.: é necessário uso do service `docker:26-dind` (Docker-in-Docker) e da tag `global-docker-tls` para que o runner adicione o certificado

#### opções

- --docker-repository
  - Docker Repository onde será publicado a imagem docker, exemplo: `gcr.io/magalu-cicd/squad-magamais/bragi`
  - Esse valor pode ser informado através da variável de ambiente `DOCKER_REPO`

- -s, --source
  - versão da imagem Docker a partir da qual será gerada a tag, exemplo: `123456`
  - Esse valor será pego por padrão da variável `CI_COMMIT_SHORT_SHA`
- -t, --tag
  - Versão que está sendo deployada, exemplo `v1.0.0`
  - Quando deployado através de um pipeline de **TAG** esse valor é o valor da tag, exemplo: `v1.1.1`.

#### variáveis de ambiente

Variável         | Descrição
-----------------|----------------------|
`DOCKER_REPO`    | Opcional, caso não exista a imagem sera criada no padrão: `${IMAGE_REGISTRY}/nome-do-repositorio-do-git`
`IMAGE_REGISTRY` | Opcional, seta o endereço do registry da imagem, valor padrão: `gcr.io/magalu-cicd`

## **api-contract-test**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Api-contract-test gera testes de contrato de APIs a partir de uma OpenAPI Specification 3.0.
Os testes gerados simulam um consumidor, que utiliza todas as informações retornadas pela API, prevenindo que o contrato seja quebrado em tempo de release.

O comando executa as seguintes ações:

- Gera um artefato Pact baseado em uma OpenAPI Specification 3.0 necessariamente em JSON
- Publica o artefato gerado no broker informado

[Clique aqui](https://magazine.atlassian.net/wiki/spaces/EA/pages/2220591769/Design+Doc) para mais informações sobre como funciona a solução.

#### exemplo

```sh
$ "ci-knife api-contract-test
     -s \"$PWD/valid_oas.json\"
     -b \"http://meu-pact-broker.ipet.sh/\"
     -u=\"broker-user\"
     -p=\"broker-password\"
     -c \"3.0.0\"
     -t \"['test']\"
     -d \"$PWD/dependency.yaml\"
     -o \"full\"
     -r \"openapi:saul\"
     "
```

#### Opções

- -s, --openapi-spec
  - Define o caminho relativo para sua spec em json ou yaml. Obrigatório.

- -b, --broker-url
  - Define o endereço do seu Pact Broker. Opcional, caso não seja informado será assumido o endereço contido na variável de ambiente “API_PACT_BROKER_URL”.
- -u, --broker-user
  - Define o usuário do Pact Broker. Opcional, caso não seja informado será assumido o usuário contido na variável de ambiente “API_PACT_BROKER_USER”.
- -p, --broker-password
  - Define a senha do Pact Broker. Opcional, caso não seja informada será assumida a senha contida na variável de ambiente “API_PACT_BROKER_PASSWORD”.
- -c, --consumer-version
  - Define a versão do contrato de consumidor. Opcional, caso não seja informado será assumido o nome da branch atual, obtido através da variável de ambiente “CURRENT_BRANCH”.
- -t, --tags
  - Array de tags que permite adicionar metadados da versão. Uma prática recomendada é informar o nome da branch quando estiver verificando ou publicando um contrato, ou informar o ambiente quando estiver fazendo o deploy. É opcional, porém são adicionadas algumas informações extraídas do seu dependency.yaml. Veja mais em [Tags](https://docs.pact.io/pact_broker/tags).
- -d, --dependency-yaml
  - Define o caminho relativo do seu dependency yaml. É opcional e quando não informado, é considerado o valor “./dependency.yaml”.
- -o, --contract
  - Define se o contrato a ser gerado deve conter somente as interações de sucesso (2xx) ou se deve considerar todas as interações contidas na OAS. Os valores possíveis são `only-success` ou `full`. É um parâmetro opcional e por default é setado para `full`.
- -r, --ruleset
  - Define o ruleset a ser utilizado na validação de lint da OAS. Os valores possíveis são `openapi:saul` e `openapi:maas`. É um parâmetro opcional e o valor default é `openapi:saul`.

## **magalint**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Magalint é uma ferramenta de lint para JSON e YAML, que fornece alguns conjuntos de regras baseadas no Spectral para validar qualquer documento.

[Clique aqui](https://gitlab.luizalabs.com/luizalabs/engenharia-apis/magalint) para acessar o repositório da solução.

Dúvidas podem ser encaminhadas no canal #firefighting-apis.

#### Exemplo

```sh
$ "ci-knife magalint
     -f \"$PWD/openapi.json\"
     -r \"openapi:base\"
```

#### Opções

- -f, --file
  - Caminho do documento a ser validado

- -r, --ruleset
  - Ruleset a ser utilizado na validação
    - `openapi:base` - conjunto de regras para OpenAPI predefinidas pelo Spectral
    - `openapi:saul` - conjunto de regras para OpenAPI necessárias para a utilização do Better Call Saul
    - `openapi:maas` - conjunto de regras para OpenAPI necessárias para exposição de APIs no MaaS

## **gcs-deploy / gcs-rollback**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

Publica aplicações de arquivos estáticos no Google Cloud Storage e realiza o versionamento dos arquivos no NPM Nexus.
Também envia mensagens sobre o inicio e fim do deploy e altera a label da GMUD para Deployed e fecha a gmud no caso de
sucesso. (é necessário que o usuário do git tenha acesso de desenvolvedor ao git do luizalabs)

#### exemplo

```sh
ci-knife gcs-deploy
```

```sh
ci-knife gcs-rollback
```

> Os comandos gcs-deploy e gcs-rollback devem ser utilizados na substituição de comando para deploy de produção, pois realizam o
> versionamento.

#### Staging

Para deploy em ambiente de staging deve ser utilizado o comando `--no-npm` para que os artefatos não sejam enviados ao nexus

```sh
ci-knife gcs-deploy --no-npm --no-msg
```

#### opções

- `-p, --path`: **[Somente para deploy]** Diretório onde se encontra o bundle da aplicação. Obrigatoriamente deve ser informado.
- `-t, --tag`: A versão será obtida a partir da TAG, não é necessário informar a versão no comando. Se informado, o
  versionamento será realizado com a versão informada.
- `-m, --no-msg`: não envia mensagem sobre o deploy.
- `-n, --no-npm`: não publica pacote npm (apenas envia para o gcs).
- `-c, --command <cp, rsync>`: utilizar um comando customizado para deploy, **padrão é `cp`**. [Mais informações dos motivadores](https://magazine.atlassian.net/wiki/spaces/TWE/pages/4152492407/Erro+Comandos+CI-KNIFE+deploy+statico).
- `-a, --args`: Passar argumentos para o comando customizável, como `-r -d`.
- `-rbg, --resetBuildGlob`: não utilizar "*" no glob do path de origem do comando, exemplo: `./build` ao invés de `./build/*`.
- `-v, --variation`: adiciona na mensagem do slack a informação da variação que está sendo entregue, multiplas variações entregues seguidas terão as mensagens agrupadas em uma thread (as mensagens só será agrupadas no slack, dentro do periodo de tempo configurado `SLACK_THREAD_TIMEOUT`). Essa opção geralmente é usada quando são entregues diversas apps através do mesmo repo/GMUD (microserviços).
- `--check-gmud`: Valida se a GMUD está aprovada antes de realizar o deploy. Uma outra opção é usar a variável `CHECK_GMUD_APPROVED` descrita a seguir.
- `--prune`: Faz prune de uma pasta no bucket antes do deploy/rollback. Util para limpar pastas com arquivos gerados dinamicamentes como pastas de arquivos bundle de frontend. Caso deseje fazer a limpeza do bucket todo o path informado pode ser "**". Exemplo: `ci-knife gcs-deploy --prune "**"`. Atenção com essa opção pois pode gerar indisponibilidade no frontend durante a subida dos novos arquivos, o recomendado é que seu bucket/cdn tenha um cache configurado para menor impacto.
- `--cache-clean`: Força a limpeza do cache do CDN antes de realizar o deploy/rollback. Útil quando é necessário garantir que os usuários receberão a versão mais recente dos arquivos imediatamente após o deploy, sem precisar esperar a expiração natural do cache. **padrão é `true`**

#### variáveis de ambiente

Variável                  | Descrição                                                                 | Obrigatoriedade
--------------------------|---------------------------------------------------------------------------|------------------------------------------------------------------
`GCHAT_DEPLOY_WEBHOOK`    | Endereço do webhook do canal do Google Chat para mensagens de deploy      | só é necessário se for avisar em um canal diferente do `#producao-deploys`
`SLACK_DEPLOY_CHANNEL`    | Id do canal do slack para mensagens de deploy                             | só é necessário se for avisar em um canal diferente do `#producao-deploys`
`SLACK_TEAM_ID`           | Id do time a ser marcado no canal (para multiplos times separar por `||`) | sim (a menos que use a opção `--no-msg`)
`SLACK_THREAD_TIMEOUT`    | Agrupa as mensagens no canal dentro do tempo passado em minutos           | default 60 minutos
`SLACK_TOKEN`             | Token para uso da Api do slack                                            | só é necessário se for usar um customizado
`STORAGE_ID`              | Bucket que será realizado deploy                                          | É obrigatório para o funcionamento.
`STORAGE_SECRET_FILE`     | Nome do arquivo da service account adicionado nos "secret files" do gitlabci               | É obrigatório para o funcionamento.
`CHECK_GMUD_APPROVED`       | Valida se a GMUD está aprovada antes de realizar o deploy. (Valor default 'false')

#### Configurando o acesso ao bucket

> [!TIP]
> Para mais detalhes de como conceder acesso ao seu bucket para o deploy, [veja esta documentação](./docs/GCS-SECURE-FILE-DEPLOY.md).

#### Configuração adicional para projetos já existentes

Para o funcionamento correto do gcs-deploy / gcs-rollback em um projeto já existente é necessário adicionar um arquivo
`package.json` no bucket do projeto (Necessário somente na primeira utilização).

##### Informações do arquivo

name: você deve manter o "@ci-knife/" e incluir ao lado o nome do seu projeto.

version: versão atual da sua aplicação (versão que está no bucket).

rollback_version: versão anterior da aplicação. (você também pode subir essa versão no nexus se quiser).

Exemplo:

```json
{
  "name": "@ci-knife/nome-da-aplicação",
  "version": "0.2.1",
  "rollback_version": "0.1.0"
}
```

## **script-deploy / script-rollback**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

O comando `script-deploy` será utilizado pra realizar comandos de deploy no ambiente de produção, disparando uma thread no canal #producao-deploys com nome da aplicação, versão e GMUD.

O comando `script-rollback` será utilizado pra realizar comandos de rollback no ambiente de produção, disparando uma thread no canal #producao-deploys com nome da aplicação, versão e GMUD.

#### exemplo comando

```sh
ci-knife script-deploy --script "npx <pkg>[@<specifier>] [args...]"
```

```sh
ci-knife script-rollback --script "npx <pkg>[@<specifier>] [args...]"

```

#### opções comando

- `-s, --script`: Comando a ser executado.
- `-l, --print-log`: Mostra um log das informações na execução da pipeline, o log contém:  Versão do projeto, nome do projeto e o comando passado com o `--script`. *(**Opcional**)
- `-m, --no-msg`: não envia mensagem sobre o deploy.
- `-v, --variation`: adiciona na mensagem do slack a informação da variação que está sendo entregue, multiplas variações entregues seguidas terão as mensagens agrupadas em uma thread (agrupará as mensagens apenas no slack, dentro do periodo de tempo configurado `SLACK_THREAD_TIMEOUT`). Essa opção geralmente é usada quando são entregues diversas apps através do mesmo repo/GMUD (microserviços).
- `--check-gmud`: Valida se a GMUD está aprovada antes de realizar o deploy.

#### variáveis de ambiente configuraveis

Variável               | Descrição                                                                   | Obrigatoriedade
-----------------------|-----------------------------------------------------------------------------|------------------------------------------------------------------
`GCHAT_DEPLOY_WEBHOOK` | Endereço do webhook do canal do Google Chat para mensagens de deploy        | só é necessário se for avisar em um canal diferente do `#producao-deploys`
`SLACK_DEPLOY_CHANNEL` | Id do canal do slack para mensagens de deploy                               | só é necessário se for avisar em um canal diferente do `#producao-deploys`
`SLACK_TEAM_ID`        | Id do time a ser marcado no canal (para multiplos times separar por `\|\|`) | sim (a menos que use a opção `--no-msg`)
`SLACK_THREAD_TIMEOUT` | Agrupa as mensagens no canal dentro do tempo passado em minutos             | default 60 minutos
`SLACK_TOKEN`          | Token para uso da Api do slack                                              | só é necessário se for usar um customizado
`CHECK_GMUD_APPROVED`        | Valida se a GMUD está aprovada antes de realizar o deploy. (Valor default 'false')

## **api-contract-verify**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

O comando `api-contract-verify` verifica se o Provider/API cumpre todas interações dos contratos que o pertence.

#### exemplo

```sh
$ "ci-knife api-contract-verify
     --provider-name=Provider
     --openapi-spec=\"$PWD/openapi.json\"
     --production
     "
```

#### Opções

- -p, --provider-name
  - Nome do Provider/API. **obrigatório**
- -s, --openapi-spec
  - Define o caminho relativo para sua spec em json ou yaml. **obrigatório**
- --production
  - Quando informado apontará para o broker de contratos de _produção_, no contrário para o broker de contratos de _playground_

## **api-catalog**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

O comando `api-catalog` irá catalogar sua API em um local único e centralizado. A ferramenta utilizada é o Backstage, onde será possível visualizar informações relevantes das APIs do Labs. O catálogo de APIs facilitará o gerenciamento, visualização, ownership, identificação, evolução das APIs.

[Clique aqui](https://magazine.atlassian.net/wiki/spaces/EA/pages/2994766575/Design+Doc+-+Cat+logo+de+APIs+flows) para mais informações sobre como funciona a solução.

#### exemplo

```sh
$ "ci-knife api-catalog
     -d \"$PWD/dependency.yaml\"
     -l \"Supported\"
     -g \"123\"
     -e \"prod\"
     -s \"$PWD/oas.json\"
     -k \"$PWD/kong_plugins.yaml\"
```

#### opções

- -d, --dependency-yaml **obrigatório informar**
  - Define o caminho relativo do dependency.yaml. A maioria das informações são extraídas desse arquivo para catalogar a API. Não é possível catalogar a API caso application name não exista:

  ```yaml
  application:
    name: xyz
  ```

- -l, --lifecycle **obrigatório informar**
  - Lifecycle da API no Backstage
    - `Experimental`: A API está em Early Release, em experimentos e desenvolvimento, aceitando feedbacks. O design poderá sofrer alterações, ou até ser removido futuramente.
    - `Pre-Release`: O design da API irá ter suporte no futuro, mas não está 100% certo, poderá sofrer mudanças.
    - `Supported`: A API está em produção é tem suporte. Mudança no design não deve quebrar para os consumidores.
    - `Deprecated`: A API ainda tem suporte, mas em breve será descartada.
    - `Retired`: A API não está mais disponível.

- -g, --gateway-id
  - Id do gateway utilizado pela API.
- -e, --environment
  - Ambiente que está fazendo deploy da API.
    - `dev`
    - `stage`
    - `prod`
- -s, --openapi-spec
  - Define o caminho relativo para a sua spec json ou yaml.
- -k, --kong-plugins
  - Define o caminho relativo para o arquivo de plugins do kong.

Utilizando atráves de [template](#api-catalog-1)

## **azion-purge**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>
Realiza o URL Purge da camada Edge Caching da Azion

[Clique aqui para saber mais sobre URL Purge.](https://www.azion.com/pt-br/documentacao/produtos/edge-application/real-time-purge/#tipos-de-purge)

#### exemplo

```sh
ci-knife azion-purge --urls https://aplicacao.luizalabs.com/*
```

#### exemplo type urls

```sh
ci-knife azion-purge -t url -u https://aplicacao.luizalabs.com/index.html https://aplicacao.luizalabs.com/style.css
```

#### opções

- -t, --type **Não é obrigatório**
  - Purge type:
    - `wildcard`: (**Valor default**) É uma maneira poderosa de purge uma lista de objetos passando uma expressão Wildcard. Você pode usar o caractere curinga (*) em argumentos de caminho ou query string.
    - `url`: É a maneira mais simples de purge seu cache de conteúdo, passando uma lista de até 50 objetos por pedido. Você não pode remover as variações do cache de conteúdo com esse método.
    - `cachekey`: É a maneira mais precisa de purge seu cache de conteúdo passando uma lista de chaves de cache de até 50 objetos por pedido.

- -u, --urls **obrigatório informar ao menos uma**
  - Urls que terão o purge feito na azion. O formato varia de acordo com o purge type, verifique a documentação referenciada acima para saber mais. Exemplos:
    - `wildcard`: (**Valor default**)
      - <www.yourdomain.com/>*
      - static.yourdomain.com/*/site.js
    - `url`:
      - static.yourdomain.com/include/site.js
      - static.yourdomain.com/include/site.css
    - `cachekey`:
      - <www.yourdomain.com/@@>

# **Renovate**
<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

O renovate é uma ferramenta de atualização de dependências. Ao rodar em seu projeto a ferramenta analisa arquivos de dependências (package.json, *.lock, requirements, etc) e busca por versões atualizadas, abrindo pull requests automáticos de acordo com algumas regras predefinidas.

[Documentação renovate](https://docs.renovatebot.com/)
[Regras padrão do grupo luizalabs](https://gitlab.luizalabs.com/luizalabs/renovate-config)

#### exemplo

```
include:
  - project: 'luizalabs/renovate-runner'
    ref: 'main'
    file: 'templates/renovate.gitlab-ci.yml'
```

Esse job fica configurado em [luizalabs/renovate-runner/templates/renovate.gitlab-ci.yml](https://gitlab.luizalabs.com/luizalabs/renovate-runner/-/blob/main/templates/renovate.gitlab-ci.yml?ref_type=heads).

Você pode customizar alguma propriedade estendendo o job e sobrescrevendo apenas as propriedades que você pretende mudar, por exemplo:

```
include:
  - project: 'luizalabs/renovate-runner'
    ref: 'main'
    file: 'templates/renovate.gitlab-ci.yml'

renovate:
  stage: quality-gate
  rules:
    - if: '$CI_PIPELINE_SOURCE == "schedule"'
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

## **renovate-comment**

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

O comando `renovate-comment` irá analisar os merge requests abertos pelo renovate, e comenta-los no merge request atual. Essa ação serve para incentivar os desenvolvedores a atualizarem as versões de pacotes, mantendo o projeto mais atualizado.

O comentário vai priorizar os MRs com sucesso, avaliando conforme as variáveis `CIKNIFE_RENOVATE_VALID_JOBS` e `CIKNIFE_RENOVATE_JOBS_VALID_STATUS`. Se não encontrar nenhum MR com sucesso, irá comentar a lista de MRs mesmo com falha.

#### exemplo comando

```sh
ci-knife renovate-comment
```

#### variáveis de ambiente configuraveis

Variável               | Descrição                                                                   | Obrigatoriedade
-----------------------|-----------------------------------------------------------------------------|------------------------------------------------------------------
`CIKNIFE_RENOVATE_VALID_JOBS` | Nomes dos jobs para o renovate avaliar o status e decidir se é um pipeline com sucesso ou falha. Se algum job não for encontrado não ira falhar, permitindo que use jobs em diferentes workflows de pipelines do gitlab.    | opcional, valor padrão: `test,sonar,sonar branch,lint`
`CIKNIFE_RENOVATE_JOBS_VALID_STATUS` | Status dos jobs para considerar sucesso (success ou manual)     | opcional, valor padrão `sucess`


# Commit semântico

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

É a prática de categorizar o commit de acordo com o tipo da mudança e qual o seu escopo.
Com essa prática fica mais fácil de entender a mudança realizada, gerar o CHANGELOG e a tag/versão automaticamente baseado no commit, a estrutura do commit ficará:

### Forma simples

```sh
git commit -m "type: subject"
```

#### Exemplos

```sh
git commit -m "feat: add new swipe breadcrumb"

git commit -m "fix: product variation not visible to user"
```

### Forma com escopo

```sh
git commit -m "type(scope): subject"
```

#### Exemplos

```sh
git commit -m "feat(core): add api integration with Crush"

git commit -m "feat(component): new price filter component"
```

> A forma com escopo é mais utilizada quando isso provoca alguma mudança para o CI, por exemplo um _mono repo_ que entrega multiplas aplicações.

### Breaking change

Ao declarar um commit com o texto `BREAKING CHANGE` no seu corpo ele irá gerar uma versão MAJOR

#### Exemplos

```sh
$ git commit -m "feat(core): add  X method

BREAKING CHANGE: deprecation of Y method"
```

### Tipos possíveis

Tipo       | CHANGELOG                  | Versão gerada   | Descrição
-----------|----------------------------|-----------------|-------------------------------------------------------------------------------------------
`refactor` | "Code Refactoring"         | Patch "x.x.x+1" | melhoria lógica/semantica em um código pré existente
`feat`     | "Features"                 | Minor "x.x+1.x" | Adição de nova funcionalidade
`fix`      | "Bug Fixes"                | Patch "x.x.x+1" | Correção de bug
`chore`    | "Improvements"             | Patch "x.x.x+1" | Uma pequena melhoria que não tem um impacto direto no negócio ou em algum dos outros tipos
`test`     | "Tests"                    | Patch "x.x.x+1" | Adição de testes de qualquer tipo
`perf`     | "Performance Improvements" | Patch "x.x.x+1" | Melhoria de performance
`build`    | "Build System"             | Patch "x.x.x+1" | Adição ou mudança nos scripts de build do projeto
`ci`       | "Continuous Integration"   | Patch "x.x.x+1" | Mudanças nos steps de CI
`docs`     | "Documentation"            | Patch "x.x.x+1" | Adição ou mudança de documentação do projeto
`style`    | "Styles"                   | Patch "x.x.x+1" | "Code style" Mudanças no estido do código sem afetá-lo: espaços, tabs, ponto e virgola
`revert`   | "Reverts"                  | Patch "x.x.x+1" | Desfazer algo no projeto via git ou não

> ### :warning: **Atenção!!!**
>
> Além do CHANGELOG a GMUD será gerada automaticamente baseada no CHANGELOG, por isso use, se necessário, em sua branch funcionalidades do git como "squash" e "amend" para que somente sejam listados commits que façam sentido.

# Freezing

Durante alguns períodos promocionais, por segurança, para manter o ambiente estável, nós não realizamos deploys, e a esse período damos o nome de "freezing".

Através de variáveis é possível definir se estamos em período de freezing:

- `FREEZING`: variável que pode ser utilizada em qualquer repositório, ou grupo de repositórios para indicar um "freezing" apenas na sua área;
- `CIKNIFE_FREEZING`: variável global no gitlab para freezing de toda a companhia, **não utilize essa variável em seus repositórios**, utilize apenas a variável anterior para indicar um freezing da sua área ou projeto.

Obs.: As variáveis não se sobrepõem, apenas se complementam, imagina que na Black Friday todo o Magalu está em Freezing, então a variável "global" será utilizada, já após a Black Friday apenas algumas áreas como a logistica continuam em Freezing, pois ainda tem um grande trabalho a fazer nas entregas, então a variável "local" é usada nestes grupos e repositórios.

> \* Lembrando que essa verificação só ocorrerá para o deploy em produção vindo de pipeline de TAG e com a verificação da gmud aprovada ativa (variável ``CHECK_GMUD_APPROVED`` true para o projeto ou o parâmetro `--check-gmud` informado junto ao comando de deploy).

## Como preencher a variável de freezing? <a name="preencher-freezing"></a>

Temos 2 formas de preencher essa variável:

- `booleano` (true|false): define apenas se está ou não em freezing;
- `intervalo de datas`: intervalo de datas separadas por `:`, exemplo: `2024-10-15:2024-12-01`, você ainda por usar o separador `|` para adicionar multiplos intervalos.

Obs.: detalhando o exemplo `2024-10-15:2024-12-01`, `2024-10-15` seria o primeiro dia do bloqueio, e `2024-12-01` seria o último dia de bloqueio, a partir do dia 02 já seria possível realizar novos deploys. (data inicial maior e igual, e data final menor e igual a data corrente)

## Como fazer deploy mesmo estando em freezing? <a name="deploy-freezing"></a>

Primeiro você deve alinhar a entrega com sua diretoria, uma vez alinhado, ao gerar a GMUD, você deve marcar a GMUD Aprovada com a label: `ciknife-bypass-freezing`, e o ci-knife não irá mais bloquear o seu deploy, lembrando que a adição de label fica no histórico do gitlab, então utilize com coerência.

# Deploy fora do horário permitido

Seguindo as boas práticas do labs, o horário recomendado para deploy é: Segunda à Quinta das 08 as 17horas.
Fora desse período, temos o risco de novos deploys trazerem erros que não serão identificados durante a noite ou finais de semana.

Portanto criamos essa trava para impedir deploys indevidos ou não acompanhados fora do horário esperado.

Temos como exceção times e projetos que precisam ser feitos o deploy fora do horário comercial, devido ao horário de pico das aplicações e o deploy pode ocasionar erros nos fluxos de venda. Neste cenário as variáveis podem ser sobrescritas no seu projeto.

Para fazer optin nesse fluxo, é necessário a configuração das variáveis:

VARIÁVEL       | Significado                  | Valor padrão
-----------|----------------------------|-----------------
`NO_DEPLOY_FRIDAYS` | Deploy não é permitido às sexta-feiras       | true
`NO_DEPLOY_WEEKENDS` | Deploy não é permitido aos finais de semana (sáb e dom)        | true
`NO_DEPLOY_OUT_WORKING_HOURS` | Deploy não é permitido fora do horário comercial        | true
`DEPLOY_WORKING_HOURS` | Horário comercial definido para validação, usado apenas se a env NO_DEPLOY_OUT_WORKING_HOURS for verdadeira. O deploy será valido das 08:00 às 17:59.         | 08-17*

\*O deploy será valido das 08:00 às 17:59.
> \* Lembrando que essa verificação só ocorrerá para o deploy em produção vindo de pipeline de TAG e com a verificação da gmud aprovada ativa (variável ``CHECK_GMUD_APPROVED`` true para o projeto ou o parâmetro `--check-gmud` informado junto ao comando de deploy).

## Como fazer deploy fora do horário permitido?

Para casos de urgência no deploy, ou deploys alinhados com a sua liderança fora do horário, ao gerar a GMUD e após aprovada, você deve marcar a GMUD com uma label de ciknife (exemplos a seguir), e o ci-knife não irá mais bloquear o seu deploy, lembrando que a adição de label fica no histórico do gitlab, então utilize com coerência.

Motivo       | Label necessária para deploy
-------------|------------------------------
Deploy na sexta feira | `ciknife-bypass-friday`
Deploy no final de semana | `ciknife-bypass-weekend`
Deploy fora do horário comercial | `ciknife-bypass-working-hours`

# Templates

Os templates são basicamente includes para o arquivo `.gitlab-ci.yaml` que adicionam jobs de CI em seu projeto. Os includes disponíveis são:

## Reports (Sonar e Fortify) # Depreciado

> Fortify sast _DEPRECIADO_, utilizar o report-security.yaml documentado no [Reports Security](#reports-security).

```yaml
include:
  - project: 'luizalabs/ci-knife'
    ref: master
    file: 'templates/report-sast.yaml'
```

**Observação:** para o correto funcionamento do `sonar` e `fortify` é necessário adicionar os arquivos `sonar-project.properties` e `sast.properties` no projeto.

### Fortify

Para o fortify, é necessário adicionar a variavel `FORTIFY_SOURCE_ANALYZER`, que deve conter a linha de comando do `/opt/fortify/bin/sourceanalyzer`

**Exemplo:**

```
FORTIFY_SOURCE_ANALYZER: -b $CI_DEFAULT_BRANCH -python-version 3 $CI_PROJECT_NAME/ -exclude "**/tests/*,**/settings/*.py"
```

## Reports Security

```yaml
include:
  - project: 'luizalabs/ci-knife'
    ref: master
    file: 'templates/report-security.yaml'
```

**Observação:** para o correto funcionamento do `security scanner` é necessário adicionar o arquivo `dependency.yaml` no projeto. Veja mais detalhes na [documentação de segurança](https://magazine.atlassian.net/wiki/spaces/SDLABS/pages/3201695953/Pipeline+De+Seguran+a+-+Implementa+o#1--Cria%C3%A7%C3%A3o-do-arquivo-dependency.yaml).

## Deploy ArgoCD

```yaml
  - project: 'luizalabs/ci-knife'
    ref: master
    file: 'templates/deploy-argocd.yaml'
```

É necessários adicionar as `variables` no inicio do arquivo `.gitlab-ci.yaml`

```yaml
  ARGOCD_NAMESPACE: Caminho do repositório onde está localizado as configurações do ArgoCD
  APPS_NAME: Nome das aplicações que vão ser deployados
```

Maiores detalhes, sobre a configuração do ArgoCD, [clique aqui](#argocd-deploy--argocd-rollback)

### Ambiente de Integração

Adicionar o trecho de código abaixo no `.gitlab-ci.yaml` para incluir o step de deploy para o ambiente de integração. Necessário que exista a pasta `integration` no projeto de IaC do ArgoCD.

```yaml
  - project: 'luizalabs/ci-knife'
    ref: master
    file: 'templates/deploy-argocd-integration.yaml'
```

## API Catalog

Necessário definir as váriaveis para poder utilizar o template.

```
  DEPENDENCY_PATH: Caminho do dependency.yaml. *Obrigatório
  API_LIFECYCLE: Lifecycle da API no Backstage. *Obrigatório
  API_GATEWAY_ID: Id do gateway utilizado pela API.
  API_ENV: Ambiente da API.
  OPENAPI_PATH: Caminho do OpenAPI.
  KONG_PLUGINS_PATH: Caminho do Kong Plugins.
```

Exemplo de uso do template de Catalogo de API:

```yaml
include:
  - project: 'luizalabs/ci-knife'
    ref: master
    file: 'templates/catalog-api.yaml'

stages:
  - catalog

catalog api:
  extends: .catalog-api
  before_script:
    - export DEPENDENCY_PATH="$PWD/dependency.yaml" API_LIFECYCLE="Experimental" API_GATEWAY_ID="123" API_ENV="dev" OPENAPI_PATH="$PWD/openapi.json" KONG_PLUGINS_PATH="$PWD/kong_plugins.yaml"
```

Maiores detalhes do API Catalog [clique aqui](#api-catalog)

## Deploy Kong

Necessário configurar as variáveis de ambiente abaixo:

```
  GATEWAY_ENVIRONMENT: Ambiente que a configuração esta relacionada. *Obrigatório
  GATEWAY_ID: Identificador do gateway. *Obrigatório
  API_NAME: Nome da aplicação que será enviada para o Kong. *Obrigatório
  BACKEND_NAMESPACE: Namespace onde a aplicação que será enviada para o Kong está rodando. *Obrigatório
  BACKEND_NAME: Nome da aplicação dentro do kubernetets que será enviada para o Kong *Obrigatório
  GATEWAY_CONFIG: Localização de um ou mais arquivos de configuração da API, contendo plugins e servers. Caso não seja passado, vai procurar o arquivo na raiz do projeto.
  GATEWAY_OPENAPI_FILE: Localização do arquivo OpenAPI, podendo ser no formato yaml ou json. Caso não seja passado, vai procurar o arquivo na raiz do projeto.
  API_CONTEXT: Nome a ser utilizado como contexto, o valor será adicionado como prefixo em todas as rotas.
  API_PRESERVE_HOST: Flag para o Kong preservar o domínio recebido e repassar ao downstream. Valor padrão: false.
```

Exemplo de como chamar o template dentro do gitci:

```yaml
include:
  - project: 'luizalabs/ci-knife'
    ref: master
    file: 'templates/deploy-kong.yaml'

stages:
  - kong release

variables:
  GATEWAY_CONFIG: gateway-config.yaml
  GATEWAY_OPENAPI_FILE: openapi.yaml
  BACKEND_NAME: testing
  BACKEND_NAMESPACE: testing
  API_NAME: testing
  GATEWAY_ID: testing

deploy kong sandbox:
  variables:
    GATEWAY_ENVIRONMENT: homolog

deploy kong production:
  variables:
    GATEWAY_ENVIRONMENT: prod
```

## Validação Segurança em MRs  <a name="template-seguranca-mr"></a>

O template de segurança em MRs irá validar novos secret leaks nos commits levados de um MR para branch destino.

Adicione no seu arquivo de ci o include a seguir:

```yaml
include:
  - project: 'luizalabs/ci-knife'
    ref: master
    file: 'templates/security-mr.yaml'
```

Ou caso seu projeto esteja no grupo `cicd` ou `luizalabs` do gitlab, você pode usar as variáveis:

```yaml
include:
  - project: $CIKNIFE_TEMPLATE_PROJECT
    ref: $CIKNIFE_TEMPLATE_VERSION
    file: $CIKNIFE_TEMPLATE_SECURITY_FILE
```

## Validação projetos CICD  <a name="template-projetos-cicd"></a>

O template de cicd fará validações pertinentes aos arquivos de configs utilizados pelas nossas ferramentas de gitOps (argocd, etc).

Hoje possui validações de MR para commitlint, MR aprovado se alterado arquivos de produção, e secret leaks novos em merge requests.

Adicione no seu arquivo de ci o include a seguir:

```yaml
include:
  - project: 'luizalabs/ci-knife'
    ref: 'master'
    file: 'templates/validate-cicd.yaml'
```

Ou caso seu projeto esteja no grupo cicd do gitlab, você pode usar as variáveis:

```yaml
include:
  - project: $CIKNIFE_TEMPLATE_PROJECT
    ref: $CIKNIFE_TEMPLATE_VERSION
    file: $CIKNIFE_TEMPLATE_CICD_FILE
```

# Dicas para implantação em projetos

<div style="margin-top: -20px; text-align: right"><a href="#ci-knife">voltar ao topo</a></div>

## Git

- Você pode usar o usário padrão do git <ci-knife@luizalabs.com>, basta adicionar ele como `Maintainer` do projeto (ou como desenvolvedor caso os desenvolvedores possam commitar na master/criar tags etc).

- Ou caso queira, crie um usuário genérico para o time (<squad.nome@luizalabs.com>);
  - Adicione-o como `Maintainer` do projeto;
  - Utilize-o para a criação de `access token` com acesso a API do Gitlab;
- :warning: Caso o projeto exista e tenha tags garanta que a última tag é uma `tag anotada` (ex.: `git tag -a v1.0.0`), e que foi criada a partir da _master_ e possui o formato `vX.X.X`, para validar:
  - Na branch master: `git checkout master`
  - Execute: `git log`
  - A saida do comando deve conter ao lado do _hash_ do commit a versão da tag (caso contrário deverá exclui-la e cria-la novamente)
  - Exemplo da saída do comando `git log`:

      ```sh
      commit 07fece1184bb00274c5daa641ed7561b0b132ce7 (HEAD -> master, tag: v1.2.1, origin/master, origin/HEAD)
      Author: Bruno Freitas <bruno.freitas@luizalabs.com>
      Date:   Thu Sep 5 16:12:14 2019 -0300
          chore(release): v.1.2.1
      ```

## Projetos com package.json

- Para projetos que contenham o arquivo package.json, não esqueça de preencher a propriedade "repository", ex.:

  ```json
  {
    "name": "meu-projeto",
    "version": "0.0.0",
    "repository": {
      "type": "git",
      "url": "git@gitlab.luizalabs.com:luizalabs/meu-projeto.git"
    },
    ...
  ```

- Caso seja um projeto novo deixe a versão como "0.0.0" para que o `semantic version` possa alterá-la para versão correta;

- é recomendado o uso dos pacotes `husky + commitlint` local para pré validar as mensagens de commit, ex.:

  _package.json_

    ```json
    ...
    "devDependencies": {
        "@commitlint/cli": "^8.1.0",
        "@commitlint/config-conventional": "^8.1.0",
        "husky": "^3.0.0",
        ...
    },
    "husky": {
        "hooks": {
            "commit-msg": "commitlint -g ./commitlint.config.js -E HUSKY_GIT_PARAMS"
        }
    }
    ```

  _commitlint.config.js_

    ```js
    module.exports = { extends: ['@commitlint/config-conventional'] };
    ```

- Caso vá utilizar o sonar, é uma boa prática utilizar o "eslint-plugin-sonarjs" para conseguir validar já localmente alguns problemas que serão alertados pela ferramenta;

## CHANGELOG

- :warning: Caso esteja iniciando um projeto não é necessário criar um arquivo de CHANGELOG
- :warning: Caso esteja adicionando em um projeto que já possui um CHANGELOG é importante que ao menos o cabeçalho do último registro siga o padrão `[versao](link ou vazio)` para que ele possa continuar preenchendo, exemplo extraído do projeto `Explorer`:

  **exemplo: antes do ci-knife**

  ```md
  # Changelog

  ## [2.6.14][] - 2019-07-18

  ### Changed
  - Update redirect map
  ```

  **exemplo: ajustando compatibilidade com ci-knife**

  ```md
  # Changelog

  ## [2.6.14]() - 2019-07-18

  ### Changed
  - Update redirect map
  ```

  **exemplo: primeiro release com ci-knife**

  ```md
  # Changelog

  ## [2.6.15](https://gitlab.luizalabs.com/luizalabs/explorer/compare/v2.6.14...v2.6.15) (2019-08-02)

  ### Continuous Integration

  * add deploy steps ([c7185d8](https://gitlab.luizalabs.com/luizalabs/explorer/commit/c7185d8))
  * add gmud step ([ce58a1b](https://gitlab.luizalabs.com/luizalabs/explorer/commit/ce58a1b))
  * add rollback step ([2414934](https://gitlab.luizalabs.com/luizalabs/explorer/commit/2414934))
  * add slack integration ([7a44a59](https://gitlab.luizalabs.com/luizalabs/explorer/commit/7a44a59))


  ### Documentation

  * update docs after new CI flow ([60dc29a](https://gitlab.luizalabs.com/luizalabs/explorer/commit/60dc29a))

  ## [2.6.14]() - 2019-07-18

  ### Changed
  - Update redirect map
  ```

  ## Usando variáveis de ambiente

  Para configurar algumas variáveis de ambiente siga os passos abaixo:

  ### GCHAT

  Para configurar o Google Chat como provedor de mensagem utilize a variável de ambiente `MSG_PROVIDER=gchat`.

  > Ob.: uma variável CIKNIFE_MSG_PROVIDER pode ser setada no mais alto nível do gitlab para servir como padrão, porém cada repo pode usar a variável mencionada anteriormente conforme preferir, por exemplo durante uma migração).

  Para setar as variaveis de webhooks por canal `GCHAT_GMUD_WEBHOOK` e `GCHAT_DEPLOY_WEBHOOK` no canal escolhido:
  - Clique na seta ao lado do nome do canal
  - Vá para "Apps e integrações"
  - E "+ Adicionar Webhook"
  - Adicione o nome "ci-knife" e se desejar a sua imagem: "<https://wx.mlcdn.com.br/ci-knife/ci-knife.jpeg>"

  Para marcar pessoas durante o deploy do time pode usar a variável `GCHAT_TEAM_ID`, onde você pode por o IDs de quantos usuários desejar, separados por `||`. Esse Id pode ser obtido inspecionando no navegador uma marcação de usuário e pegando do html o campo: `data-user-id`.

  ### SLACK

  Para configurar o Slack como provedor de mensagem utilize a variável de ambiente `MSG_PROVIDER=slack`.

  > Ob.: uma variável CIKNIFE_MSG_PROVIDER pode ser setada no mais alto nível do gitlab para servir como padrão, porém cada repo pode usar a variável mencionada anteriormente conforme preferir, por exemplo durante uma migração).

  Obtenha as informações dos ids com base nas urls do canal/grupo

  | item               | url                                                                    |
  |--------------------|------------------------------------------------------------------------|
  | `producao-deploys` | <https://app.slack.com/client/T024FR42U/C03PHMGKTB8>                     |
  | `cd-navegaçao`     | <https://app.slack.com/client/T024FR42U/G5ASAMRA9>                       |
  | `@squad-navegacao` | <https://app.slack.com/client/T024FR42U/G5ASAMRA9/user_groups/S5PF8627P> |

  > Para pegar o team id, basta clicar no `@nome-da-squad` em uma msg qlq do slack

  | var                    | value      |
  |------------------------|------------|
  | `SLACK_DEPLOY_CHANNEL` | C03PHMGKTB8|
  | `SLACK_GMUD_CHANNEL`   | G5ASAMRA9  |
  | `SLACK_TEAM_ID`        | S5PF8627P  |

# Colaborando com o projeto

## Dúvidas, problemas, sugestões

O `ci-knife` é um projeto mantido por todo o LuizaLabs, para interagir com os demais usuários do projeto sobre dúvidas, problemas, idéias ou até MRs (Por que não? Bora colaborar!)
existe o canal no slack: [#ci-knife-contributors](https://luizalabs.slack.com/archives/C01D14K85JN).

## Merge Request

Caso queira colaborar com o projeto através de uma melhoria, correção ou feature (sobre feature puxar uma uma discussão no canal pra entender se a feature faz sentido estar no `ci-knife`) você pode simplesmente abrir um `merge request`.

Uma vez aberto o `MR` você deve envia-lo no canal do slack, e aguarda 2 aprovações :thumbsup: . (Sugestão: peça que pessoas ativas no repositório e no canal revisem seu MR).

Aprovado o `MR` solicite a um `Tech Lead` (se o time não tiver um, peça ajuda no canal) que faça o deploy da nova versão. (será abordado nos tópicos seguintes).

### Gerando imagem de teste

Após abrir o `Merge Request`. é possível usar a pipeline associada ao `MR` para gerar uma versão de teste do `ci-knife`. Exemplo:

Botão na pipeline do MR:

![pipelne](docs/ci-knife-test-build-button.png)

Resultado da pipeline:

![job-result](docs/ci-knife-test-pipeline.png)

Agora é só você usar esse endereço como versão do ci-knife no seu repo/projeto onde irá testar, exemplo:

```
deploy sandbox:
    tags:
        - global-docker-tls
    services:
        - docker:26-dind
    image: gcr.io/magalu-cicd/ci-knife:e6736680
    stage: sandbox
    script: ci-knife argocd-deploy --no-msg --path sandbox --docker-image
    only:
        - merge_requests
    when: manual
```

## Gerando uma nova versão do ci-knife (deploy)

É importante que esse processo seja realizado por um `Tech Leader`, pois uma parte do processo depende de acessos deste, como atualizar a versão nas variáveis globais do Gitlab.

Então vamos aos passos:

### Gerando uma versão

Esse passo começa fazendo o `merge` do nosso MR.

Uma vez feito o merge na branch principal, deve-se usar o pipeline desta para a criação da tag, através do job `create release`:

![create-release](docs/ci-knife-create-release.png)

Assim será criada a `tag` com a nova versão e no pipeline desta iremos gerar a imagem da tag com o `build tag image`:

![tag-image](docs/ci-knife-tag-image.png)

![tag-job](docs/ci-knife-job-tag.png)

### Disponibilizando e comunicando

Depois de criar a versão, para disponibilizarmos automaticamente para todos usuários, devemos atualizar a variável de ambiente global `CIKNIFE_IMAGE` no [gitlab](https://gitlab.luizalabs.com/groups/luizalabs/-/settings/ci_cd).

![update-gitlab](docs/update-gitlab.png)

Atualizada a variável, os jobs já estarão usando a nova versão.
Agora falta comunicar os usuários,
atualizando a descrição do canal e adicionando um breve resumo do que está entrando com esta versão:

![slack-set-description](docs/slack-set-description.png)
