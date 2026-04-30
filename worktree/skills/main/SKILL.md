---
name: main
description: Move a sibling worktree's branch into the main checkout, then remove the worktree.
---

Run `bash <skill-dir>/move.sh [<source-worktree-path>]`. The script verifies both worktrees are clean, removes the source, and checks the branch out in main.

From a linked worktree, no argument is needed. From the main checkout, pass the source path explicitly — when several linked worktrees exist, infer from session context (the branch the user just merged/PR'd, the worktree they were just working in) and confirm rather than asking the user to pick from a long list.
