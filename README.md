# Software Development Environment (SDE) Workspace

**[ [EN](README.md) | [PT](README.ptbr.md) ]**

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

## Overview

SDE Workspace is an autonomous multi-agent system for software development. It provides a structured environment with specialized AI agents to transform business requirements into high-quality code through an automated development lifecycle.

## Quick Installation

Install SDE Workspace with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/0.1.0/boot.sh | bash
```

Or using wget:

```bash
wget -qO- https://raw.githubusercontent.com/brain-model/sde-workspace/0.1.0/boot.sh | bash
```

### Installation Options

The installer will present you with 4 configuration options:

1. **default-ptbr** - Portuguese Brazil (Default version)
2. **default-enus** - English US (Default version)  
3. **copilot-ptbr** - Portuguese Brazil (GitHub Copilot version)
4. **copilot-enus** - English US (GitHub Copilot version)

**What's the difference?**

- **Default versions**: Install only the core `.sde_workspace` structure with agents, guides, and templates
- **Copilot versions**: Include additional GitHub Copilot chatmodes in `.github/chatmodes/` for enhanced AI assistance

## What Gets Installed

After installation, you'll have:

```bash
.sde_workspace/
├── system/                 # Core normative system
│   ├── specs/             # Specifications with lifecycle management
│   │   ├── draft/         # Draft specifications
│   │   ├── in-review/     # Specifications under review
│   │   ├── active/        # Active/approved specifications
│   │   ├── deprecated/    # Deprecated specifications
│   │   ├── archived/      # Archived specifications
│   │   └── manifest.json  # Auto-generated specs index
│   ├── agents/            # AI agent definitions and prompts
│   ├── guides/            # Development guides and workflows
│   ├── templates/         # Document and artifact templates
│   ├── backlog/           # Structured work items and tasks
│   └── workspaces/        # Ephemeral guided work areas
├── knowledge/             # Classified knowledge base
│   ├── external/          # External sources and documentation
│   │   ├── sources/       # Raw and processed external materials
│   │   ├── standards/     # Market standards and summaries
│   │   ├── vendor-docs/   # Vendor documentation curation
│   │   ├── research/      # Research papers and benchmarks
│   │   └── transcripts/   # Meeting transcripts and events
│   ├── internal/          # Institutional knowledge
│   │   ├── concepts/      # Domain glossary and definitions
│   │   ├── runbooks/      # Operational procedures
│   │   ├── references/    # Lists, catalogs, internal indices
│   │   ├── notes/         # Raw and consolidated notes
│   │   ├── decisions-context/ # Decision contexts and narratives
│   │   ├── integracao/    # Integration flows and mappings
│   │   ├── templates/     # Internal artifact templates
│   │   └── onboarding/    # Entry guides and learning paths
│   └── manifest.json      # Auto-generated knowledge index
└── .github/
    └── copilot-instructions.md  # Copilot configuration
```

For Copilot versions, you'll also get:

```bash
.github/
└── chatmodes/             # Specialized AI agent modes
    ├── architect.chatmode.md   # Architecture-focused agent
    ├── developer.chatmode.md   # Development-focused agent
    ├── orchestrator.chatmode.md # Orchestration agent
    ├── pm.chatmode.md          # Product management agent
    ├── qa.chatmode.md          # Quality assurance agent
    └── reviewer.chatmode.md    # Code review agent
```

## Key Features

### 🏗️ **Structured Development Environment**

- **Specification Lifecycle**: Formal workflow for specs (draft → in-review → active → deprecated → archived)
- **Multi-Agent System**: Specialized AI agents for different development roles
- **Knowledge Management**: Organized internal and external knowledge repositories
- **Template-Driven**: Standardized templates for consistent documentation

### 🤖 **AI-Powered Workflow**

- **GitHub Copilot Integration**: Enhanced with specialized chatmodes for different development contexts
- **Intelligent Agents**: Architect, Developer, QA, Reviewer, Product Manager, and Orchestrator agents
- **Automated Indexing**: Auto-generated manifests for efficient discovery and navigation

### 📚 **Knowledge Organization**

- **External Sources**: Standards, vendor docs, research papers, transcripts
- **Internal Knowledge**: Concepts, runbooks, decision contexts, integration guides
- **Version Control**: Full change tracking and history for all specifications
- **Search & Discovery**: Manifest-based indexing for rapid content location

## System Requirements

- Git
- curl or wget
- Internet connection

The installer will automatically install missing dependencies on supported systems (Ubuntu/Debian, RHEL/CentOS, macOS).

## Manual Installation

If you prefer to install manually:

```bash
# Clone the repository
git clone https://github.com/brain-model/sde-workspace.git
cd sde-workspace

# Run the installer
./install.sh
```

## Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](CONTRIBUTING.md) to get started:

- **Development Workflow**: Setup, coding standards, and testing procedures
- **Branch Strategy**: How we manage different language and feature branches
- **Semantic Commits**: Our commit message conventions for automated versioning
- **Code Review Process**: Guidelines for submitting and reviewing pull requests

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes, new features, and architectural decisions.

## Support

For issues and questions:

- Open an issue on [GitHub Issues](https://github.com/brain-model/sde-workspace/issues)
- Check our documentation in the `.sde_workspace/system/guides/` directory
- Review [Contributing Guidelines](CONTRIBUTING.md) for development questions

## License

MIT License - see [LICENSE](LICENSE) file for details.
