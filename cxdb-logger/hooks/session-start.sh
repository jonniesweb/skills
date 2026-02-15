#!/usr/bin/env bash
# Create a CXDB context for this Claude Code session
set -uo pipefail

CXDB_HTTP="${CXDB_HTTP:-http://localhost:9080}"
SESSION_DIR="/tmp/cxdb-sessions"

# Read hook input from stdin
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
[[ -n "$SESSION_ID" ]] || exit 0

mkdir -p "$SESSION_DIR"

# If context already exists for this session, skip
[[ -f "$SESSION_DIR/$SESSION_ID" ]] && exit 0

# Create a new CXDB context via HTTP API
CONTEXT_ID=$(curl -sf -X POST "$CXDB_HTTP/v1/contexts/create" \
  -H 'Content-Type: application/json' \
  -d '{}' 2>/dev/null | jq -r '.context_id // empty') || exit 0
[[ -n "$CONTEXT_ID" ]] || exit 0

echo "$CONTEXT_ID" > "$SESSION_DIR/$SESSION_ID"

# Publish registry bundle (idempotent - 204 if already exists with same content)
BUNDLE_FILE="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}/registry-bundle.json"
if [[ -f "$BUNDLE_FILE" ]]; then
  BUNDLE_ID=$(jq -r '.bundle_id' "$BUNDLE_FILE" 2>/dev/null)
  curl -sf -X PUT "$CXDB_HTTP/v1/registry/bundles/$BUNDLE_ID" \
    -H 'Content-Type: application/json' \
    -d @"$BUNDLE_FILE" 2>/dev/null || true
fi

# Log the session start as the first turn
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"')
SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"')

curl -sf -X POST "$CXDB_HTTP/v1/contexts/$CONTEXT_ID/append" \
  -H 'Content-Type: application/json' \
  -d "$(jq -n \
    --arg source "$SOURCE" \
    --arg cwd "$CWD" \
    '{
      type_id: "claude-code.SessionStart",
      type_version: 2,
      data: {
        role: "system",
        content: ("Session started (source=" + $source + ", cwd=" + $cwd + ")"),
        source: $source,
        cwd: $cwd
      }
    }')" 2>/dev/null || true

exit 0
