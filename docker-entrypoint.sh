#!/bin/bash

# Locate the bundled claude binary from claude-agent-sdk
# Retry a few times because the virtualenv might not be immediately available
for i in 1 2 3 4 5; do
  CLAUDE_BIN=$(find /root -path "*/claude_agent_sdk/_bundled/claude" -type f 2>/dev/null | head -1)
  if [ -n "$CLAUDE_BIN" ]; then
    ln -sf "$CLAUDE_BIN" /usr/local/bin/claude-cli
    chmod +x "$CLAUDE_BIN"
    echo "Linked claude binary: $CLAUDE_BIN -> /usr/local/bin/claude-cli"
    break
  fi
  echo "Waiting for claude binary... (attempt $i)"
  sleep 1
done

if [ -z "$CLAUDE_BIN" ]; then
  echo "WARNING: No bundled claude binary found after retries"
fi

exec poetry run uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
