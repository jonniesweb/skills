---
name: rebase
description: Fetch origin/main and rebase the current worktree or branch onto the latest origin/main.
---

Run `git fetch origin main` then `git rebase origin/main` in the current worktree/branch.

If the rebase has conflicts, stop and surface them — do not auto-resolve.

Do not rebase if the current branch is `main` or `master`.

After a successful rebase, force push to origin with `git push --force-with-lease`. Only do this when on a branch (not `main`/`master`, and not detached HEAD). Skip the push if the rebase failed or was stopped for conflicts.
