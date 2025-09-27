# SDE Workspace

**Software Development Environment (SDE) Workspace** is an autonomous multi-agent system for software development that provides a structured environment with specialized agents to transform business requirements into high-quality code through an automated development cycle.

This document establishes a unique and predictable domain where normative specifications go through a formal lifecycle, institutional knowledge is organized and navigable, and tools/agents can quickly index canonical manifests without fragile heuristics.

## 1. Architecture Overview

### 🏗️ Structured Development System

- **Specification Lifecycle**: Formal flow for specs (draft → in-review → active → deprecated → archived)
- **Multi-Agent System**: Specialized AI agents for different development functions
- **Knowledge Management**: Organized repositories of internal and external knowledge
- **Template-Based**: Standardized templates for consistent documentation

### 🤖 AI-Driven Flow

- **GitHub Copilot Integration**: Enhanced with specialized chatmodes for different development contexts
- **Intelligent Agents**: Architect, Developer, QA, Reviewer, Product Manager and Orchestrator
- **Automated Indexing**: Self-generated manifests for efficient discovery and navigation

### 📚 Knowledge Organization

- **External Sources**: Standards, vendor documentation, research papers, transcripts
- **Internal Knowledge**: Concepts, runbooks, decision contexts, integration guides
- **Version Control**: Complete change tracking and history for all specifications
- **Search & Discovery**: Manifest-based indexing for fast content location

## 1.1. Installation and Configuration

### Quick Installation

To install the SDE Workspace, use a single command:

```bash
curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/master/boot.sh | bash
```

### Configuration Options

The installer presents 4 configuration options:

1. **default-ptbr** - Brazilian Portuguese (standard version)
2. **default-enus** - English US (standard version)  
3. **copilot-ptbr** - Brazilian Portuguese (GitHub Copilot version)
4. **copilot-enus** - English US (GitHub Copilot version)

**Differences:**

- **Standard versions**: Install only the core `.sde_workspace` structure with agents, guides and templates
- **Copilot versions**: Include additional GitHub Copilot chatmodes in `.github/chatmodes/` for enhanced AI assistance

### Installed Structure

After installation, you will have:

```bash
.sde_workspace/                    # Main structure
├── system/                       # Central normative system
│   ├── specs/                   # Specifications with lifecycle management
│   ├── agents/                  # AI agent definitions and prompts
│   ├── guides/                  # Development guides and workflows
│   ├── templates/               # Document and artifact templates
│   ├── backlog/                 # Structured work items
│   └── workspaces/              # Temporary guided work areas
├── knowledge/                    # Classified knowledge base
│   ├── external/                # External sources and documentation
│   └── internal/                # Institutional knowledge
└── .github/
    └── copilot-instructions.md  # Copilot configuration
```

For Copilot versions, there will also be:

```bash
.github/chatmodes/               # Specialized AI agent modes
├── architect.chatmode.md        # Architecture-focused agent
├── developer.chatmode.md        # Development-focused agent
├── orchestrator.chatmode.md     # Orchestration agent
├── pm.chatmode.md              # Product management agent
├── qa.chatmode.md              # Quality assurance agent
└── reviewer.chatmode.md        # Code review agent
```

## 2. Structure Architecture

```bash
.sde_workspace/
  README.md                  ← This document
  system/                    ← Normative core and automations
    specs/                   ← Specs with lifecycle
      draft/
      in-review/
      active/
      deprecated/
      archived/
    agents/                  ← Agent config/prompts (curated)
    backlog/                 ← Structured work items (curated)
    guides/                  ← Meta guides (how to use the structure / flows)
    templates/               ← Templates for creating specs/artifacts
    workspaces/              ← Ephemeral guided work areas (can be regenerated)
  knowledge/                 ← Classified knowledge base
    external/                ← Sources that come from outside the organization
      sources/
        raw/                 ← Original artifacts (PDF, txt) — immutable
        processed/           ← Normalizations (derived markdown) — generated
      standards/             ← Market standards (internal summaries)
      vendor-docs/           ← Vendor materials (curation)
      research/              ← Research, whitepapers, external benchmarks
      transcripts/           ← Transcripts from external meetings / events
    internal/                ← Institutional knowledge
      concepts/              ← Glossary and domain definitions
      runbooks/              ← Operational procedures (execution)
      references/            ← Internal lists, catalogs, indexes
      notes/
        raw/                 ← Raw notes (quick capture)
        summary/             ← Consolidated/refined notes
      decisions-context/     ← Decision narrative contexts (support for specs)
      integration/           ← Integrations (flows, mappings)
      templates/             ← Non-normative internal artifact templates
```bash
      onboarding/            ← Entry guides and learning paths
