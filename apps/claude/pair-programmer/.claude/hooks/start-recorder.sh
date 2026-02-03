#!/bin/bash
# start-recorder.sh - Manually start the recorder after config is set up
# Call this after running /record-config

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
CONFIG_FILE="$PROJECT_DIR/.claude/skills/pair-programmer/config.json"

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: config.json not found. Run /record-config first."
  exit 1
fi

# Check setup status
SETUP_DONE=$(jq -r '.setup // false' "$CONFIG_FILE" 2>/dev/null)
API_KEY=$(jq -r '.videodb_api_key // ""' "$CONFIG_FILE" 2>/dev/null)

if [ "$SETUP_DONE" != "true" ] || [ -z "$API_KEY" ] || [ "$API_KEY" == "null" ]; then
  echo "Error: Setup not complete. Run /record-config first."
  exit 1
fi

# Read port from config
PORT=$(jq -r '.recorder_port // 8899' "$CONFIG_FILE" 2>/dev/null)

# Check if already running
if lsof -i :$PORT >/dev/null 2>&1; then
  echo "✓ Recorder already running on port $PORT"
  exit 0
fi

# Install deps if needed (clean install to avoid extraneous packages)
if [ ! -d "$PROJECT_DIR/node_modules" ] || [ ! -f "$PROJECT_DIR/node_modules/.bin/electron" ]; then
  echo "Installing dependencies (this may take a minute for electron)..."
  cd "$PROJECT_DIR"
  rm -rf node_modules
  npm install
fi

# Start recorder
echo "Starting recorder..."
cd "$PROJECT_DIR"
nohup npm start > /tmp/videodb-recorder.log 2>&1 &

# Wait and verify (electron + tunnel can take a few seconds)
for i in 1 2 3 4 5; do
  sleep 2
  if lsof -i :$PORT >/dev/null 2>&1; then
    echo "✓ Recorder started on port $PORT"
    exit 0
  fi
done

echo "✗ Failed to start. Check /tmp/videodb-recorder.log"
tail -20 /tmp/videodb-recorder.log
exit 1
