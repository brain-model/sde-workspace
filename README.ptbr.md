# SDE Workspace

**[ [EN](README.md) | [PT](README.ptbr.md) ]**

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

## Visão Geral

O SDE Workspace é um sistema autônomo multi-agente para desenvolvimento de software. Ele fornece um ambiente estruturado com agentes de IA especializados para transformar requisitos de negócio em código de alta qualidade através de um ciclo de desenvolvimento automatizado.

## Instalação Rápida

Instale o SDE Workspace com um único comando:

```bash
curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/0.1.0/boot.sh | bash
```

Ou usando wget:

```bash
wget -qO- https://raw.githubusercontent.com/brain-model/sde-workspace/0.1.0/boot.sh | bash
```

### Opções de Instalação

O instalador apresentará 4 opções de configuração:

1. **default-ptbr** - Português Brasil (Versão padrão)
2. **default-enus** - Inglês americano (Versão padrão)  
3. **copilot-ptbr** - Português Brasil (Versão GitHub Copilot)
4. **copilot-enus** - Inglês americano (Versão GitHub Copilot)

**Qual a diferença?**

- **Versões padrão**: Instalam apenas a estrutura central `.sde_workspace` com agentes, guias e templates
- **Versões Copilot**: Incluem chatmodes adicionais do GitHub Copilot em `.github/chatmodes/` para assistência de IA aprimorada

## O que é Instalado

Após a instalação, você terá:

```text
.sde_workspace/
├── system/
│   ├── agents/         # Definições dos agentes de IA
│   ├── guides/         # Guias de desenvolvimento
│   └── templates/      # Templates de documentos
└── .github/
    └── copilot-instructions.md  # Configuração do Copilot
```

Para versões Copilot, você também terá:

```text
.github/
└── chatmodes/
    ├── architect.chatmode.md
    ├── developer.chatmode.md
    ├── qa.chatmode.md
    └── reviewer.chatmode.md
```

## Requisitos do Sistema

- Git
- curl ou wget
- Conexão com a internet

O instalador instalará automaticamente dependências ausentes em sistemas suportados (Ubuntu/Debian, RHEL/CentOS, macOS).

## Instalação Manual

Se preferir instalar manualmente:

```bash
# Clone o repositório
git clone https://github.com/brain-model/sde-workspace.git
cd sde-workspace

# Execute o instalador
./install.sh
```

## Contribuindo

Nós damos boas-vindas às contribuições da comunidade! Leia nosso [Guia de Contribuição](CONTRIBUTING.ptbr.md) para começar:

- **Fluxo de Desenvolvimento**: Setup, padrões de código e procedimentos de teste
- **Estratégia de Branches**: Como gerenciamos diferentes branches de idioma e funcionalidades
- **Commits Semânticos**: Nossas convenções de mensagens de commit para versionamento automatizado
- **Processo de Code Review**: Diretrizes para submissão e revisão de pull requests

## Changelog

Veja [CHANGELOG.ptbr.md](CHANGELOG.ptbr.md) para um histórico detalhado de mudanças, novas funcionalidades e decisões arquiteturais.

## Suporte

Para problemas e dúvidas:

- Abra uma issue no [GitHub Issues](https://github.com/brain-model/sde-workspace/issues)
- Consulte nossa documentação no diretório `.sde_workspace/system/guides/`
- Revise o [Guia de Contribuição](CONTRIBUTING.ptbr.md) para questões de desenvolvimento

## Licença

Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.
