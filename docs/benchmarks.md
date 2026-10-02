# Benchmarks

**Hardware:** AMD Radeon RX 6700 XT (12GB VRAM), AMD Ryzen 5 5600, 32GB DDR4, CachyOS.
**Server:** llama.cpp built with Vulkan, flash attention on, q8_0 KV cache, 128K context.

## Qwen 3.5 9B (Q5_K_M), fully on GPU

| Measurement | Result |
|---|---|
| VRAM at 64K / 128K context | 6.7 GB / 7.8 GB |
| Prompt processing | ~250 tok/s (67K-token prompt), up to ~400 tok/s on short prompts |
| Generation, short context | ~30 tok/s |
| Generation, 67K tokens of context | ~17 tok/s |
| Reading a 67K-token document | 4 min 27 s |

The 9B uses a hybrid attention design, so doubling context from 64K to 128K cost only ~1.1GB of VRAM.

## Qwen 3.6 35B-A3B (UD-Q4_K_M), split GPU + RAM

| `--n-cpu-moe` | Total VRAM | System RAM (model) |
|---|---|---|
| 32 | 7.85 GB | ~16.7 GB |
| 26 (chosen) | 10.7 GB | ~13.7 GB |

| Measurement | Result |
|---|---|
| Generation | 17.6–17.7 tok/s, steady |
| Prompt processing, with UI background jobs on | ~66 tok/s |
| Prompt processing, background jobs off | ~206–223 tok/s |
| Hermes first message (11,814-token system prompt) | 53 s to read, ~72 s total |
| Follow-up messages | seconds (prompt cached) |

## Agent edit test

Commands sent through a project-tracker prompt, results checked with `git diff`.

| Command | 9B | 35B |
|---|---|---|
| `log:` append a changelog line | Replaced the previous line; copied the command word into the file | Clean |
| `add task:` | — | Clean |
| `done:` check off a task | Deleted the task, damaged backticks on another line, claimed success | Deleted the task, reported it honestly |
