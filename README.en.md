# sde-workspace

[EN | PT](./README.md)

Installer and templates for a developer workflow with AI agents (Backstage/TypeScript) and GitHub Copilot.

## Quick Install (cURL)

Use the installer from the main branch. During execution, select language and version.

```bash
curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/main/install.sh | bash
```

## What the installer does

- Prompts for language (`pt-br` or `en-us`) and version (`default` or `github-copilot`).
- Clones the corresponding branch to fetch artifacts.
- Creates in the current folder:
  - `.sde_workspace` with the full project structure.
  - `.github/chatmodes` only if it does not exist yet.

## Notes

- If `.github/chatmodes` already exists, the installer will not overwrite it.
- If `.sde_workspace` already exists, you will be asked whether to replace it.
- Optional environment variables:
  - `REPO_URL` to point to another repository fork.
