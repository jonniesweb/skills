---
name: main
description: Move a sibling worktree's branch into the main checkout, then remove the worktree.
---

Identify the source worktree (the one whose branch should land in main):

- If `git rev-parse --git-dir` ≠ `git rev-parse --git-common-dir`, you're in a linked worktree — that is the source.
- Otherwise (you're in the main checkout already), pick the source from `git worktree list`. If only one linked worktree exists, use it. If several, infer from session context (the branch the user just merged/PR'd, the worktree they were just working in) and confirm with the user before doing anything destructive — do not ask them to pick blindly from a long list.

Capture: source branch (`git -C <src> rev-parse --abbrev-ref HEAD`), source path (`git -C <src> rev-parse --show-toplevel`), main path (first `worktree` line of `git worktree list --porcelain`).

Verify both the source and main are clean: `git -C <path> status --porcelain` must be empty for each. If either is dirty, stop and surface what's uncommitted — never auto-stash, reset, or discard.

A branch can't be checked out in two worktrees at once, so the source worktree must be removed first. `cd` to the main worktree before doing this — removing the directory you're standing in leaves your shell in an invalid cwd. Then: `git worktree remove <src>` followed by `git checkout <branch>`.

After the checkout, remind the user that any dev server running against the main checkout needs to be restarted to pick up the branch change.
