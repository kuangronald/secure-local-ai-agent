#!/usr/bin/env fish
# Scout profile: web search ON, vault memory OFF.
# Run after main-profile.fish. Cloning copies the lockdown settings,
# so memory has to be explicitly cut off afterwards.

hermes profile create scout --clone
mkdir -p $HOME/scout-workspace/no-vault

# Memory OFF. memory_enabled=false alone is NOT enough: the cloned
# Obsidian plugin keeps prefetching. Point it at an empty directory.
hermes -p scout config set memory.memory_enabled false
hermes -p scout config set memory.obsidian.vault_path $HOME/scout-workspace/no-vault
hermes -p scout config set memory.obsidian.prefetch false

# Writes only to its own workspace
hermes -p scout config set HERMES_WRITE_SAFE_ROOT $HOME/scout-workspace

# Same toolset as main, but web enabled
hermes -p scout config set agent.disabled_toolsets '["browser", "browser-use", "code_execution", "delegation", "image_gen", "connections"]'

# Search only. No extract backend. Fail closed: no silent fallback providers.
hermes -p scout config set web.search_backend ddgs
hermes -p scout config set web.keyless_fallback false
hermes -p scout config set web.keyless_rescue false

# Main deny list plus the vault
hermes -p scout config set approvals.deny '["sudo *", "*systemctl*", "*tailscale*", "*ufw*", "*pacman*", "*ssh *", "*curl*", "*wget*", "*python*", "*nc *", "*ncat*", "*socat*", "*scp *", "*rsync*", "*git clone*", "*git push*", "*/dev/tcp*", "*ObsidianVault*"]'

hermes -p scout config set security.allow_lazy_installs false

hermes -p scout config get web
echo "Now verify: in herm-web, ask something only the vault knows. It must NOT recall it."
