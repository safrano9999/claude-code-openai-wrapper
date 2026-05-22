#!/bin/bash
set -euo pipefail

CLAUDE_CLI_LINK="${CLAUDE_CLI_LINK:-/usr/local/bin/claude-cli}"

find_claude_binary() {
  local candidate

  if [ -n "${CLAUDE_BIN_PATH:-}" ] && [ -e "$CLAUDE_BIN_PATH" ]; then
    printf '%s\n' "$CLAUDE_BIN_PATH"
    return 0
  fi

  candidate="$(command -v claude 2>/dev/null || true)"
  if [ -n "$candidate" ] && [ "$candidate" != "$CLAUDE_CLI_LINK" ]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  candidate="$(
    find /root /usr/local /opt /app \
      -type f \( -name claude -o -name claude.exe \) \
      2>/dev/null | head -n 1
  )"
  if [ -n "$candidate" ]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  find / \
    \( -path /dev -o -path /proc -o -path /run -o -path /sys \) -prune -o \
    -type f \( -name claude -o -name claude.exe \) -print \
    2>/dev/null | head -n 1
}

CLAUDE_BIN=""
for i in 1 2 3 4 5; do
  CLAUDE_BIN="$(find_claude_binary || true)"
  if [ -n "$CLAUDE_BIN" ]; then
    chmod +x "$CLAUDE_BIN" 2>/dev/null || true
    ln -sfn "$CLAUDE_BIN" "$CLAUDE_CLI_LINK"
    echo "Linked claude binary: $CLAUDE_BIN -> $CLAUDE_CLI_LINK"
    break
  fi

  echo "Waiting for claude binary... (attempt $i)"
  sleep 1
done

if [ -z "$CLAUDE_BIN" ]; then
  echo "WARNING: No claude binary found after retries"
fi

exec "$@"
