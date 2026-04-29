---
name: review-branch
description: Review code changes in the current branch for issues
---

# Review Branch

Review the code modified in this branch for bugs, redundant code, or obvious overcomplication.

## Always run in a subagent

This skill MUST be executed via a subagent — not in the main conversation context. The diff and per-file review work are large and would pollute the main context. When this skill is invoked, immediately dispatch a single subagent (e.g. `Agent` with `subagent_type=general-purpose`, or `superpowers:code-reviewer` if available) to carry out the steps below, and have it return a concise summary plus the list of filed beads issue IDs.

The main agent should:
1. Spawn the subagent with the instructions in this file plus any user-provided focus areas.
2. Wait for the subagent's report.
3. Relay the summary and beads issue IDs back to the user. Do not re-review files in the main context.

## Instructions (for the subagent)

1. Get the diff of changes in this branch compared to main:
   - Run `git diff origin/main...HEAD` to see all changes
   - Run `git log origin/main..HEAD --oneline` to see commits
2. Review each changed file for:
   - Bugs or logic errors
   - Redundant or dead code
   - Obvious overcomplication
   - Missing error handling
   - Security concerns
   - Performance issues
3. For each issue found:
   - Identify if it's an existing issue or introduced in this branch
   - Assess severity (critical, major, minor)
   - File a beads issue with:
     - Clear description of the problem
     - File and line references
     - Suggested fix if applicable
     - Note whether it's existing or new
4. Return a summary of findings plus the filed beads issue IDs.
