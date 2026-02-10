---
name: work-post
description: Post-work cleanup - verify commits and update beads issues
---

# Work Post

Post-work cleanup after completing a task.

## Instructions

1. Check if there's anything left to do from the current work:
   - Review uncommitted changes with `git status`
   - Check if all acceptance criteria were met
2. Verify work was committed:
   - Run `git log -1` to see the last commit
   - Ensure the commit message accurately describes the work
3. Review the related beads epic and issues:
   - Is there anything that should be updated?
   - Were any new tasks discovered during implementation?
   - Are there follow-up improvements to track?
4. For any outstanding work or discoveries:
   - Create or update beads issues so work isn't lost
   - Reference the epic if the work is part of it
   - Include enough context for future implementation
5. Summarize what was completed and any issues created
