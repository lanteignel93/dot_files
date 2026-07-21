#!/bin/bash
# ssh-connect — fzf picker over ~/.ssh/config hosts, auto-auth.
# Uses ssh keys if the server accepts them; falls back to sshpass with
# SSH_PASS from ~/.config/vpn-ssh/secrets (chmod 600, never in a repo).
#   ssh-connect            pick a host interactively
#   ssh-connect <host>     connect straight to <host>

set -euo pipefail

SECRETS="$HOME/.config/vpn-ssh/secrets"
EXCLUDE='github|^\*'   # non-server Host entries to hide from the picker

host="${1:-}"
if [[ -z "$host" ]]; then
    host=$(awk '/^Host / {for (i=2; i<=NF; i++) print $i}' ~/.ssh/config \
        | grep -Ev "$EXCLUDE" \
        | fzf --prompt="ssh > " --height=40% --reverse \
              --preview 'ssh -G {} 2>/dev/null | grep -E "^(hostname|user|port) "' \
              --preview-window=down:3:wrap) || exit 130
fi

# Try key auth first (BatchMode fails fast instead of prompting)
if ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" true 2>/dev/null; then
    exec ssh "$host"
fi

# Fall back to password auth via sshpass
if ! command -v sshpass >/dev/null; then
    echo "ssh-connect: key auth failed and sshpass is not installed" >&2
    echo "  install it:      sudo apt install sshpass" >&2
    echo "  or better, fix keys: ssh-copy-id $host" >&2
    exit 1
fi

[[ -r "$SECRETS" ]] || { echo "ssh-connect: missing $SECRETS" >&2; exit 1; }
perms=$(stat -c '%a' "$SECRETS")
[[ "$perms" == "600" ]] || { echo "ssh-connect: $SECRETS must be chmod 600 (is $perms)" >&2; exit 1; }
# shellcheck source=/dev/null
source "$SECRETS"
[[ -n "${SSH_PASS:-}" && "$SSH_PASS" != "CHANGEME" ]] \
    || { echo "ssh-connect: set SSH_PASS in $SECRETS" >&2; exit 1; }

SSHPASS="$SSH_PASS" exec sshpass -e ssh "$host"
