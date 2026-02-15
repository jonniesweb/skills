#!/usr/bin/env bash
# Log turn completion to CXDB
set -uo pipefail

CXDB_HTTP="${CXDB_HTTP:-http://localhost:9080}"
SESSION_DIR="/tmp/cxdb-sessions"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
[[ -n "$SESSION_ID" ]] || exit 0

CONTEXT_FILE="$SESSION_DIR/$SESSION_ID"
[[ -f "$CONTEXT_FILE" ]] || exit 0
CONTEXT_ID=$(cat "$CONTEXT_FILE")
[[ -n "$CONTEXT_ID" ]] || exit 0

curl -sf -X POST "$CXDB_HTTP/v1/contexts/$CONTEXT_ID/append" \
  -H 'Content-Type: application/json' \
  -d '{
    "type_id": "claude-code.TurnComplete",
    "type_version": 1,
    "data": { "role": "system", "content": "--- turn complete ---" }
  }' 2>/dev/null || true

exit 0
