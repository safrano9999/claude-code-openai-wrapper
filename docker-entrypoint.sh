#!/bin/bash
set -e

# Locate the bundled claude binary from claude-agent-sdk
# Note: virtualenv hash changes on every build, so we search dynamically
CLAUDE_BIN=$(find /root -path "*/claude_agent_sdk/_bundled/claude" -type f 2>/dev/null | head -1 || true)

if [ -n "$CLAUDE_BIN" ]; then
  ln -sf "$CLAUDE_BIN" /usr/local/bin/claude-cli
  chmod +x "$CLAUDE_BIN"
  echo "Linked claude binary: $CLAUDE_BIN -> /usr/local/bin/claude-cli"
else
  echo "WARNING: No bundled claude binary found"
fi

exec poetry run uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload