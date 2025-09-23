# --- Makefile for Development Agent System ---

# Define targets that don't represent files.
.PHONY: install clean help

# Default target, executed when 'make' is called without arguments.
help:
	@echo "Available commands:"
	@echo "  make install   - Creates the .sde_workspace directory structure."
	@echo "  make clean     - Removes the .sde_workspace directory structure."
	@echo "  make help      - Shows this help message."

# Target to create the directory structure.
install:
	@echo ">> Creating .sde_workspace directory structure..."
	@mkdir -p .sde_workspace/backlog
	@mkdir -p .sde_workspace/specs
	@mkdir -p .sde_workspace/workspaces
	@mkdir -p .sde_workspace/archive
	@mkdir -p .sde_workspace/system/agents
	@mkdir -p .sde_workspace/system/guides
	@mkdir -p .sde_workspace/system/templates
	@echo ">> Structure created successfully."

# ---------------------------------------------
# Setup para GitHub Copilot e VSCode Chat Modes
# ---------------------------------------------
.PHONY: setup-copilot

setup-copilot:
	@echo ">> Criando diretórios de configuração para o GitHub Copilot..."
	@mkdir -p .github
	@mkdir -p .github/chatmodes
	@rm -rf .vscode/chatmodes || true

	@echo ">> Gerando .github/copilot-instructions.md..."
	@printf "%b" "# Diretrizes para o GitHub Copilot\n\nEste projeto utiliza um workflow de agentes de IA para desenvolvimento de software, com foco em Backstage e TypeScript.\n\n**Regras Gerais:**\n- Todo o código deve ser escrito em TypeScript e seguir as melhores práticas de Clean Code.\n- As mensagens de commit devem seguir estritamente as regras definidas em '.sde_workspace/system/guides/semantic_commit_guide.md'.\n- A interação com o sistema Backstage deve utilizar os serviços principais como DatabaseService e SchedulerService sempre que possível.\n" > .github/copilot-instructions.md

	@echo ">> Gerando chatmodes para os agentes em .github/chatmodes/..."
	@printf "%b" "---\ntitle: Agente Arquiteto\n---\n# Papel e Objetivo\nVocê é o Agente Arquiteto. Suas instruções estão em '.sde_workspace/system/agents/architect.md'. Assuma essa persona e processo para a sessão. Comece pedindo o TASK-ID do backlog.\n" > .github/chatmodes/architect.chatmode.md

	@printf "%b" "---\ntitle: Agente Desenvolvedor\n---\n# Papel e Objetivo\nVocê é o Agente Desenvolvedor. Suas instruções estão em '.sde_workspace/system/agents/developer.md'. Assuma essa persona e processo para a sessão. Comece pedindo o workspace da tarefa.\n" > .github/chatmodes/developer.chatmode.md

	@printf "%b" "---\ntitle: Agente de QA\n---\n# Papel e Objetivo\nVocê é o Agente de QA. Suas instruções estão em '.sde_workspace/system/agents/qa.md'. Assuma essa persona e processo para a sessão. Comece pedindo o workspace da tarefa para iniciar a análise.\n" > .github/chatmodes/qa.chatmode.md

	@printf "%b" "---\ntitle: Agente Revisor\n---\n# Papel e Objetivo\nVocê é o Agente Revisor. Suas instruções estão em '.sde_workspace/system/agents/reviewer.md'. Assuma essa persona e processo para a sessão. Comece pedindo a URL do Merge Request para a revisão.\n" > .github/chatmodes/reviewer.chatmode.md

	@echo ">> Chatmodes criados com sucesso."

# Target to clean the created structure.
clean:
	@echo ">> Removing .sde_workspace structure..."
	@rm -rf .sde_workspace
	@echo ">> Cleanup completed."