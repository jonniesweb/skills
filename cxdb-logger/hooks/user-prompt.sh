#!/usr/bin/env bash
# Log user prompts to CXDB
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

PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')
# Truncate long prompts
if [[ ${#PROMPT} -gt 4000 ]]; then
  PROMPT="${PROMPT:0:4000}... [truncated]"
fi

curl -sf -X POST "$CXDB_HTTP/v1/contexts/$CONTEXT_ID/append" \
  -H 'Content-Type: application/json' \
  -d "$(jq -n --arg content "$PROMPT" '{
    type_id: "claude-code.UserPrompt",
    type_version: 1,
    data: { role: "user", content: $content }
  }')" 2>/dev/null || true

exit 0
