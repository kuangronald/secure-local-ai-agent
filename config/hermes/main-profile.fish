#!/usr/bin/env fish
# Main Hermes profile: memory ON, web OFF, locked down.
# Assumes the model is already configured with `hermes model`
# (Custom endpoint http://127.0.0.1:8081/v1, Chat Completions, reasoning disabled).

mkdir -p $HOME/hermes-workspace $HOME/ObsidianVault/Memory/Hermes $HOME/ObsidianVault/Knowledge $HOME/ObsidianVault/Daily

# Approvals: a human answers every flagged command; unattended runs are denied
hermes config set approvals.mode manual
hermes config set approvals.timeout 120
hermes config set approvals.cron_mode deny
hermes config set approvals.single_query_mode deny
hermes config set approvals.unattended_mode deny

# Commands that never run, even if approved by accident
hermes config set approvals.deny '["sudo *", "*systemctl*", "*tailscale*", "*ufw*", "*pacman*", "*ssh *", "*curl*", "*wget*", "*python*", "*nc *", "*ncat*", "*socat*", "*scp *", "*rsync*", "*git clone*", "*git push*", "*/dev/tcp*"]'

# Reduce the toolset; no web access in this profile
hermes config set agent.disabled_toolsets '["browser", "browser-use", "code_execution", "delegation", "image_gen", "connections", "web"]'

# Network and install restrictions
hermes config set security.allow_private_urls false
hermes config set security.allow_lazy_installs false

# File-writing tools may only write here
hermes config set HERMES_WRITE_SAFE_ROOT "$HOME/hermes-workspace:$HOME/ObsidianVault:$HOME/.hermes"
chmod 600 $HOME/.hermes/.env

# Obsidian memory (plugin: https://github.com/Xore/hermes-obsidian-memory)
hermes config set memory.memory_enabled true
hermes config set memory.provider obsidian
hermes config set memory.obsidian.vault_path $HOME/ObsidianVault
hermes config set memory.obsidian.memory_dir Memory/Hermes
hermes config set memory.obsidian.recall_dirs Memory,Knowledge
hermes config set memory.obsidian.daily_dir Daily
# Prefetch: search memory on every message (smaller models don't search on their own)
hermes config set memory.obsidian.prefetch true

# The installer may enable an always-on gateway service
systemctl --user disable --now hermes-gateway 2>/dev/null

hermes config check
