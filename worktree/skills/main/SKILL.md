---
name: main
description: Checkout the current worktree's branch in the main worktree.
---

Guard: confirm you are in a linked git worktree, not the main checkout. Compare `git rev-parse --git-dir` and `git rev-parse --git-common-dir` — if they resolve to the same path, you're already in the main worktree. Stop and tell the user they're not on a worktree.

Capture the current branch (`git rev-parse --abbrev-ref HEAD`), the current worktree path (`git rev-parse --show-toplevel`), and the main worktree path (the first `worktree` line of `git worktree list --porcelain`).

The branch can't be checked out in two worktrees at once, so the current worktree must be removed first. From the main worktree: `git worktree remove <current-worktree-path>`, then `git checkout <branch>`.
