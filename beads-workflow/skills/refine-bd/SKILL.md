---
name: refine-bd
description: Refine a beads issue or epic for implementation quality
---

# Refine Beads Issue

Refine a beads issue or epic to verify it's the best implementation approach and integrates well into the codebase.

## Instructions

1. Review the current beads issue or epic
2. Verify the proposed implementation approach:
   - Is this the best way to implement this?
   - Does it integrate well with existing codebase patterns?
   - Are there edge cases or considerations missing?
3. Ensure each task has sufficient detail for an AI coding agent to implement it:
   - Clear acceptance criteria
   - Technical implementation notes
   - File paths and code references where helpful
4. If any task is too complex or large:
   - Split it into smaller, more focused issues
   - Ensure each sub-task is independently implementable
5. Verify dependencies between tasks make sense:
   - Check for circular dependencies
   - Ensure prerequisite tasks come first
   - Identify tasks that can be parallelized
