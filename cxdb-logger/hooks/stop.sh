#!/usr/bin/env bash
# Log turn completion to CXDB
set -uo pipefail

WRITER="$HOME/bin/cxdb-writer"
SESSION_DIR="/tmp/cxdb-sessions"

[[ -x "$WRITER" ]] || exit 0

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
[[ -n "$SESSION_ID" ]] || exit 0

CONTEXT_FILE="$SESSION_DIR/$SESSION_ID"
[[ -f "$CONTEXT_FILE" ]] || exit 0
CONTEXT_ID=$(cat "$CONTEXT_FILE")
[[ -n "$CONTEXT_ID" ]] || exit 0

"$WRITER" append \
  -context "$CONTEXT_ID" \
  -role system \
  -text "--- turn complete ---" \
  -type-id "claude-code.TurnComplete" \
  -type-version 1 2>/dev/null || true

exit 0
