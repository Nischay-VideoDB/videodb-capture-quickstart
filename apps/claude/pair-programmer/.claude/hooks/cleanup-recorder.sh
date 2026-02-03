#!/bin/bash
# cleanup-recorder.sh - SessionEnd hook to stop recorder when session ends

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
CONFIG_FILE="$PROJECT_DIR/.claude/skills/pair-programmer/config.json"

# Read port from config (default 8899)
PORT=$(jq -r '.recorder_port // 8899' "$CONFIG_FILE" 2>/dev/null)

# Find and kill process on the port
PID=$(lsof -ti :$PORT 2>/dev/null)

if [ -n "$PID" ]; then
  kill $PID 2>/dev/null
  echo "Stopped recorder (PID: $PID, port: $PORT)" >&2
fi

exit 0
