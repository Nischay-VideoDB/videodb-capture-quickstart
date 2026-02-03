---
description: Get all context (screen + audio) from recording
---

Fetch and summarize all context from the recording via MCP resource.

## MCP Resource

Fetch `context://all/recent` from the `pair-programmer` server.

## Response

Provide a concise summary of:
- What's visible on screen (recent screen descriptions)
- What's being said (mic transcriptions)
- What's playing (system audio)
- Overall activity/situation

Keep summary brief unless user asks for details.
