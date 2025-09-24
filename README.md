# sde-workspace

[PT | EN](./README.en.md)

Instalador e templates para um workflow de desenvolvimento com agentes (Backstage/TypeScript) e GitHub Copilot.

## Instalação Rápida (cURL)

Use o instalador da branch principal (main). Durante a execução, escolha idioma e versão.

```bash
curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/main/install.sh | bash
```

## O que o instalador faz

- Solicita: idioma (`pt-br` ou `en-us`) e versão (`default` ou `github-copilot`).
- Clona a branch correspondente do repositório para obter os artefatos.
- Cria na pasta atual:
  - `.sde_workspace` com toda a estrutura do projeto.
  - `.github/chatmodes` apenas se ainda não existir.

## Observações

- Se `.github/chatmodes` já existir, o instalador não sobrescreve.
- Se `.sde_workspace` já existir, o instalador pergunta se deseja substituir.
- Variáveis de ambiente opcionais:
  - `REPO_URL` para apontar outro fork do repositório.
