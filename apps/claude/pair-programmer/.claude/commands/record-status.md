---
description: Check recording status and buffer counts
---

Get the current recording status.

## Step 1: Run /record-config (REQUIRED)

**BEFORE doing anything else**, run:

```
/record-config
```

This ensures the recorder is configured and running.

**Only proceed to Step 2 after /record-config confirms ready.**

## Step 2: Get Status

```bash
node .claude/skills/pair-programmer/recorder-control.js status
```

## Output

- Recording state (active/inactive)
- Session ID (if recording)
- Duration (if recording)
- Buffer counts for screen, mic, system_audio

## Response

Report status in a concise format:
- If recording: "Recording active for Xs with Y context items"
- If not recording: "Not recording. X items in buffer from last session"
