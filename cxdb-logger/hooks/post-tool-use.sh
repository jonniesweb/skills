#!/usr/bin/env bash
# Log tool calls and results to CXDB
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

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}' | head -c 4000)
TOOL_RESPONSE=$(echo "$INPUT" | jq -c '.tool_response // {}' | head -c 4000)

curl -sf -X POST "$CXDB_HTTP/v1/contexts/$CONTEXT_ID/append" \
  -H 'Content-Type: application/json' \
  -d "$(jq -n \
    --arg name "$TOOL_NAME" \
    --arg input "$TOOL_INPUT" \
    --arg resp "$TOOL_RESPONSE" \
    '{
      type_id: "claude-code.ToolUse",
      type_version: 2,
      data: {
        role: "assistant",
        content: ("Tool: " + $name),
        tool_name: $name,
        tool_input: $input,
        tool_response: $resp
      }
    }')" 2>/dev/null || true

exit 0
