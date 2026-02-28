#!/bin/bash
# AI-Bastion — Layer 4: Network Connection Monitor
# Monitors outgoing connections for suspicious destinations.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

LOG_DIR="${LOG_DIR:-$HOME/.ai-bastion/logs}"
LOG="$LOG_DIR/network-monitor.log"
BLOCKED_IPS_FILE="$BASTION_ROOT/configs/blocked-ips.txt"
INTERVAL="${NETWORK_CHECK_INTERVAL:-60}"
MAX_NODE_CONNECTIONS="${MAX_AGENT_CONNECTIONS:-20}"

mkdir -p "$LOG_DIR"

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 4: Network Monitor"
echo "═══════════════════════════════════════════════════"

# --- Load blocked IP ranges ---
BLOCKED_RANGES=()
if [ -f "$BLOCKED_IPS_FILE" ]; then
    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        BLOCKED_RANGES+=("$line")
    done < "$BLOCKED_IPS_FILE"
else
    BLOCKED_RANGES=("91.92.242")  # ClawHavoc C2 default
fi

echo "[*] Monitoring network every ${INTERVAL}s (${#BLOCKED_RANGES[@]} blocked ranges)"
echo "[$(date -Is)] Network monitor started" >> "$LOG"

# --- Monitor loop ---
while true; do
    CONNECTIONS=$(ss -tunp 2>/dev/null || true)

    # Check for blocked IP ranges
    for range in "${BLOCKED_RANGES[@]}"; do
        if echo "$CONNECTIONS" | grep -q "$range"; then
            ALERT="[$(date -Is)] 🚨 CONNECTION TO BLOCKED IP: $range"
            echo "$ALERT" >> "$LOG"
            echo "$ALERT" >&2
            notify-send -u critical "🚨 AI-BASTION: Blocked IP" \
                "Connection to $range detected!" 2>/dev/null || true

            SOAR_SCRIPT="$BASTION_ROOT/layers/06-soar-response/auto-response.sh"
            [ -x "$SOAR_SCRIPT" ] && bash "$SOAR_SCRIPT" 2
        fi
    done

    # Check for unusual connection count from agent process
    NODE_CONNECTIONS=$(echo "$CONNECTIONS" | grep -c "node.*ESTAB" 2>/dev/null || echo "0")
    if [ "$NODE_CONNECTIONS" -gt "$MAX_NODE_CONNECTIONS" ]; then
        echo "[$(date -Is)] ⚠️ HIGH CONNECTION COUNT: agent has $NODE_CONNECTIONS connections" >> "$LOG"
    fi

    sleep "$INTERVAL"
done
