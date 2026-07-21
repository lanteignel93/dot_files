#!/bin/bash
# vpn — connect NetExtender from the CLI (no GUI).
# Credentials live in ~/.config/vpn-ssh/secrets (chmod 600, never in a repo).
#   vpn          connect (foreground; Ctrl-C disconnects)
#   vpn -b       connect in background (log: ~/.local/log/netextender.log)
#   vpn status   show tunnel state
#   vpn off      disconnect a background session

set -euo pipefail

SECRETS="$HOME/.config/vpn-ssh/secrets"
LOG="$HOME/.local/log/netextender.log"

[[ -r "$SECRETS" ]] || { echo "vpn: missing $SECRETS" >&2; exit 1; }
perms=$(stat -c '%a' "$SECRETS")
[[ "$perms" == "600" ]] || { echo "vpn: $SECRETS must be chmod 600 (is $perms)" >&2; exit 1; }
# shellcheck source=/dev/null
source "$SECRETS"

for var in VPN_SERVER VPN_USER VPN_PASS VPN_DOMAIN; do
    [[ -n "${!var:-}" && "${!var}" != "CHANGEME" ]] \
        || { echo "vpn: set $var in $SECRETS" >&2; exit 1; }
done

is_up() { ip link show ppp0 &>/dev/null; }

case "${1:-}" in
    status)
        if is_up; then
            echo "VPN up:"
            ip -brief addr show ppp0
        else
            echo "VPN down"
        fi
        ;;
    off)
        if pkill -f '[n]etExtender'; then
            echo "VPN disconnected"
        else
            echo "vpn: no netExtender process found" >&2; exit 1
        fi
        ;;
    -b)
        is_up && { echo "vpn: already connected"; exit 0; }
        mkdir -p "$(dirname "$LOG")"
        echo "Connecting to $VPN_SERVER as $VPN_USER (background)..."
        sudo -b /usr/sbin/netExtender --auto-reconnect \
            -u "$VPN_USER" -p "$VPN_PASS" -d "$VPN_DOMAIN" "$VPN_SERVER" \
            >> "$LOG" 2>&1
        for _ in $(seq 1 30); do
            is_up && { echo "VPN up."; exit 0; }
            sleep 1
        done
        echo "vpn: tunnel did not come up in 30s — check $LOG" >&2
        exit 1
        ;;
    "")
        is_up && { echo "vpn: already connected"; exit 0; }
        echo "Connecting to $VPN_SERVER as $VPN_USER (Ctrl-C to disconnect)..."
        exec sudo /usr/sbin/netExtender --auto-reconnect \
            -u "$VPN_USER" -p "$VPN_PASS" -d "$VPN_DOMAIN" "$VPN_SERVER"
        ;;
    *)
        echo "usage: vpn [-b | status | off]" >&2
        exit 2
        ;;
esac
