# Design Decisions

| Decision | Why |
|---|---|
| llama.cpp with Vulkan instead of ROCm | The RX 6700 XT (gfx1031) is not officially supported by ROCm; Vulkan works without workarounds |
| Qwen 3.6 35B-A3B as default, Qwen 3.5 9B as backup | The 35B made clean edits and reported honestly where the 9B failed; the cost is ~1 minute per agent session and ~14GB system RAM |
| `--n-cpu-moe 26` | Largest number of expert layers on the GPU that leaves ~1.3GB VRAM free for the desktop |
| 128K context | Hermes needs at least 64K; 262K would leave no VRAM headroom |
| Reasoning disabled | Qwen 3.5 printed tool calls as text when thinking was on |
| Tailscale instead of port forwarding | Remote access without exposing any port to the internet |
| Hermes on the host with restrictions, not in Docker | Hermes' Docker backend skips its dangerous-command checks, and the vault must be reachable for memory |
| No messaging gateways | Bot chats on Telegram/Discord are not end-to-end encrypted, and a compromised account becomes a remote control for the agent |
| Separate `scout` profile for web access | Never combine private data, untrusted content and an outbound channel in one agent |
| Search only, no page extraction | Fetching arbitrary URLs is the easiest exfiltration channel |
| Keyless fallbacks off | A broken search backend must fail closed, not reroute to an unchosen provider |
| OpenSnitch with the UI on the laptop | Per-process egress control, managed remotely over Tailscale |
| `reject` instead of `deny` for the catch-all | Instant failure instead of 30-second timeouts |
| Regex process path in firewall rules | Exact paths break silently when the agent updates |
| User-written notes in `Knowledge/`, agent memories in `Memory/` | The agent's forget tool can only delete inside `Memory/` |
| Memory prefetch on | The model did not reliably search memory on its own |
| Git on agent-edited files; `pdone` script for checkboxes | Model edits must be reviewable and reversible; the hardest edit moved to deterministic code |
| Open WebUI background tasks off | They competed with real prompts and cut prompt speed by ~3x |
