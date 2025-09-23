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
# Setup for GitHub Copilot and VS Code Chat Modes
# ---------------------------------------------
.PHONY: setup-copilot

setup-copilot:
	@echo ">> Creating configuration directories for GitHub Copilot..."
	@mkdir -p .github
	@mkdir -p .github/chatmodes
	@rm -rf .vscode/chatmodes || true

	@echo ">> Generating .github/copilot-instructions.md..."
	@printf "%b" "# GitHub Copilot Guidelines\n\nThis project uses an AI agents workflow for software development, focused on Backstage and TypeScript.\n\nGeneral Rules:\n- All code must be written in TypeScript and follow Clean Code best practices.\n- Commit messages must strictly follow the rules in \`.sde_workspace/system/guides/semantic_commit_guide.md\`.\n- Interactions with Backstage should use core services such as \`DatabaseService\` and \`SchedulerService\` whenever possible.\n" > .github/copilot-instructions.md

	@echo ">> Generating chat modes in .github/chatmodes/..."
	@printf "%b" "---\ntitle: Architect Agent\n---\n# Role and Goal\nYou are the Architect Agent. Your instructions are in '.sde_workspace/system/agents/architect.md'. Assume this persona and process for the session. Start by asking for the backlog TASK-ID.\n" > .github/chatmodes/architect.chatmode.md

	@printf "%b" "---\ntitle: Developer Agent\n---\n# Role and Goal\nYou are the Developer Agent. Your instructions are in '.sde_workspace/system/agents/developer.md'. Assume this persona and process for the session. Start by asking for the task workspace.\n" > .github/chatmodes/developer.chatmode.md

	@printf "%b" "---\ntitle: QA Agent\n---\n# Role and Goal\nYou are the QA Agent. Your instructions are in '.sde_workspace/system/agents/qa.md'. Assume this persona and process for the session. Start by asking for the task workspace to begin the analysis.\n" > .github/chatmodes/qa.chatmode.md

	@printf "%b" "---\ntitle: Reviewer Agent\n---\n# Role and Goal\nYou are the Reviewer Agent. Your instructions are in '.sde_workspace/system/agents/reviewer.md'. Assume this persona and process for the session. Start by asking for the Merge Request URL to review.\n" > .github/chatmodes/reviewer.chatmode.md

	@echo ">> Chat modes generated successfully."

# Target to clean the created structure.
clean:
	@echo ">> Removing .sde_workspace structure..."
	@rm -rf .sde_workspace
	@echo ">> Cleanup completed."