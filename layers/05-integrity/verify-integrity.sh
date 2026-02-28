#!/bin/bash
# AI-Bastion — Layer 5: Verify File Integrity
# Checks critical files against the SHA-256 baseline.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

BASTION_DATA="$HOME/.ai-bastion"
BASELINE="$BASTION_DATA/integrity-baseline.sha256"
LOG_DIR="${LOG_DIR:-$BASTION_DATA/logs}"
LOG="$LOG_DIR/integrity.log"
FAILED=0
CHECKED=0

mkdir -p "$LOG_DIR"

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 5: Integrity Verification"
echo "═══════════════════════════════════════════════════"
echo ""

if [ ! -f "$BASELINE" ]; then
    echo "❌ No baseline found at $BASELINE"
    echo "   Run create-baseline.sh first."
    exit 1
fi

echo "[$(date -Is)] Running integrity check..." >> "$LOG"

while IFS= read -r line; do
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue

    EXPECTED_HASH=$(echo "$line" | awk '{print $1}')
    FILE_PATH=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ //')

    if [ -f "$FILE_PATH" ]; then
        CURRENT_HASH=$(sha256sum "$FILE_PATH" | awk '{print $1}')
        CHECKED=$((CHECKED + 1))

        if [ "$EXPECTED_HASH" != "$CURRENT_HASH" ]; then
            echo "  🚨 MODIFIED: $FILE_PATH"
            echo "[$(date -Is)] 🚨 INTEGRITY FAIL: $FILE_PATH has been MODIFIED!" >> "$LOG"
            notify-send -u critical "🚨 AI-BASTION: File Modified" \
                "$(basename $FILE_PATH) was changed!" 2>/dev/null || true
            FAILED=$((FAILED + 1))
        else
            echo "  ✅ OK: $(basename $FILE_PATH)"
        fi
    else
        echo "  🚨 MISSING: $FILE_PATH"
        echo "[$(date -Is)] 🚨 INTEGRITY FAIL: $FILE_PATH is MISSING!" >> "$LOG"
        FAILED=$((FAILED + 1))
        CHECKED=$((CHECKED + 1))
    fi
done < "$BASELINE"

echo ""
echo "═══════════════════════════════════════════════════"
if [ $FAILED -eq 0 ]; then
    echo "  ✅ All $CHECKED files intact"
    echo "[$(date -Is)] ✅ All $CHECKED files intact" >> "$LOG"
else
    echo "  🚨 $FAILED of $CHECKED files COMPROMISED!"
    echo "[$(date -Is)] 🚨 $FAILED files compromised!" >> "$LOG"
fi
echo "═══════════════════════════════════════════════════"

exit $FAILED
