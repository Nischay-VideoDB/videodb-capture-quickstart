---
description: Shortcut-triggered: analyze context and show result in overlay
---

The user triggered the assistant shortcut. Your job is to understand what they need, gather the right information, and respond via the overlay.

## CRITICAL RULE: ALL communication MUST go through the overlay

**The user CANNOT see your text output, tool calls, or console messages.** The ONLY thing the user sees is the overlay. If you don't call the overlay API, the user sees NOTHING.

- NEVER print or output a response directly — it is invisible to the user.
- EVERY status update, progress message, intermediate finding, and final answer MUST be sent via the overlay API.
- Call the overlay BEFORE each major step (so the user sees what you're doing) and AFTER you have your answer.
- If in doubt, call the overlay. Overcommunicating is always better than silence.

**Overlay command:**
`curl -s -X POST http://127.0.0.1:PORT/api/overlay/show -H "Content-Type: application/json" -d '{"text":"Your message"}'`

**Port:** From `.claude/skills/pair-programmer/config.json` → `recorder_port` (default 8899). Base: `http://127.0.0.1:PORT`.

---

## Workflow

### 1. Show a loading state immediately

Your FIRST action must be showing the overlay. Before any context fetch or reasoning:
`curl -s -X POST http://127.0.0.1:PORT/api/overlay/show -H "Content-Type: application/json" -d '{"loading":true}'`

### 2. Gather context (show overlay before each fetch)

Update overlay → fetch → repeat for each source you need:

`curl -s -X POST http://127.0.0.1:PORT/api/overlay/show -H "Content-Type: application/json" -d '{"text":"Reading your screen context..."}'`
Then: `curl -s http://127.0.0.1:PORT/api/context/screen`

`curl -s -X POST http://127.0.0.1:PORT/api/overlay/show -H "Content-Type: application/json" -d '{"text":"Checking mic and audio..."}'`
Then: `curl -s http://127.0.0.1:PORT/api/context/mic` and `curl -s http://127.0.0.1:PORT/api/context/system_audio`

Or fetch all at once: `curl -s http://127.0.0.1:PORT/api/context/all`

### 3. Analyze and iterate — don't settle on the first result

Read the context and figure out what the user needs. If the answer isn't obvious from the first pass, **keep trying**. You have multiple tools — use them in combination.

**Search past content:** Get `rtstream_id` values from `curl -s http://127.0.0.1:PORT/api/status` (field `rtstreams`). Then search:
`curl -s -X POST http://127.0.0.1:PORT/api/rtstream/search -H "Content-Type: application/json" -d '{"rtstream_id":"<id>","query":"keyword1 keyword2"}'`

Try multiple queries with different keywords. If "error message" returns nothing useful, try "stack trace", "exception", "failed", etc. Cast a wide net.

**Show overlay before every search attempt:**
- `{"text":"Searching for error logs..."}`
- `{"text":"Trying a different query — looking for stack traces..."}`
- `{"text":"Found something — digging deeper..."}`
- `{"text":"Checking audio context for more clues..."}`

### 4. Refine the indexing prompt when context lacks detail

If the context descriptions are too vague for what you need (e.g. screen context says "user is looking at code" but you need *what* code or *what error*), you can change what the vision/audio model focuses on going forward.

**Check current prompts:** Read `.claude/skills/pair-programmer/config.json` — the `visual_index.prompt`, `mic_index.prompt`, and `system_audio_index.prompt` fields show exactly what each indexing model is currently analyzing. This tells you why context may be missing specific details and helps you craft a targeted replacement.

**Update the prompt:** Get the recording status to find each stream's `scene_index_id`:
`curl -s http://127.0.0.1:PORT/api/status`
The `rtstreams` array has `rtstream_id`, `scene_index_id`, and `index_type` (`screen`, `mic`, or `system_audio`) for each stream.

Then call:
`curl -s -X POST http://127.0.0.1:PORT/api/rtstream/update-prompt -H "Content-Type: application/json" -d '{"rtstream_id":"<rtstream_id>","scene_index_id":"<scene_index_id>","prompt":"<new prompt>"}'`

This updates the prompt on the server **and** persists it to `config.json`, so it survives restarts. Subsequent indexing batches will use the new prompt.

**Tell the user via overlay** when you update a prompt: `{"text":"Updated screen analysis to focus on error messages. Will have better details shortly."}`

### 5. Show your final answer via overlay

Once you have what you need, send a clear, concise, actionable response:
`curl -s -X POST http://127.0.0.1:PORT/api/overlay/show -H "Content-Type: application/json" -d '{"text":"Your final answer here"}'`

This is mandatory. Never end without a final overlay call.

---

## CRITICAL RULE: NEVER ask for clarification in reply, Use Overlay to communicate

**The overlay is ONE-WAY. The user CANNOT reply to it.** Asking questions like "Would you like me to…?", "Let me know if…", "Should I…?" is completely useless — the user has no way to answer.

- **NEVER** end with a question or a prompt for user input.
- **NEVER** ask "Would you like me to do X?" or "Let me know when you're ready."
- **NEVER** present options or ask the user to choose.
- **ALWAYS** analyze the context fully and deliver a direct, complete answer.
- If the intent is ambiguous, make your best judgment from the available context (screen, mic, audio, search results) and give a concrete answer. Bias toward action over asking.
- The ONLY acceptable use of questions is rhetorical ones that you immediately answer yourself.

**Bad example:** "I see a pipeline diagram. Would you like me to create a Node.js POC? Let me know when you're ready!"
**Good example:** "Your diagram shows a Request → Server → Media Queue → Downloader → Location A/B pipeline. Here's how to implement it: [concrete steps]"

---

## Key principles

- **Overlay is mandatory.** Every single user-facing message — progress, status, or answer — must go through the overlay API. Direct text output is invisible.
- **Never ask — always answer.** The overlay is one-way. The user cannot reply. Deliver a direct, actionable response every time.
- **Be persistent.** Don't give up after one search or one context read. Try different queries, check different streams, and combine findings.
- **Communicate constantly.** Show what you're doing at each step via the overlay. The user should never wonder if the assistant is stuck.
- **Be concise in the final answer.** Progress updates can be brief status lines. The final overlay message should be clear and actionable.
