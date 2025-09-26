# Contribuindo para o SDE Workspace

Obrigado pelo interesse em contribuir para o projeto SDE Workspace! Este guia ajudara voce a comecar.

## Comecando

1. **Faca um fork do repositorio** e clone localmente
2. **Instale o workspace** usando o instalador:

   ```bash
   curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/master/boot.sh | bash
   ```

3. **Escolha sua configuracao** entre as 4 opcoes disponiveis:
   - `default-ptbr` - Portugues Brasil (versao padrao)
   - `default-enus` - Ingles EUA (versao padrao)
   - `copilot-ptbr` - Portugues Brasil (versao GitHub Copilot)
   - `copilot-enus` - Ingles EUA (versao GitHub Copilot)

## Fluxo de Desenvolvimento

### Estrategia de Branches

- `master` - Branch principal com a versao estavel mais recente
- `default-ptbr` - Versao padrao em Portugues Brasil
- `default-enus` - Versao padrao em Ingles EUA
- `copilot-ptbr` - Portugues Brasil com integracao GitHub Copilot
- `copilot-enus` - Ingles EUA com integracao GitHub Copilot

### Fazendo Alteracoes

1. **Crie um branch de feature** a partir do branch base apropriado
2. **Siga as convencoes de commit semantico** (veja `.sde_workspace/system/guides/guia_commit_semantico.md`)
3. **Teste suas alteracoes** em todas as configuracoes de branch relevantes
4. **Atualize a documentacao** se necessario
5. **Envie um pull request** com descricao clara

### Formato da Mensagem de Commit

Usamos mensagens de commit semanticas. Formato: `<tipo>[<escopo>]: <descricao>`

Exemplos:

- `feat: adiciona novo fluxo de agente`
- `fix(installer): resolve problema de deteccao de branch`
- `docs: atualiza guia de instalacao`

Veja o guia completo em `.sde_workspace/system/guides/guia_commit_semantico.md`

## Diretrizes de Codigo

### Estrutura de Arquivos

- **Mantenha consistencia** entre todos os branches de idioma
- **Use templates** de `.sde_workspace/system/templates/`
- **Siga convencoes de nomenclatura** sem acentos para arquivos em portugues
- **Atualize manifestos** ao adicionar conteudo da base de conhecimento

### Sistema de Agentes

- **Arquivos de agentes** devem ser consistentes entre versoes de idioma
- **Prompts** devem ser traduzidos mantendo precisao tecnica
- **Logica de workflow** deve permanecer identica em todas as versoes

## Documentacao

### Suporte Multi-idioma

- **Ingles (EN-US)**: Padrao para contribuidores internacionais
- **Portugues (PT-BR)**: Versao localizada para usuarios brasileiros
- **Sem acentos**: Arquivos em portugues usam nomenclatura simplificada sem acentos

### Base de Conhecimento

- Use frontmatter padronizado para todos os arquivos de conhecimento
- Mantenha o schema de 7 campos: id, title, category, created, updated, source, tags
- Siga a estrutura organizada em `.sde_workspace/knowledge/`

## Testes

1. **Teste de instalacao**: Verifique se o instalador funciona em diferentes configuracoes
2. **Validacao cross-branch**: Garanta que alteracoes funcionam em todos os 4 branches
3. **Teste de fluxo de agentes**: Valide interacoes e handoffs de agentes
4. **Atualizacoes de documentacao**: Verifique se todos os READMEs e guias estao atuais

## Reportando Issues

Ao reportar problemas, inclua:

- **Configuracao usada** (qual dos 4 branches)
- **Passos para reproduzir** o problema
- **Comportamento esperado vs real**
- **Detalhes do ambiente** (OS, shell, versao Git)

## Comunidade

- **Seja respeitoso** e colaborativo
- **Siga o codigo de conduta**
- **Ajude outros** em discussoes e revisoes
- **Compartilhe conhecimento** e melhore a documentacao

## Duvidas?

- Verifique a **documentacao** existente em `.sde_workspace/`
- Revise **issues fechadas** para questoes similares
- Abra uma **nova issue** com o label `question`
- Participe de **discussoes** no repositorio

Obrigado por contribuir para o SDE Workspace!
