# VideoDB Pair Programmer

AI pair programming with real-time screen and audio context.

---

## On Session Start

**When a new session starts and the user hasn't requested any specific action**, immediately run:

```bash
/record-config
```

This verifies setup, checks configuration, and starts the recorder if needed. Do this proactively before waiting for user input.

---

## Automatic Lifecycle

**Session Start**:
- Installs dependencies if needed (`npm install`)
- If config complete (`setup: true`) → starts recorder automatically
- If config incomplete → prompts to run `/record-config`

**Session End**: Stops the recorder app automatically.

**After `/record-config`**: Runs `start-recorder.sh` to start the app immediately.

---

## Commands

| Command | Description |
|---------|-------------|
| `/record` | Start/stop recording |
| `/record-status` | Check recording status |
| `/refresh-context` | Get all context (screen + audio) |
| `/refresh-screen` | Get screen descriptions only |
| `/refresh-audio` | Get audio transcriptions only |
| `/show-overlay` | Display overlay on screen |
| `/hide-overlay` | Hide the overlay |
| `/what-happened` | Summarize recent activity |
| `/record-config` | Configure API key and settings |

## First Time Setup

On first use (or if `setup: false` in config), run `/record-config` to:
1. Set your VideoDB API key
2. Configure optional settings (backend URL, webhook, port)

After setup, everything is automatic.

## Workflow

1. **Start recording**: `/record`
2. **Get context**: `/refresh-context`
3. **Stop recording**: `/record`

## MCP Resources

| Resource | Description |
|----------|-------------|
| `context://screen/recent` | Screen descriptions |
| `context://mic/recent` | Mic transcriptions |
| `context://system_audio/recent` | System audio |
| `context://all/recent` | All combined |
| `context://status` | Recording status |

## MCP Tools

| Tool | Description |
|------|-------------|
| `get_screen_context` | Get screen descriptions |
| `get_audio_context` | Get audio transcriptions |
| `get_recording_status` | Check status |
| `summarize_recent_activity` | Summarize recent |

## Files

```
vdb-pp-sdk-2/
├── package.json
├── .mcp.json
└── .claude/
    ├── hooks/
    │   ├── ensure-recorder.sh   # SessionStart: check config & start
    │   ├── start-recorder.sh    # Manual start after /record-config
    │   └── cleanup-recorder.sh  # SessionEnd: stop
    ├── settings.json            # Hook configuration
    ├── commands/                # Slash commands
    └── skills/pair-programmer/
        ├── config.json          # Configuration (setup flag + settings)
        ├── recorder-app.js      # Electron app
        ├── recorder-control.js  # CLI controller
        └── ui/
```
