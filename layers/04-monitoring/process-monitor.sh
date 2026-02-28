#!/bin/bash
# AI-Bastion — Layer 4: Suspicious Process Monitor
# Detects processes that should not be running alongside AI agents.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1091
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

LOG_DIR="${LOG_DIR:-$HOME/.ai-bastion/logs}"
LOG="$LOG_DIR/process-monitor.log"
PATTERNS_FILE="$BASTION_ROOT/configs/suspicious-processes.txt"
INTERVAL="${PROCESS_CHECK_INTERVAL:-30}"

mkdir -p "$LOG_DIR"

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 4: Process Monitor"
echo "═══════════════════════════════════════════════════"

# --- Load suspicious patterns ---
SUSPICIOUS_PATTERNS=()
if [ -f "$PATTERNS_FILE" ]; then
    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        SUSPICIOUS_PATTERNS+=("$line")
    done < "$PATTERNS_FILE"
else
    # Default patterns
    SUSPICIOUS_PATTERNS=(
        "nc -l"                           # netcat listener (reverse shell)
        "ncat"                            # nmap netcat
        "socat"                           # socket cat
        "/dev/tcp"                        # bash reverse shell
        "base64.*decode"                  # suspicious decoding
        "curl.*|.*sh"                     # download and execute
        "wget.*|.*sh"                     # download and execute
        "python.*-c.*import.*socket"      # Python reverse shell
        "bore.pub"                        # tunneling (used in ClawHavoc)
    )
fi

echo "[*] Monitoring ${#SUSPICIOUS_PATTERNS[@]} suspicious patterns every ${INTERVAL}s"
echo "[$(date -Is)] Process monitor started" >> "$LOG"

# --- Monitor loop ---
while true; do
    for pattern in "${SUSPICIOUS_PATTERNS[@]}"; do
        # shellcheck disable=SC2009
        FOUND=$(ps aux 2>/dev/null | grep -i "$pattern" | grep -v grep | grep -v "process-monitor" || true)
        if [ -n "$FOUND" ]; then
            ALERT="[$(date -Is)] 🚨 SUSPICIOUS PROCESS: pattern='$pattern' | $FOUND"
            echo "$ALERT" >> "$LOG"
            echo "$ALERT" >&2

            notify-send -u critical "🚨 AI-BASTION: Suspicious Process" \
                "Pattern detected: $pattern" 2>/dev/null || true

            # Optional: trigger SOAR response
            SOAR_SCRIPT="$BASTION_ROOT/layers/06-soar-response/auto-response.sh"
            if [ -x "$SOAR_SCRIPT" ]; then
                bash "$SOAR_SCRIPT" 1
            fi
        fi
    done
    sleep "$INTERVAL"
done
