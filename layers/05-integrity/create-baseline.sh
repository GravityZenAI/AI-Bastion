#!/bin/bash
# AI-Bastion — Layer 5: Create Integrity Baseline
# Generates SHA-256 hashes of critical files for tamper detection.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1091
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

AGENT_DIR="${AGENT_DATA_DIR:-$HOME/.openclaw}"
BASTION_DATA="$HOME/.ai-bastion"
INTEGRITY_FILE="$BASTION_DATA/integrity-baseline.sha256"

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 5: Create Integrity Baseline"
echo "═══════════════════════════════════════════════════"
echo ""

mkdir -p "$BASTION_DATA"

# --- Generate baseline ---
echo "# AI-Bastion Integrity Baseline" > "$INTEGRITY_FILE"
echo "# Generated: $(date -Is)" >> "$INTEGRITY_FILE"
echo "# If any hash changes without authorization, the system may be compromised" >> "$INTEGRITY_FILE"
echo "" >> "$INTEGRITY_FILE"

FILE_COUNT=0

# Critical agent files
CRITICAL_FILES=(
    "$AGENT_DIR/openclaw.json"
    "$AGENT_DIR/SOUL.md"
    "$AGENT_DIR/IDENTITY.md"
    "$AGENT_DIR/ai-bastion-security-rules.xml"
)

# Add any additional files from config
if [ -n "${INTEGRITY_EXTRA_FILES:-}" ]; then
    IFS=',' read -ra EXTRA <<< "$INTEGRITY_EXTRA_FILES"
    CRITICAL_FILES+=("${EXTRA[@]}")
fi

for f in "${CRITICAL_FILES[@]}"; do
    if [ -f "$f" ]; then
        sha256sum "$f" >> "$INTEGRITY_FILE"
        echo "  ✅ Baselined: $(basename $f)"
        FILE_COUNT=$((FILE_COUNT + 1))
    else
        echo "  ⏭️  Skipped (not found): $(basename $f)"
    fi
done

# Make baseline read-only
chmod 444 "$INTEGRITY_FILE"

echo ""
echo "[✅] Integrity baseline created: $INTEGRITY_FILE"
echo "    Files baselined: $FILE_COUNT"
echo ""
echo "    To verify integrity later:"
echo "    bash $(dirname $0)/verify-integrity.sh"
echo ""
echo "    To update baseline (after authorized changes):"
echo "    chmod 644 $INTEGRITY_FILE && bash $0"
