#!/usr/bin/env bash
# Build and install cxdb-writer binary
set -euo pipefail

CXDB_WRITER_SRC="$HOME/work/cxdb/tools/cxdb-writer"
INSTALL_DIR="$HOME/bin"
BINARY="$INSTALL_DIR/cxdb-writer"

if [[ ! -d "$CXDB_WRITER_SRC" ]]; then
  echo "Error: cxdb-writer source not found at $CXDB_WRITER_SRC"
  exit 1
fi

mkdir -p "$INSTALL_DIR"
echo "Building cxdb-writer..."
cd "$CXDB_WRITER_SRC"
go build -o "$BINARY" .
echo "Installed cxdb-writer to $BINARY"
