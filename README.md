# jonniesweb/skills

A Claude Code skills and plugins marketplace — a collection of reusable AI agent workflows by [Jon Simpson](https://github.com/jonniesweb).

Each plugin is a self-contained directory at the repo root. The central registry at [`.claude-plugin/marketplace.json`](./.claude-plugin/marketplace.json) lists every plugin available in this marketplace.

## Installation

Add this repo as a marketplace inside Claude Code:

```
/plugin marketplace add jonniesweb/skills
```

Then install individual plugins:

```
/plugin install <plugin-name>@jonniesweb-skills
```

## Plugins

### [beads-workflow](./beads-workflow)

Task management workflow skills built around the [`bd` (beads)](https://github.com/) CLI.

| Skill | Description |
| --- | --- |
| `investigate` | Investigate a GitHub issue or feature description, determine status, and plan implementation if needed |
| `plan-to-bd` | Convert a plan into a beads epic with detailed issues and subissues |
| `refine-plan` | Verify and refine an implementation plan |
| `refine-bd` | Refine a beads issue or epic for implementation quality |
| `review-branch` | Review code changes in the current branch for issues |
| `work` | Work on the next available beads task |
| `work-post` | Post-work cleanup — verify commits and update beads issues |

### [retro](./retro)

Session retrospective skill. Reflect on the conversation, surface lessons, and capture follow-ups.

### [cxdb-logger](./cxdb-logger)

Hook-based session logging to CXDB via HTTP API. Hooks-only — no skills. Captures session start, user prompts, tool use, and stop events for observability.

### [gepa](https://github.com/jonniesweb/gepa-cli)

LLM-guided optimizer for any text artifact, using the `gepa` CLI with an evaluator protocol. Sourced from [`jonniesweb/gepa-cli`](https://github.com/jonniesweb/gepa-cli).

### [worktree](./worktree)

Git worktree workflow skills.

| Skill | Description |
| --- | --- |
| `fix` | Build the requested change in a git worktree, then open a PR |
| `rebase` | Fetch `origin/main` and rebase the current worktree or branch onto it |
| `main` | Checkout the main worktree |

## Plugin layout

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json              # name, version, description
├── skills/
│   └── skill-name/
│       └── SKILL.md             # YAML frontmatter + markdown body
├── hooks/                       # optional lifecycle hooks
│   ├── hooks.json
│   └── *.sh
├── references/                  # optional reference docs
└── scripts/                     # optional templates / utilities
```

Skill frontmatter requires `name` and `description`. Optional fields: `user-invocable: true`, `disable-model-invocation: true`.

## Adding a new plugin

1. Create the plugin directory with `.claude-plugin/plugin.json`.
2. Add skill definitions as `SKILL.md` files under `skills/<name>/`.
3. Register the plugin in [`.claude-plugin/marketplace.json`](./.claude-plugin/marketplace.json) with `name`, `source`, `description`, `version`, and `keywords`.

See [`CLAUDE.md`](./CLAUDE.md) for the full contributor guide.
