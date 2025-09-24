# SDE Workspace

**[ [EN](README.md) | [PT](README.ptbr.md) ]**

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

## Overview

SDE Workspace is an autonomous multi-agent system for software development. It provides a structured environment with specialized AI agents to transform business requirements into high-quality code through an automated development lifecycle.

## Quick Installation

Install SDE Workspace with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/master/boot.sh | bash
```

Or using wget:

```bash
wget -qO- https://raw.githubusercontent.com/brain-model/sde-workspace/master/boot.sh | bash
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

```
.sde_workspace/
├── system/
│   ├── agents/         # AI agent definitions
│   ├── guides/         # Development guides
│   └── templates/      # Document templates
└── .github/
    └── copilot-instructions.md  # Copilot configuration
```

For Copilot versions, you'll also get:

```
.github/
└── chatmodes/
    ├── architect.chatmode.md
    ├── developer.chatmode.md
    ├── qa.chatmode.md
    └── reviewer.chatmode.md
```

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

## Support

For issues and questions:
- Open an issue on [GitHub Issues](https://github.com/brain-model/sde-workspace/issues)
- Check our documentation in the `.sde_workspace/system/guides/` directory

## License

MIT License - see [LICENSE](LICENSE) file for details.