```

Notes:

- Root directories `archive/` and `backlog/` do NOT exist in this version; any external alias will only be created when automation requires it.
- Obsolete content remains within `system/specs/archived/` or is moved to specific historical folders defined case by case.
- `system/guides/` differs from `runbooks/`: guides explain HOW to contribute / navigate; runbooks explain HOW to operate/process runtime activities.

## 3. Specs Lifecycle

Possible states in `system/specs/`:

| State      | Objective | Transition Criteria |
|-------------|----------|------------------------|
| draft       | Initial ideation | Minimal structure + clear scope |
| in-review   | Collaborative evaluation | Designated reviewers + feedback addressed |
| active      | Current norm | Approved and referenced in implementations |
| deprecated  | Replaced / phase-out | New version or active approach published |
| archived    | Frozen history | Should no longer be referenced operationally |

Archiving moves the file to `archived/` preserving frontmatter and checksum.

## 4. Standard Frontmatter

### For Specs (system/specs/)

Each spec must start with YAML block:

```markdown
---
id: spec-<slug>
title: <Descriptive Title>
type: (design-doc|adr|arch-analysis|process-spec|test-spec)
status: (draft|in-review|active|deprecated|archived)
version: 1.0.0
topics: [domain, architecture, ...]
created: YYYY-MM-DD
updated: YYYY-MM-DD
supersedes: <previous-id|null>
supersededBy: <posterior-id|null>
relations: [correlated ids]
---
```

### For Knowledge (knowledge/internal/)

Each knowledge file should use standardized 7-field schema:

```markdown
---
id: <stable-identifier>
title: <Readable Title>
category: (concept|meeting-notes|decision|design-document|chat-transcript|journey|note-raw)
created: YYYY-MM-DDTHH:MM:SS-03:00
updated: YYYY-MM-DDTHH:MM:SS-03:00
source: <origin-or-url>
tags: ["topic1", "topic2", "curated|needs-curation"]
---
```

**Restrictions**:

- `id` immutable (derived from initial slug).
- Update `updated` with each substantive modification.
- Semantic versioning incremented on incompatible changes (specs only).

## 5. Indexing Manifest

### Specs Manifest

File: `system/specs/manifest.json` (automatically generated). Contains list of objects:

```json
{
  "version": 2,
  "generatedAt": "2025-09-25T12:00:00Z",
  "specs": [
    {
      "id": "spec-name",
      "path": "system/specs/active/spec-name.md",
      "checksum": "sha256:...",
      "status": "active",
      "type": "design-doc",
      "topics": ["..."],
      "version": "1.2.0",
      "updated": "2025-09-10"
    }
  ]
}
```

### Knowledge Manifest

File: `knowledge/manifest.json` (automatically generated). Indexes knowledge base:

```json
{
  "version": "2.0",
  "generatedAt": "2025-09-26T17:06:46.411497",
  "description": "Knowledge base manifest for Backstage platform documentation and internal notes",
  "repositories": {
    "internal": {
      "type": "knowledge-base",
      "governance": "contextual-information",
      "description": "Internal curated knowledge and meeting notes"
    },
    "backstage": {
      "type": "official-documentation", 
      "governance": "reference-documentation",
      "description": "Official Backstage documentation from upstream repository",
      "path": ".sde_workspace/knowledge/external/vendor-docs/backstage"
    }
  },
  "files": [...]
}
```

**Important**: Do not manually edit manifests. Regeneration tool will perform validations (id uniqueness, coherent state, updated checksum).

## 6. Operation & Contribution Flow

1. Create new spec in `system/specs/draft/` using a template from `system/templates/`.
2. Fill complete frontmatter (except generated fields).
3. Submit PR for review → move to `in-review/` when active review exists.
4. Approval promotes to `active/` (update status + move directory + regenerate manifest).
5. Obsolescence: move to `deprecated/` (add `supersededBy`).
6. Final closure: move to `archived/` maintaining links.

Automation (future / planned): frontmatter validation, manifest generation and checksum calculation via CI script.

## 7. Knowledge Base

Principles:

- Separate external vs institutional origin.
- Normalize only what's necessary (markdown in `processed/`).
- Don't edit files in `external/sources/raw/`.
- Consolidate notes: move from `notes/raw` to `notes/summary` when refined.

## 8. What You Can Edit

Editable (create/modify/remove via PR):

- `system/specs/*/*.md` (except manifest)
- `system/guides/*`
- `system/backlog/*`
- `system/templates/*`
- `system/agents/*` (prompts / configs)
- `knowledge/internal/**/*`
- `knowledge/external/standards`, `vendor-docs`, `research`, `transcripts` (synthesized content)

Don't Edit Directly:

- `system/specs/manifest.json`
- `knowledge/manifest.json`
- Files in `knowledge/external/sources/raw/`
- Derived artifacts in `knowledge/external/sources/processed/` (automated regen)
- Checksums or generated fields in manifests

## 9. Naming Conventions

- Slug: lowercase, `-` separator, no accents. Ex: `observability-pipeline-design`.
- Spec file: `spec-<slug>.md` (internal id reuses slug).
- Knowledge documents: `<slug>.md` (or original format in `raw/`).
- PDFs keep source name + optional date: `vendor-product-whitepaper-2025.pdf`.

## 10. Templates Structure

`system/templates/` should contain at least:

- `spec-design-doc.md`
- `spec-adr.md`
- `spec-arch-analysis.md`
- `spec-process-spec.md`
- `spec-test-spec.md`
- `knowledge-note.md`
- `knowledge-runbook.md`

Each template includes minimal frontmatter and mandatory sections with guide comments.

## 11. Roadmap (Summary)

- [x] ✅ **Manifest generation script v2** - `dev/scripts/generate_knowledge_manifest.py`
- [x] ✅ **Normalized knowledge frontmatter** - 7-field schema implemented
- [x] ✅ **Functional knowledge manifest** - `knowledge/manifest.json` with repositories  
- [x] ✅ **Updated agents** - Product Manager + 4 agents with new manifests
- [ ] Automatic frontmatter validation (schema)
- [ ] CI for calculating checksum diffs
- [ ] Consolidated backlog symlink/alias
- [ ] Incremental indexing for agents

## 12. Best Practices

- Small PRs per spec or logical set.
- Update `topics` to improve semantic search.
- Relate correlated specs via `relations` for contextual navigation.
- Promote deprecated quickly when approved substitute exists.

## 13. Quick FAQ

| Question | Answer |
|----------|----------|
| Can I edit manifests? | No. Automatically regenerated by scripts. |
| Where do I put raw transcript? | `knowledge/external/transcripts/` or `sources/raw/` if original file. |
| Where does an exported diagram go? | Same folder as corresponding markdown or `knowledge/internal/references/` if generic. |
| How do I handle external PDF? | Place in `sources/raw/` and generate markdown in `processed/`. |
| When to move to archived? | When it's only historical, no operational use. |
| What's the difference between manifests? | `specs/manifest.json` = normative documents; `knowledge/manifest.json` = contextual knowledge. |

## 14. Contact & Governance

Default reviewers defined in `CODEOWNERS` (future). While absent, use PR with at least 1 architecture approval + 1 operations approval.
