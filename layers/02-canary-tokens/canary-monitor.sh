#!/bin/bash
# AI-Bastion — Layer 2: Canary Token Monitor
# Watches canary files for access. Alerts immediately on detection.
# Depends on: inotify-tools (MIT license)
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

AGENT_DIR="${AGENT_DATA_DIR:-$HOME/.openclaw}"
LOG_DIR="${LOG_DIR:-$HOME/.ai-bastion/logs}"
CANARY_LIST="$HOME/.ai-bastion/canary-locations.txt"
LOG="$LOG_DIR/canary-alerts.log"

mkdir -p "$LOG_DIR"

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 2: Canary Monitor"
echo "═══════════════════════════════════════════════════"

# --- Install inotify-tools if needed ---
if ! command -v inotifywait &>/dev/null; then
    echo "[*] Installing inotify-tools..."
    sudo apt-get install -y -qq inotify-tools 2>/dev/null || {
        echo "❌ Could not install inotify-tools. Install manually:"
        echo "   sudo apt-get install inotify-tools"
        exit 1
    }
fi

# --- Read canary file locations ---
CANARY_FILES=()
if [ -f "$CANARY_LIST" ]; then
    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        [ -f "$line" ] && CANARY_FILES+=("$line")
    done < "$CANARY_LIST"
else
    # Default locations
    CANARY_FILES=(
        "$AGENT_DIR/canary/.env.backup"
        "$AGENT_DIR/canary/passwords.txt"
        "$AGENT_DIR/.credentials_backup"
    )
fi

if [ ${#CANARY_FILES[@]} -eq 0 ]; then
    echo "❌ No canary files found. Run deploy-canaries.sh first."
    exit 1
fi

echo "[*] Monitoring ${#CANARY_FILES[@]} canary files..."
echo "[$(date -Is)] Canary monitor started — watching ${#CANARY_FILES[@]} files" >> "$LOG"

# --- Monitor each canary file ---
for file in "${CANARY_FILES[@]}"; do
    if [ -f "$file" ]; then
        (
            inotifywait -m -e access,open "$file" 2>/dev/null | while read -r dir event fname; do
                ALERT="[$(date -Is)] 🚨 CANARY TRIGGERED: $file was accessed! Event: $event"
                echo "$ALERT" >> "$LOG"
                echo "$ALERT" >&2

                # Desktop notification
                notify-send -u critical "🚨 AI-BASTION ALERT" \
                    "Canary file accessed: $(basename $file)" 2>/dev/null || true

                # Optional: trigger SOAR response
                SOAR_SCRIPT="$BASTION_ROOT/layers/06-soar-response/auto-response.sh"
                if [ -x "$SOAR_SCRIPT" ]; then
                    bash "$SOAR_SCRIPT" 1  # Elevate to ALERT level
                fi
            done
        ) &
        echo "  👁️ Watching: $(basename $file)"
    fi
done

echo ""
echo "[✅] Canary monitor active (PID: $$)"
echo "    Log: $LOG"
echo "    Press Ctrl+C to stop"

# Keep the script running
trap 'echo "[$(date -Is)] Canary monitor stopped" >> "$LOG"; kill 0' EXIT
wait
