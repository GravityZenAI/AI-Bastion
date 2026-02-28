#!/bin/bash
# AI-Bastion — Layer 1: Zero Trust Network (nftables)
# Configures granular firewall rules beyond basic UFW.
# Requires: sudo
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ "$EUID" -ne 0 ]; then
    echo "❌ This script requires root. Run with: sudo bash $0"
    exit 1
fi

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 1: Zero Trust Network"
echo "═══════════════════════════════════════════════════"
echo ""

# --- 1A: Install nftables if needed ---
if ! command -v nft &>/dev/null; then
    echo "[*] Installing nftables..."
    apt-get update -qq && apt-get install -y -qq nftables
fi

# --- 1B: Apply fortress rules ---
echo "[*] Applying nftables rules..."

nft flush ruleset 2>/dev/null || true

nft -f - << 'NFTABLES'
table inet ai_bastion {
    # Rate limiting to prevent brute force
    set rate_limit_set {
        type ipv4_addr
        flags dynamic,timeout
        timeout 1m
    }

    chain input {
        type filter hook input priority 0; policy drop;

        # Localhost always OK
        iif "lo" accept

        # Established connections
        ct state established,related accept

        # DROP invalid packets
        ct state invalid drop

        # Rate limit: max 10 new connections per minute per IP
        ct state new add @rate_limit_set { ip saddr limit rate 10/minute } accept

        # Log all denied traffic (for analysis)
        log prefix "[AI-Bastion BLOCKED] " drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;

        # BLOCK egress to known malicious IPs
        # Uncomment and add IPs as needed:
        # ip daddr { 91.92.242.0/24 } drop  # Example: ClawHavoc C2 range

        # Optional: log new outgoing connections
        # ct state new log prefix "[AI-Bastion EGRESS] "
    }
}
NFTABLES

echo "[✅] nftables fortress rules applied"

# --- 1C: Load blocked IPs if available ---
BLOCKED_IPS_FILE="$BASTION_ROOT/configs/blocked-ips.txt"
if [ -f "$BLOCKED_IPS_FILE" ]; then
    echo "[*] Loading blocked IP list..."
    BLOCK_COUNT=0
    while IFS= read -r line; do
        [[ "$line" =~ ^#  ]] && continue
        [[ -z "$line" ]] && continue
        nft add rule inet ai_bastion output ip daddr "$line" drop 2>/dev/null && BLOCK_COUNT=$((BLOCK_COUNT + 1))
    done < "$BLOCKED_IPS_FILE"
    echo "[✅] Blocked $BLOCK_COUNT IP ranges"
fi

# --- 1D: Enable nftables service ---
systemctl enable nftables 2>/dev/null || true

echo ""
echo "[✅] Layer 1 (nftables) complete"
echo "    Policy: default DROP inbound, ACCEPT outbound"
echo "    Rate limit: 10 new connections/minute per IP"
echo "    Verify with: sudo nft list ruleset"
