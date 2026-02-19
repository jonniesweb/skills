---
name: review-branch
description: Review code changes in the current branch for issues
---

# Review Branch

Review the code modified in this branch for bugs, redundant code, or obvious overcomplication.

## Instructions

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
4. Summarize findings at the end
