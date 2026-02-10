---
name: investigate
description: Investigate a GitHub issue or feature description, determine status, and plan implementation if needed
user_invocable: true
---

# Investigate

Take a GitHub issue ID (e.g. `#1234`) or a plain-language description of a bug/feature, investigate the current codebase to determine its status, and — if work is needed — produce a refined implementation plan with beads tracking.

## Instructions

Follow these phases in order. **Exit early** whenever a phase concludes that no further work is needed.

---

### Phase 1 — Gather Context

1. **If the input is a GitHub issue ID** (number or `#number` or a GitHub URL):
   - Fetch the issue details: `gh issue view <id> --json title,body,labels,state,comments`
   - Extract the title, description, reproduction steps, expected behavior, and any linked PRs.
   - If the issue is already closed, note this — it may already be resolved.

2. **If the input is a plain-text description**:
   - Use it directly as the problem statement.

3. Summarize the problem/feature in 1–2 sentences so the user can confirm you understood correctly.

---

### Phase 2 — Investigate Current State

Use the Explore agent (Task tool with subagent_type=Explore) and direct Grep/Glob/Read calls to answer:

1. **Is this already implemented?**
   - Search for keywords, function names, UI text, routes, or feature flags related to the issue.
   - Check recent commits and PRs: `git log --oneline --all --grep="<keywords>" -20`
   - If the feature or fix clearly already exists in the codebase, **report your findings and exit**.

2. **Can you reproduce or confirm the bug?** (for bug reports)
   - Trace the code path described in the issue.
   - Identify the root cause or confirm the described behavior from reading the code.
   - If the described bug cannot exist given the current code (e.g. the code path was changed), **report that the issue appears resolved and exit**.

3. **Is there enough information to proceed?**
   - If the issue is too vague, the area of the codebase is unclear, or you cannot determine what needs to change, **tell the user what's unclear and exit**.

After this phase, tell the user one of:
- "This is already implemented / resolved. Here's what I found: …" → **Stop.**
- "I can't determine the issue from the information available. Here's what's unclear: …" → **Stop.**
- "This needs work. Here's what I found: …" → **Continue to Phase 3.**

---

### Phase 3 — Assess Complexity & Plan

1. Based on your investigation, determine the scope of the fix or feature:
   - Which files need to change?
   - What's the general approach?
   - Are there tests to add or update?

2. **If the fix is simple** (1–2 lines, obvious change, single file):
   - Present the fix to the user with the exact change needed.
   - Ask if they'd like you to apply it directly.
   - **Stop here** — do not create beads issues for trivial fixes.

3. **If the fix is non-trivial** (multiple files, architectural decisions, or more than a couple of lines):
   - Write a detailed implementation plan directly in your response (do **NOT** use EnterPlanMode — it blocks on user interaction and stalls the pipeline).
   - Structure the plan with numbered steps, affected files, and approach for each.
   - Once the plan is written, invoke `/refine-plan` to verify and refine it.
   - Continue to Phase 4.

---

### Phase 4 — Create Tracked Work

1. Invoke `/plan-to-bd` to convert the refined plan into a beads epic with issues and subissues.

2. After beads issues are created, collect all the issue/epic IDs that were created.

3. Invoke `/refine-bd` with all the issue/epic IDs passed as arguments. Run this directly (not in a subagent) so it benefits from the full investigation and planning context already in the conversation.

4. Report the final beads epic and issue IDs to the user along with a summary of the planned work.

---

## Output Format

Always end with a clear status summary:

```
## Investigation Result

**Status**: [Already implemented | Cannot determine | Simple fix | Planned]
**Summary**: <1-2 sentence summary>

### Details
<your findings>

### Next Steps
<what happens next, or "No action needed">
```

## Important Rules

- **Always investigate before planning.** Never skip straight to implementation planning.
- **Exit early and clearly.** If the issue is resolved or unclear, say so and stop. Don't manufacture work.
- **Trust the code.** Read the actual implementation, don't guess.
- **Be specific.** When reporting findings, include file paths, line numbers, and code snippets.
- **Don't apply fixes automatically** in this skill — only plan and track. The user or `/work` skill handles implementation.
