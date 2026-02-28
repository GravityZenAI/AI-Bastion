#!/bin/bash
# AI-Bastion — Layer 2: Deploy Canary Tokens
# Creates trap files that detect intrusions. If an attacker or
# compromised agent reads these files, you know immediately.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

AGENT_DIR="${AGENT_DATA_DIR:-$HOME/.openclaw}"
CANARY_DIR="$AGENT_DIR/canary"
LOG_DIR="${LOG_DIR:-$HOME/.ai-bastion/logs}"

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 2: Deploy Canary Tokens"
echo "═══════════════════════════════════════════════════"
echo ""

mkdir -p "$CANARY_DIR"
mkdir -p "$LOG_DIR"

# --- Canary 1: Fake API keys file ---
# An attacker or compromised skill scanning for API keys will find this
cat > "$CANARY_DIR/.env.backup" << 'CANARY'
# BACKUP - DO NOT DELETE
OPENAI_API_KEY=sk-canary-DETECT-IF-THIS-IS-READ-alert
ANTHROPIC_API_KEY=sk-ant-canary-DETECT-IF-READ-alert
AWS_SECRET_KEY=canary-detect-exfiltration-attempt
STRIPE_SECRET_KEY=sk_live_canary_INTRUSION_DETECTED
CANARY
echo "[✅] Deployed canary: fake API keys (.env.backup)"

# --- Canary 2: Fake passwords file ---
# Attackers running credential harvesting will hit this
cat > "$CANARY_DIR/passwords.txt" << 'CANARY'
admin:canary-password-DETECT-IF-READ
root:canary-alert-INTRUSION-DETECTED
database:canary-trap-file-DO-NOT-USE
CANARY
echo "[✅] Deployed canary: fake passwords (passwords.txt)"

# --- Canary 3: Fake credentials in agent directory ---
# Tests if a compromised agent reads files it shouldn't
cat > "$AGENT_DIR/.credentials_backup" << 'CANARY'
# Emergency credentials backup
# WARNING: If an AI agent reads this file, it has been compromised
MASTER_TOKEN=canary-AGENT-COMPROMISED-alert
RECOVERY_KEY=canary-UNAUTHORIZED-ACCESS-detected
CANARY
echo "[✅] Deployed canary: fake credentials in agent directory"

# --- Set restrictive permissions ---
chmod 600 "$CANARY_DIR"/* 2>/dev/null
chmod 600 "$AGENT_DIR/.credentials_backup" 2>/dev/null

# --- Record canary locations ---
cat > "$HOME/.ai-bastion/canary-locations.txt" << EOF
# AI-Bastion Canary Token Locations
# Generated: $(date -Is)
# If any of these files are accessed, an intrusion is detected.
$CANARY_DIR/.env.backup
$CANARY_DIR/passwords.txt
$AGENT_DIR/.credentials_backup
EOF

echo ""
echo "[✅] Layer 2 (Canary Tokens) deployed"
echo "    3 canary files placed in strategic locations"
echo "    Locations saved to: $HOME/.ai-bastion/canary-locations.txt"
echo ""
echo "    Next: Start the canary monitor:"
echo "    bash $(dirname $0)/canary-monitor.sh &"
