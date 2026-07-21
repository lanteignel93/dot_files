#!/bin/bash
# vpn — connect NetExtender 10.3+ (nxcli + NEService daemon) from the CLI.
# Credentials live in ~/.config/vpn-ssh/secrets (chmod 600, never in a repo).
# The root NEService daemon owns the tunnel: no sudo needed, connect returns
# and the tunnel persists until 'vpn off'.
#   vpn          connect (approve the MFA push on your phone)
#   vpn -b       same as 'vpn' (kept for muscle memory)
#   vpn status   show tunnel state
#   vpn off      disconnect

set -euo pipefail

SECRETS="$HOME/.config/vpn-ssh/secrets"

[[ -r "$SECRETS" ]] || { echo "vpn: missing $SECRETS" >&2; exit 1; }
perms=$(stat -c '%a' "$SECRETS")
[[ "$perms" == "600" ]] || { echo "vpn: $SECRETS must be chmod 600 (is $perms)" >&2; exit 1; }
# shellcheck source=/dev/null
source "$SECRETS"

for var in VPN_SERVER VPN_USER VPN_PASS VPN_DOMAIN; do
    [[ -n "${!var:-}" && "${!var}" != "CHANGEME" ]] \
        || { echo "vpn: set $var in $SECRETS" >&2; exit 1; }
done

is_up() {
    local out
    out=$(nxcli status 2>/dev/null || true)
    grep -qi "disconnected" <<<"$out" && return 1
    grep -qi "connected" <<<"$out"
}

case "${1:-}" in
    status)
        nxcli status
        ;;
    off)
        nxcli disconnect
        ;;
    ""|-b)
        is_up && { echo "vpn: already connected"; nxcli status; exit 0; }
        echo "Connecting to $VPN_SERVER as $VPN_USER (approve the MFA push)..."
        nxcli "$VPN_SERVER" -u "$VPN_USER" -p "$VPN_PASS" -d "$VPN_DOMAIN" \
            --always-trust
        ;;
    *)
        echo "usage: vpn [-b | status | off]" >&2
        exit 2
        ;;
esac
