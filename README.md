# Software Development Environment (SDE) Workspace

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

**[ [EN](README.md) | [PT](README.ptbr.md) ]**

The Software Development Environment (SDE) Workspace is a domain-driven, multi-agent platform that turns business requirements into production-ready software. It combines canonical documentation, AI agents, and governance tooling to keep architecture, code, and knowledge in sync.

## Why SDE Workspace matters

- **Single Source of Truth** – Specs, knowledge, prompts, and workflows are versioned and indexed via manifests.
- **AI-native workflows** – GitHub Copilot chatmodes and specialized agents (Architect, Developer, QA, Reviewer, PM, Orchestrator) are provisioned automatically.
- **Operations Ready** – Automation scripts monitor drift, validate manifests, calculate hashes, and generate weekly knowledge reports.

## Architecture at a glance

```text
.sde_workspace/
├── system/                    # Normative core (specs, prompts, templates, scripts)
│   ├── specs/                 # Lifecycle-managed specs (draft → archived)
│   ├── agents/                # Agent prompts & capabilities
│   ├── guides/                # Contribution & workflow guides
│   ├── templates/             # Spec / knowledge / report templates
│   ├── backlog/               # Structured work items
│   ├── handoffs/              # Formal agent handoff artifacts
│   ├── scripts/               # CLI automations (see below)
│   └── schemas/               # JSON schemas used by validators
├── knowledge/                 # Curated institutional & external knowledge base
│   ├── internal/              # Concepts, runbooks, references, notes
│   ├── external/              # Standards, vendor docs, research, transcripts
│   └── manifest.json          # Auto-generated knowledge index
└── .github/
    └── copilot-instructions.md / chatmodes/ (Copilot editions only)
```

### Specification lifecycle

| State | Purpose | Key automation |
|-------|---------|----------------|
| `draft` | Early design & ideation | Template scaffolding |
| `in-review` | Collaborative feedback | Handoff checklists |
| `active` | Approved normative spec | Manifest promotion |
| `deprecated` | Superseded guidance | Archive scheduler |
| `archived` | Frozen history | Integrity validation |

## AI-guided delivery flow

1. **Setup agent** detects tech stack and configures `.sde_workspace` on first run.
2. **Product Manager** prioritizes backlog items and orchestrates agents.
3. **Architect → Developer → QA → Reviewer** iterate through handoffs and validations.
4. **Knowledge services** index decisions, runbooks, and manifests for future reuse.

## Prerequisites

The installer now checks for mandatory dependencies before cloning. Install them upfront to avoid interruptions:

| Tool | Used for | Official docs |
|------|----------|---------------|
| `git` | Repository checkout | [git-scm.com/downloads](https://git-scm.com/downloads) |
| `curl` *(or `wget`)* | Remote bootstrap | [curl.se/download.html](https://curl.se/download.html) |
| `jq` | JSON processing across scripts | [jqlang.github.io/jq/download](https://jqlang.github.io/jq/download/) |
| `yq` | YAML front‑matter parsing | [github.com/mikefarah/yq](https://github.com/mikefarah/yq/#install) |
| `sha256sum` | Artifact hashing & manifest validation | [GNU coreutils](https://www.gnu.org/software/coreutils/coreutils.html#sha256sum-invocation) |

Optional but recommended:

- `yajsv` for JSON-Schema validation ([github.com/neilpa/yajsv](https://github.com/neilpa/yajsv))
- `gsha256sum` via `brew install coreutils` on macOS exposes `sha256sum`

If a dependency is missing, `install.sh` exits with a helpful message and links back to the relevant documentation.

## Quick start

```bash
curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/master/boot.sh | bash
```

During installation choose between:

1. `default-ptbr` – baseline structure in Brazilian Portuguese
2. `default-enus` – baseline structure in English
3. `copilot-ptbr` – baseline + Copilot chatmodes (pt-BR)
4. `copilot-enus` – baseline + Copilot chatmodes (en-US)

Copilot variants populate `.github/chatmodes/` and `.github/copilot-instructions.md` to unlock agent-aware chat experiences.

### Manual install

```bash
git clone https://github.com/brain-model/sde-workspace.git
cd sde-workspace
./install.sh
```

The installer performs a sparse checkout of `.sde_workspace/` for the selected flavor and merges Copilot chatmodes without overwriting existing files.

## Automation scripts

All CLI utilities live in `.sde_workspace/system/scripts/` and share consistent error codes (0 success / 8 missing tool). Highlights:

| Script | Purpose | Primary deps |
|--------|---------|--------------|
| `scan_knowledge.sh` | Rebuilds `knowledge/manifest.json` with hashes & metrics | `jq`, `yq`, `sha256sum` |
| `validate_manifest.sh` | Checks schema, tags, drift, and orphaned artifacts | `jq`, `yajsv` (optional) |
| `report_knowledge_health.sh` | Summarizes knowledge stats (md/json) | `jq` |
| `report_knowledge_metrics.sh` | Computes reuse ratio, priority violations, gaps | `jq` |
| `report_knowledge_weekly.sh` | Weekly digest + open P1 gaps | `jq` |
| `resolve_knowledge.sh` | Deterministic knowledge resolution & gap creation | `jq`, `grep` |
| `compute_artifact_hashes.sh` | Recomputes handoff artifact hashes | `jq`, `sha256sum` |
| `validate_handoff.sh` | End-to-end handoff validation | `jq`, `sha256sum`, `yajsv`* |
| `apply_handoff_checklist.sh` | Auto-completes handoff checklists by phase | `jq` |
| `archive_deprecated.sh` | Archives stale deprecated artifacts | `jq`, `date` |

*`yajsv` enables JSON-Schema validation; without it the script downgrades to warnings.

Each script prints `[tool:ERROR]` messages when dependencies are absent—fix the environment and re-run the installer if needed.

## Knowledge governance

- **Front-matter enforcement** – templates ensure specs and knowledge docs ship with normalized metadata.
- **Gaps management** – `resolve_knowledge.sh` escalates unanswered queries and records gaps in `.sde_workspace/knowledge/gaps/`.
- **Metrics & reporting** – weekly and ad-hoc reports quantify reuse, drift, and outstanding P1 gaps.

## Contributing & support

- Read the [Contributing Guidelines](CONTRIBUTING.md) for workflow, semantic commits, and review expectations.
- Track architectural decisions and roadmap updates in [CHANGELOG.md](CHANGELOG.md).
- Need help? open an [issue](https://github.com/brain-model/sde-workspace/issues) and review `.sde_workspace/system/guides/` for runbooks.

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.
