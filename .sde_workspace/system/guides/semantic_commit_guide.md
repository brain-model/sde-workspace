# Semantic Commit Guide

## 1. Mission

This guide establishes the semantic commit convention for the project. The practice of categorizing commits in a structured way creates an explicit versioning history that is readable by both humans and machines.

Adherence to this standard is **mandatory** and allows us to:

* Quickly understand changes in each commit.
* Automate `CHANGELOG.md` generation.
* Automate semantic versioning (MAJOR, MINOR, PATCH).

## 2. Specification

Each commit message consists of a **header**, an optional **body**, and an optional **footer**.

```plaintext

<type>[<scope>]: <description>

[optional body]

[optional footer(s)]

```

---

## 3. Commit Structure

### Header (Required)

The header is the main line of the commit and must strictly follow the format `type(scope): description`.

* **`type`**: Defines the category of change. (See the types table below).
* **`scope` (optional)**: A noun in parentheses that describes the affected code area (e.g., `core`, `component`, `api-billing`). Use it when the change is restricted to a specific module.
* **`description`**: A short, imperative summary of the change, in lowercase. Don't capitalize the first letter and don't end with a period.

#### Header Examples

```sh
# Without scope
feat: add new swipe breadcrumb

# With scope
feat(core): add api integration with Crush system
```

### Body (Optional)

The body is used to provide additional context about the change.

* Must be separated from the header by a blank line.
* Use it to explain the "what" and "why" of the change, not the "how".

### Footer (Optional)

The footer is used for two main purposes:

1. **Breaking Changes:** To indicate a change that breaks compatibility. Start the footer with `BREAKING CHANGE:`, followed by a clear explanation of the change, justification, and migration notes. A `BREAKING CHANGE` always results in a `MAJOR` version.
2. **Task Reference:** To link the commit to tasks or issues in a tracking system.

#### Example with Breaking Change

```plaintext
feat(core): add method X

BREAKING CHANGE: method Y has been discontinued in favor of method X due to performance improvement. To migrate, replace all calls from `Y()` to `X()`.
```

## 4. Types Table

This table is the primary reference for allowed commit `types`, their impact on `CHANGELOG` and `Version`.

| Type | CHANGELOG | Generated Version | Description |
| :--- | :--- | :--- | :--- |
| `refactor` | "Code Refactoring" | Patch `x.x.x+1` | Logical/semantic improvement in pre-existing code. |
| `feat` | "Features" | Minor `x.x+1.x` | Addition of new functionality. |
| `fix` | "Bug Fixes" | Patch `x.x.x+1` | Bug fix. |
| `chore` | "Improvements" | Patch `x.x.x+1` | A small improvement that has no direct business impact. |
| `test` | "Tests" | Patch `x.x.x+1` | Addition or modification of tests of any type. |
| `perf` | "Performance Improvements" | Patch `x.x.x+1` | Performance improvement. |
| `build` | "Build System" | Patch `x.x.x+1` | Addition or change in project build scripts. |
| `ci` | "Continuous Integration"| Patch `x.x.x+1` | Changes in CI steps. |
| `docs` | "Documentation" | Patch `x.x.x+1` | Addition or change in project documentation. |
| `style` | "Styles" | Patch `x.x.x+1` | "Code style": Changes in code style without affecting it (spaces, tabs, etc.). |
| `revert` | "Reverts" | Patch `x.x.x+1` | Undo something in the project via `git revert`. |

## 5. Complete Practical Examples

### Example 1: New feature

```plaintext
feat(api): add endpoint for order status query

Implements the new GET /orders/{id}/status endpoint that returns the current order state.
This endpoint will be consumed by the new customer tracking panel.

Refs: TASK-451
```

### Example 2: Bug fix with breaking change

```plaintext
fix(auth): fix token renewal flow

The token renewal flow was failing when the access token expired at exactly the same second as verification. The logic was adjusted to include a 5-second safety margin.

BREAKING CHANGE: the `TOKEN_EXPIRATION_MARGIN` environment variable has been removed. The system now uses a fixed value internally. Deployments must remove this variable from their configurations.
```
