---
name: plan-to-bd
description: Convert a plan into a beads epic with detailed issues and subissues
---

# Plan to Beads

Turn the current plan or context into a beads epic. Create issues and subissues that best represent the chunks of work to complete.

## Instructions

1. Analyze the current plan or context provided
2. Break down the work into logical epics, issues, and subissues
3. For each issue, include:
   - Clear title describing the work
   - Detailed description with acceptance criteria
   - Technical context and implementation notes
   - Dependencies on other issues if applicable
4. Organize issues in a logical order of implementation
5. Create the epic and all child issues in beads

## bd Commands Reference

### Create an epic
```bash
bd create --title="Epic title" --type=epic --description="Epic description" --priority=2
```

### Create child issues under an epic
Use `--parent <epic-id>` to establish the parent/child relationship:
```bash
bd create --title="Child issue" --type=task --parent=<epic-id> --description="Description" --priority=2
```

### Capture issue ID for scripting
Use `--silent` to output only the issue ID:
```bash
EPIC_ID=$(bd create --title="Epic title" --type=epic --silent)
bd create --title="Child task" --type=task --parent=$EPIC_ID --silent
```

### Add dependencies between issues
```bash
# issue-A depends on issue-B (issue-B must complete first)
bd dep add <issue-A> <issue-B>

# Or: issue-B blocks issue-A (equivalent)
bd dep <issue-B> --blocks <issue-A>
```

### View epic status
```bash
bd epic status          # Show completion status of all epics
bd children <epic-id>   # List child issues of an epic
```

## Workflow

1. Create the epic first with `--type=epic --silent` to capture its ID
2. Create child issues with `--parent=<epic-id>` for each piece of work
3. Add dependencies between child issues with `bd dep add` where ordering matters
4. Use parallel subagents when creating many issues for efficiency
