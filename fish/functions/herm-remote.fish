function herm-remote --description 'Attach to the persistent hermes tmux session on the desktop'
    # Replace "desktop" with your desktop's Tailscale hostname
    ssh -t desktop tmux new -A -s hermes
end
