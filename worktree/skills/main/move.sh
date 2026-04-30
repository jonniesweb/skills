#!/usr/bin/env bash
# Move a linked worktree's branch into the main checkout, then remove the worktree.
#
# Usage: move.sh [<source-worktree-path>]
#   From a linked worktree, no argument is needed — the current worktree is the source.
#   From the main checkout, pass the source path explicitly.

set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

if [[ -n "${1:-}" ]]; then
  src="$1"
  [[ -d "$src" ]] || { echo "error: source path does not exist: $src" >&2; exit 1; }
  src="$(cd "$src" && git rev-parse --show-toplevel)"
else
  if [[ "$(git rev-parse --git-dir)" == "$(git rev-parse --git-common-dir)" ]]; then
    echo "error: you're in the main checkout — pass a source worktree path as argument" >&2
    echo >&2
    echo "linked worktrees:" >&2
    git worktree list | tail -n +2 >&2
    exit 2
  fi
  src="$(git rev-parse --show-toplevel)"
fi

main="$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')"
[[ "$src" != "$main" ]] || { echo "error: source resolves to the main worktree" >&2; exit 1; }

branch="$(git -C "$src" rev-parse --abbrev-ref HEAD)"

for path in "$src" "$main"; do
  status="$(git -C "$path" status --porcelain)"
  if [[ -n "$status" ]]; then
    echo "error: $path has uncommitted changes:" >&2
    echo "$status" >&2
    exit 3
  fi
done

cd "$main"
git worktree remove "$src"
git checkout "$branch"

echo "moved $branch into $main; removed $src"
