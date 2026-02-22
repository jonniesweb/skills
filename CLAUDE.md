# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code skills and plugins marketplace — a collection of reusable AI agent workflows. Each plugin is a self-contained directory at the repo root. The central registry at `.claude-plugin/marketplace.json` lists all available plugins and must be kept in sync when adding or modifying plugins.

## Plugin Structure

Every plugin follows this layout:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json              # Required: name, version, description
├── skills/
│   └── skill-name/
│       └── SKILL.md             # Skill definition (YAML frontmatter + markdown body)
├── hooks/                       # Optional: lifecycle hooks
│   ├── hooks.json               # Hook event bindings
│   └── *.sh                     # Hook scripts
├── references/                  # Optional: reference docs
└── scripts/                     # Optional: templates/utilities
```

Skill definitions use YAML frontmatter with `name` and `description` fields. Optional frontmatter: `user-invocable: true`, `disable-model-invocation: true`. The gepa plugin is an exception — its `SKILL.md` lives directly in the plugin root rather than under `skills/`.

## Current Plugins

- **beads-workflow** — 7 skills for task management using the `bd` (beads) CLI: investigate, plan-to-bd, refine-plan, refine-bd, review-branch, work, work-post
- **retro** — Session retrospective/reflection skill
- **cxdb-logger** — Hook-based session logging to CXDB via HTTP API (no skills, only hooks)
- **gepa** — LLM-guided optimization using the `gepa` CLI with evaluator protocol

## Shell Script Conventions

Hook scripts use `set -uo pipefail`, parse JSON with `jq`, and exit 0 on non-fatal failures. The `$CLAUDE_PLUGIN_ROOT` env var references the plugin directory in hook commands.

## Adding a New Plugin

1. Create the plugin directory with `.claude-plugin/plugin.json`
2. Add skill definitions as `SKILL.md` files (under `skills/<name>/` or at plugin root)
3. Add the plugin entry to `.claude-plugin/marketplace.json` with name, source path, description, version, and keywords
