#!/usr/bin/env bash
# Log tool calls and results to CXDB
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

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}' | head -c 1000)
TOOL_RESPONSE=$(echo "$INPUT" | jq -c '.tool_response // {}' | head -c 1000)

SUMMARY="Tool: $TOOL_NAME
Input: $TOOL_INPUT
Response: $TOOL_RESPONSE"

"$WRITER" append \
  -context "$CONTEXT_ID" \
  -role assistant \
  -text "$SUMMARY" \
  -type-id "claude-code.ToolUse" \
  -type-version 1 2>/dev/null || true

exit 0
