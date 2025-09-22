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

# Target to clean the created structure.
clean:
	@echo ">> Removing .sde_workspace structure..."
	@rm -rf .sde_workspace
	@echo ">> Cleanup completed."