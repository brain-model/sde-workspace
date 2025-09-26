# Contributing to SDE Workspace

Thank you for your interest in contributing to the SDE Workspace project! This guide will help you get started.

## Getting Started

1. **Fork the repository** and clone it locally
2. **Install the workspace** using the installer:

   ```bash
   curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/master/boot.sh | bash
   ```

3. **Choose your configuration** from the 4 available options:
   - `default-ptbr` - Brazilian Portuguese (standard version)
   - `default-enus` - English US (standard version)
   - `copilot-ptbr` - Brazilian Portuguese (GitHub Copilot version)
   - `copilot-enus` - English US (GitHub Copilot version)

## Development Workflow

### Branch Strategy

- `master` - Main branch with the latest stable version
- `default-ptbr` - Brazilian Portuguese standard version
- `default-enus` - English US standard version
- `copilot-ptbr` - Brazilian Portuguese with GitHub Copilot integration
- `copilot-enus` - English US with GitHub Copilot integration

### Making Changes

1. **Create a feature branch** from the appropriate base branch
2. **Follow semantic commit conventions** (see `.sde_workspace/system/guides/semantic_commit_guide.md`)
3. **Test your changes** across all relevant branch configurations
4. **Update documentation** if necessary
5. **Submit a pull request** with clear description

### Commit Message Format

We use semantic commit messages. Format: `<type>[<scope>]: <description>`

Examples:

- `feat: add new agent workflow`
- `fix(installer): resolve branch detection issue`
- `docs: update installation guide`

See the complete guide in `.sde_workspace/system/guides/semantic_commit_guide.md`

## Code Guidelines

### File Structure

- **Maintain consistency** across all language branches
- **Use templates** from `.sde_workspace/system/templates/`
- **Follow naming conventions** without accents for Portuguese files
- **Update manifests** when adding knowledge base content

### Agent System

- **Agent files** should be consistent across language versions
- **Prompts** should be translated maintaining technical accuracy
- **Workflow logic** must remain identical across all versions

## Documentation

### Multi-language Support

- **English (EN-US)**: Default for international contributors
- **Portuguese (PT-BR)**: Localized version for Brazilian users
- **No accents**: Portuguese files use simplified naming without accents

### Knowledge Base

- Use standardized frontmatter for all knowledge files
- Maintain the 7-field schema: id, title, category, created, updated, source, tags
- Follow the organized structure in `.sde_workspace/knowledge/`

## Testing

1. **Installation testing**: Verify installer works on different configurations
2. **Cross-branch validation**: Ensure changes work across all 4 branches
3. **Agent workflow testing**: Validate agent interactions and handoffs
4. **Documentation updates**: Check all READMEs and guides are current

## Reporting Issues

When reporting issues, please include:

- **Configuration used** (which of the 4 branches)
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (OS, shell, Git version)

## Community

- **Be respectful** and collaborative
- **Follow the code of conduct**
- **Help others** in discussions and reviews
- **Share knowledge** and improve documentation

## Questions?

- Check existing **documentation** in `.sde_workspace/`
- Review **closed issues** for similar questions
- Open a **new issue** with the `question` label
- Join **discussions** in the repository

Thank you for contributing to SDE Workspace!
