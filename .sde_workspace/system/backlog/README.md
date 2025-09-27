# Backlog

Structured work items and prioritized tasks for the development workflow.

## Purpose

This directory contains organized development tasks that feed into the SDE Workspace agent system. Each item represents a prioritized feature, improvement, or fix that goes through the complete development lifecycle.

## Content

- **Task specifications**: Detailed work items with acceptance criteria
- **Priority management**: Ordered tasks by business value and urgency  
- **Requirements gathering**: Business needs translated into actionable items
- **Feature roadmap**: Strategic development planning
- **Sprint planning**: Short-term iteration planning

## Format

- Use structured frontmatter with priority, status, and metadata
- Include clear acceptance criteria and business value
- Reference related specs and dependencies
- Maintain traceability from business need to implementation
- Follow task template structure from `system/templates/`

## Workflow Integration

Tasks from this backlog are automatically picked up by the Architect Agent to create technical specifications, which then flow through the complete development pipeline (Developer → QA → Reviewer → PM).
