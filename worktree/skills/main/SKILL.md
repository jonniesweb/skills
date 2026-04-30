---
name: main
description: Move a sibling worktree's branch into the main checkout, then remove the worktree.
---

Find the source worktree. If you're in a linked worktree (`git rev-parse --git-dir` ≠ `--git-common-dir`), it's the source. From the main checkout, pick from `git worktree list` — when several exist, infer from session context and confirm rather than asking the user to pick from a long list.

Stop if either source or main has uncommitted changes. Never auto-stash or discard.

`cd` to main first (removing the source invalidates your cwd), then `git worktree remove <src>` and `git checkout <branch>`. Remind the user to restart any dev server.
