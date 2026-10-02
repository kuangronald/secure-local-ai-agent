# Runbook

## Daily use

| Task | Command |
|---|---|
| Agent with memory | `herm` |
| Web-search agent, no memory | `herm-web` |
| From the laptop | `herm-remote` (SSH into a persistent tmux session) |
| Detach from tmux | Ctrl+B, then D |
| Check off a project task | `pdone 'exact task text'` |
| Review agent edits | `git -C ~/ObsidianVault/Knowledge/Projects/YOUR-PROJECT diff` |
| Firewall UI (laptop) | `opensnitch-ui --socket "[::]:50051" &; disown` |

## Health checks

```fish
systemctl --user status llama-qwen35 --no-pager | head -3
curl -s http://127.0.0.1:8081/v1/models | grep -o '"id":"[^"]*"'
systemctl status opensnitchd --no-pager | head -3
pgrep -af "gateway run"; or echo "gateway stopped"
tailscale status
free -h
```

## Setup outline

### Model server
1. Build llama.cpp with `-DGGML_VULKAN=ON`.
2. Download a model into `~/ai/models/`.
3. Copy a unit from `config/systemd/` to `~/.config/systemd/user/`, then:
   ```fish
   systemctl --user daemon-reload
   systemctl --user enable --now llama-qwen35
   sudo loginctl enable-linger $USER
   ```
4. Tune `--n-cpu-moe`: lower it until total VRAM is ~1GB below the card's limit.

### Hermes
1. Install Hermes Agent and point it at `http://127.0.0.1:8081/v1` (Custom endpoint, Chat Completions, reasoning disabled).
2. Install the memory plugin into `~/.hermes/plugins/obsidian` and review its code.
3. Run `fish config/hermes/main-profile.fish`, then `fish config/hermes/scout-profile.fish`.
4. Disable the gateway if the installer enabled it: `systemctl --user disable --now hermes-gateway`.

### Egress firewall
```fish
sed -i "s/USERNAME/$USER/" config/opensnitch/rules/*.json
sudo -v
sudo cp config/opensnitch/rules/*.json /etc/opensnitchd/rules/
sudo systemctl restart opensnitchd
```

## Verification tests

| Control | Test | Pass |
|---|---|---|
| Memory | In `herm`, ask about a fact saved last session | Correct answer with "Obsidian - recalled" |
| Scout isolation | In `herm-web`, ask the same question | No recall |
| Egress | Run a search in `herm-web` and watch OpenSnitch | Allowlisted engines allowed; all other Hermes traffic rejected |
| Edits | Run a tracker command, then `git diff` | Only the intended lines change |

## Updating Hermes safely

1. Back up `~/.hermes` and the vault.
2. Disable firewall rule `002-hermes-deny-rest` (updates need GitHub).
3. `hermes update`, then `hermes doctor`.
4. Re-enable rule 002.
5. Re-run the verification tests. Check that the gateway service is still disabled.

## Switching models

```fish
# back to the 9B
systemctl --user disable --now llama-qwen35
systemctl --user enable --now llama-qwen
hermes model
hermes -p scout model
```
