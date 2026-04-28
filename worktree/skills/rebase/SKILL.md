---
name: rebase
description: Fetch origin/main and rebase the current worktree or branch onto the latest origin/main.
---

Run `git fetch origin main` then `git rebase origin/main` in the current worktree/branch.

If the rebase has conflicts, stop and surface them — do not auto-resolve.

Do not rebase if the current branch is `main` or `master`.
