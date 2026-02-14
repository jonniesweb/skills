#!/usr/bin/env bash
# Create a CXDB context for this Claude Code session
set -uo pipefail

WRITER="$HOME/bin/cxdb-writer"
SESSION_DIR="/tmp/cxdb-sessions"

# Fail silently if cxdb-writer not available
[[ -x "$WRITER" ]] || exit 0

# Read hook input from stdin
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
[[ -n "$SESSION_ID" ]] || exit 0

mkdir -p "$SESSION_DIR"

# If context already exists for this session, skip
[[ -f "$SESSION_DIR/$SESSION_ID" ]] && exit 0

# Create a new CXDB context
OUTPUT=$("$WRITER" create-context 2>/dev/null) || exit 0
CONTEXT_ID=$(echo "$OUTPUT" | sed -n 's/.*context_id=\([0-9]*\).*/\1/p')
[[ -n "$CONTEXT_ID" ]] || exit 0

echo "$CONTEXT_ID" > "$SESSION_DIR/$SESSION_ID"

# Log the session start as the first turn
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"')
SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"')
"$WRITER" append \
  -context "$CONTEXT_ID" \
  -role system \
  -text "Session started (source=$SOURCE, cwd=$CWD)" \
  -type-id "claude-code.SessionStart" \
  -type-version 1 2>/dev/null || true

exit 0
