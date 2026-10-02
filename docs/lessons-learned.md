# Lessons Learned

Failure modes found by testing, in the order they were found. Each one changed the design.

## Security

### 1. The installer enabled an always-on agent service
The Hermes installer set up `hermes-gateway.service` to start at boot, even though messaging was skipped during setup. It ran the main profile (with memory and terminal access) in the background and made outbound connections to model-catalog and update servers.

**Found by:** `ps` showed a Hermes process started seconds after boot; the egress firewall showed its connections.
**Fix:** `systemctl --user disable --now hermes-gateway`.
**Lesson:** audit what an installer enables, not just what you asked for.

### 2. "Memory disabled" did not disable memory
The web-enabled `scout` profile was created by cloning the main profile, then set `memory.memory_enabled false`. It still recalled vault notes, because the Obsidian plugin and its prefetch setting were cloned too and kept running.

**Found by:** asking scout a question only the vault could answer. It answered and showed `Obsidian - recalled 2 memories`.
**Fix:** point scout's memory plugin at an empty directory (the plugin refuses to load without a vault).
**Lesson:** verify a control by trying to defeat it, not by reading the setting.

### 3. Search silently rerouted to an unconfigured provider
DuckDuckGo search was configured, but its Python package wasn't installed. With `keyless_fallback` and `keyless_rescue` on (the defaults), Hermes quietly sent every query to Exa instead, a provider that can also fetch full pages.

**Found by:** the egress firewall log showed connections to `mcp.exa.ai` at the exact time of each search, and none to DuckDuckGo.
**Fix:** disable both fallbacks so a broken backend fails closed; install the correct package.
**Lesson:** fallback behavior is a security setting.

### 4. "DuckDuckGo search" contacted seven search engines
The `ddgs` package is a metasearch library. It tried Brave, Mojeek, Startpage, Google, Yahoo, Wikipedia and Grokipedia.

**Found by:** after a deny-by-default rule was added, the firewall showed rejected connections to each engine.
**Fix:** allowlist only privacy-respecting engines (DuckDuckGo, Brave, Mojeek, Startpage, Wikipedia).
**Lesson:** a library's name does not tell you its network behavior. Observe first, then write rules.

### 5. "Deny" made blocked searches hang for 30 seconds
OpenSnitch's `deny` silently drops packets, so the client waited for a timeout on every blocked engine.

**Fix:** use `reject` for the catch-all rule. Same protection, instant failure.

### 6. The firewall rule had to survive updates
Hermes ships its own Python in a directory whose name includes a build date. An exact-path rule would silently stop matching after an update, leaving the agent unrestricted.

**Fix:** match the interpreter with a regex: `^/home/USERNAME/[.]hermes/tools/python-.*/bin/python`.

## Model reliability

### 7. The 9B guessed instead of checking memory
Asked "What's my project codename?", the 9B answered with the name of its working directory, confidently and wrongly. The fact was saved in memory; it never searched.

**Fix:** enable memory prefetch, so the plugin searches memory on every message and hands results to the model.

### 8. File edits went wrong, and the model reported success
On "check off this task", the 9B deleted the task, rewrote unrelated lines, and replaced the previous changelog entry instead of appending. It then reported "Done. Updated both files." The 35B handled appends cleanly and reported honestly, but also deleted the task instead of checking it off.

**Fix:** project files are in Git (`git diff` after every session). Checking off tasks moved to a deterministic Fish function, `pdone`, that changes only an exact single match.
**Lesson:** when two models fail the same instruction, stop prompting and write a script.

### 9. The agent edited files when asked only to read
Told to "re-read the prompt", the agent decided to "fix" earlier work and edited files twice. It also "quoted" an outdated version of its instructions from earlier in the conversation.

**Fix:** an explicit rule that only named commands may write files, plus fresh sessions after instruction changes.
**Lesson:** the files are the source of truth; the model's account of them is a draft.

### 10. Thinking mode broke tool calls
With reasoning enabled, Qwen 3.5 9B often printed tool calls as XML text inside its reasoning instead of executing them (a known llama.cpp issue).

**Fix:** disable reasoning in Hermes and on the server (`--chat-template-kwargs '{"enable_thinking":false}'`).

## Measurement

### 11. A long-context test measured the wrong thing
A 40K-token needle-in-a-haystack test passed quickly, but the UI had used RAG: it embedded the file and sent the model one chunk. The model never saw the long context.

**Found by:** the server log showed a ~500-token prompt.
**Fix:** enable full-context mode, then re-measure (67K tokens took 4.5 minutes to read; generation dropped from ~30 to ~17 tok/s).

### 12. Background jobs halved prompt speed
Open WebUI generated titles, tags and follow-up suggestions in parallel with each question. On a split GPU/RAM model, prompt processing measured 66 tok/s; with background jobs off, 206 tok/s.

## Operations

- **A stuck `pacman -Syu` held the package lock for 43 hours.** Check `pgrep -a pacman` before ever deleting a lock file.
- **Pasting multi-line `sudo` commands triggered a 10-minute lockout.** Extra lines went into the password prompt. Run `sudo -v` first.
- **A hand-started server held the port, so the service crash-looped,** while `curl` still answered from the old process. Check the service, not just the endpoint.
