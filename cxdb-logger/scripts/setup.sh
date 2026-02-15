#!/usr/bin/env bash
# Setup script for cxdb-logger plugin
# The hooks now use curl + HTTP API directly, so no Go binary is required for writes.
# cxdb-writer is still useful for binary protocol reads/debugging if available.
set -euo pipefail

CXDB_WRITER_SRC="$HOME/work/cxdb/tools/cxdb-writer"
INSTALL_DIR="$HOME/bin"
BINARY="$INSTALL_DIR/cxdb-writer"

if [[ ! -d "$CXDB_WRITER_SRC" ]]; then
  echo "Note: cxdb-writer source not found at $CXDB_WRITER_SRC (optional - hooks use HTTP API)"
  exit 0
fi

mkdir -p "$INSTALL_DIR"
echo "Building cxdb-writer (optional, for reads/debugging)..."
cd "$CXDB_WRITER_SRC"
go build -o "$BINARY" .
echo "Installed cxdb-writer to $BINARY"
