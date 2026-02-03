---
description: Start or stop screen/audio recording with optional runtime config
---

Control recording with optional configuration override.

## Step 1: Check if Ready

Read `.claude/skills/pair-programmer/config.json` to check:
- `setup` is `true`
- `videodb_api_key` exists
- `recorder_port` (default: 8899)

Then check if recorder is running on that port:

```bash
lsof -i :$PORT >/dev/null 2>&1 && echo "RUNNING" || echo "NOT_RUNNING"
```

**Decision:**
- **Config exists with `setup: true` AND recorder is RUNNING** → Skip to Step 2 immediately
- **Config missing or `setup: false`** → Run `/record-config`, then continue to Step 2
- **Config OK but recorder NOT_RUNNING** → Run `bash .claude/hooks/start-recorder.sh`, then continue to Step 2

## Step 2: Start/Stop Recording

## Start Recording

Opens picker to select screen and audio sources.

```bash
node .claude/skills/pair-programmer/recorder-control.js start
```

### With Custom Indexing Config

```bash
node .claude/skills/pair-programmer/recorder-control.js start --config '<JSON>'
```

## Stop Recording

```bash
node .claude/skills/pair-programmer/recorder-control.js stop
```

---

## Runtime Config Override

Override default indexing settings for this recording session only.

### Format

```json
{
  "visual": {
    "enabled": true,
    "prompt": "Custom prompt for screen analysis",
    "batch_time": 5,
    "frame_count": 2
  },
  "system_audio": {
    "enabled": true,
    "prompt": "Custom prompt for system audio",
    "batch_type": "sentence",
    "batch_value": 3
  },
  "mic": {
    "enabled": true,
    "prompt": "Custom prompt for mic",
    "batch_type": "sentence",
    "batch_value": 3
  }
}
```

**Only include fields you want to override** - others use defaults from config.json.

### Visual Options

| Option | Type | Description |
|--------|------|-------------|
| `enabled` | boolean | Enable/disable screen indexing |
| `prompt` | string | AI prompt for analyzing screen content |
| `batch_time` | number | Seconds between screen captures |
| `frame_count` | number | Number of frames per batch |

### Audio Options (system_audio & mic)

| Option | Type | Description |
|--------|------|-------------|
| `enabled` | boolean | Enable/disable audio indexing |
| `prompt` | string | AI prompt for audio analysis |
| `batch_type` | string | "sentence" or "time" |
| `batch_value` | number | Sentences or seconds per batch |

---

## User Intent Examples

| User Says | Action |
|-----------|--------|
| "start recording" | `start` - picker opens for source selection |
| "record with focus on code" | `start --config '{"visual":{"prompt":"Focus on code"}}'` |
| "disable mic indexing" | `start --config '{"mic":{"enabled":false}}'` |
| "stop recording" | `stop` |

---

## Examples

### Default (picker selects sources)
```bash
node .claude/skills/pair-programmer/recorder-control.js start
```

### Code-focused prompt
```bash
node .claude/skills/pair-programmer/recorder-control.js start --config '{"visual":{"prompt":"Focus on code changes and errors"}}'
```

### Fast capture for debugging
```bash
node .claude/skills/pair-programmer/recorder-control.js start --config '{"visual":{"batch_time":3,"prompt":"Watch for errors"}}'
```

### Disable mic indexing
```bash
node .claude/skills/pair-programmer/recorder-control.js start --config '{"mic":{"enabled":false}}'
```

---

## Response

- **Start success**: Confirm recording started, mention what's being captured
- **Stop success**: Report duration
- **Error**: Show error message
