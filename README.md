# Autonomous Development Agent System

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

## 1. Overview

This project implements an autonomous multi-agent system for software development. It uses a team of five specialized AI agents to transform a business requirement into a high-quality, reviewed Merge Request (MR) ready for human approval. The goal is to standardize the development lifecycle, ensure code and process quality, and automate repetitive tasks.

## 2. Quick Installation

To clone the repository and automatically set up the `.sde_workspace` directory structure, run the following command in your terminal:

```sh
curl -sSL https://raw.githubusercontent.com/brain-model/sde-workspace/main/install.sh | bash -s -- https://github.com/brain-model/sde-workspace.git
```

> **What does this command do?** It downloads the `install.sh` script from the repository, executes it with `bash`, and passes the repository URL as an argument so the script can clone it. After cloning, it runs `make install` to create all the necessary directory structure.

## 3. System Architecture

### 3.1. Directory Structure

```bash
.sde_workspace/
├── backlog/            # Contains the backlog of tasks to be developed.
├── specs/              # Stores Technical Specification Documents.
├── workspaces/         # Active workspace area for each task in progress.
├── archive/            # Archive of completed tasks.
└── system/
    ├── guides/         # Reference guides, such as semantic commit guide.
    ├── agents/         # Contains the prompts that define each agent.
    └── templates/      # Templates for artifacts (specs, QA reports, etc.).
```

### 3.2. The Agents

* **Orchestrator:** The "conductor" of the system. Manages the state machine and invokes other agents.
* **Architect:** Translates business requirements into detailed technical specifications.
* **Developer:** Implements code, manages Git lifecycle, and creates Merge Requests.
* **QA (Quality Assurance):** Validates implementation against specification and looks for bugs.
* **Reviewer:** Performs technical code review, focusing on quality, architecture, and security.

## 4. Operation Flow

The workflow is a sequential process with integrated feedback loops to ensure quality at each stage.

### 4.1. High-Level Flow Diagram

```mermaid
graph TD
    A[Backlog] --> B{Technical Design};
    B --> C[Initial Development];
    C --> D{QA Loop};
    D -- Approved --> E[MR Creation];
    D -- Rejected --> C;
    E --> F{Code Review Loop};
    F -- Approved --> G[Ready for Human Review];
    F -- Rejected --> C;

    style A fill:#f9f,stroke:#333,stroke-width:2px
    style G fill:#bbf,stroke:#333,stroke-width:2px
```

### 4.2. Detailed Sequence Diagram

```mermaid
sequenceDiagram
    participant Human
    participant Orchestrator
    participant Architect
    participant Developer
    participant QA
    participant Reviewer
    participant GitRepository

    Human->>Orchestrator: Adds item to backlog.md
    Orchestrator->>Architect: Invokes to create Spec
    Architect->>Orchestrator: Saves spec.md in specs/
    Orchestrator->>Orchestrator: Creates workspace and handoff.json
    Orchestrator->>Developer: Invokes for development
    Developer->>GitRepository: Creates branch (checkout -b)
    Developer->>GitRepository: Squashes and push --force
    Developer->>Orchestrator: Updates handoff.json (status: AWAITING_QA)
    Orchestrator->>QA: Invokes for testing

    loop QA Loop
        QA->>GitRepository: Pulls code
        QA->>Orchestrator: Updates handoff.json (QA_APPROVED or QA_REVISION_NEEDED)
        alt If QA_REVISION_NEEDED
            Orchestrator->>Developer: Invokes for fixes
            Developer->>GitRepository: Redoes squash and push --force
            Developer->>Orchestrator: Updates handoff.json (status: AWAITING_QA)
        end
    end

    Orchestrator->>Developer: Invokes to create MR
    Developer->>GitRepository: Creates MR via CLI
    Developer->>Orchestrator: Updates handoff.json (status: AWAITING_TECHNICAL_REVIEW)
    Orchestrator->>Reviewer: Invokes for review

    loop Code Review Loop
        Reviewer->>GitRepository: Extracts diff and posts comments on MR
        Reviewer->>Orchestrator: Updates handoff.json (TECHNICALLY_APPROVED or TECHNICAL_REVISION_NEEDED)
        alt If TECHNICAL_REVISION_NEEDED
            Orchestrator->>Developer: Invokes for fixes
            Developer->>GitRepository: Redoes squash and push --force
            Developer->>Orchestrator: Updates handoff.json
        end
    end

    Orchestrator->>Human: Notifies that MR is ready for final review
```

## 5. Usage and Detailed Installation

### 5.1. Prerequisites

* `git` installed and configured.
* `make` installed.
* Git provider CLI installed and authenticated (e.g., `gh` for GitHub, `glab` for GitLab).
* Runtime environment for agents (e.g., Python with necessary libraries).

### 5.2. Manual Installation

1. **Clone the repository:**

    ```sh
    git clone https://github.com/brain-model/sde-workspace.git
    ```

2. **Enter the directory:**

    ```sh
    cd sde-workspace
    ```

3. **Create the workspace structure:**

    ```sh
    make install
    ```

### 5.3. Usage Flow

1. **Start a Task:** Add a new detailed work item to the `.sde_workspace/backlog/BACKLOG.md` file, using `task_template.md` as a guide.
2. **Run the Orchestrator:** Start the main process (e.g., `python run_orchestrator.py`). The orchestrator will detect the new task and start the flow.
3. **Monitor Progress:** Observe changes in the `workspaces/` directories and the `status` field in `handoff.json` files.
4. **Finalize the Process:** When a task is completed, the Orchestrator will move it to `archive/`. An MR will be open in the repository, awaiting final review and merge by a human.
