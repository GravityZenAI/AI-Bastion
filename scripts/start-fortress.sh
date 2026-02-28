#!/bin/bash
# AI-Bastion — Start All Security Layers
# Launches monitors and verifies integrity before starting your agent.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🛡️ AI-Bastion Fortress Starting..."
echo ""

# 1. Verify integrity
echo "[1/4] Verifying file integrity..."
bash "$BASTION_ROOT/layers/05-integrity/verify-integrity.sh" 2>/dev/null || {
    echo "  ⚠️ Integrity check failed or no baseline found. Continuing..."
}
echo ""

# 2. Start canary monitor
echo "[2/4] Activating canary token monitor..."
bash "$BASTION_ROOT/layers/02-canary-tokens/canary-monitor.sh" &
CANARY_PID=$!
echo ""

# 3. Start process monitor
echo "[3/4] Activating process monitor..."
bash "$BASTION_ROOT/layers/04-monitoring/process-monitor.sh" &
PROC_PID=$!
echo ""

# 4. Start network monitor
echo "[4/4] Activating network monitor..."
bash "$BASTION_ROOT/layers/04-monitoring/network-monitor.sh" &
NET_PID=$!
echo ""

echo "🛡️ ══════════════════════════════════════════"
echo "🛡️   AI-BASTION FORTRESS ACTIVE"
echo "🛡️   Canary monitor:  PID $CANARY_PID"
echo "🛡️   Process monitor: PID $PROC_PID"
echo "🛡️   Network monitor: PID $NET_PID"
echo "🛡️   SOAR response:   Armed (levels 0-3)"
echo "🛡️ ══════════════════════════════════════════"
echo ""
echo "  Now start your AI agent."
echo "  Press Ctrl+C to stop all monitors."

# Save PIDs for cleanup
BASTION_DATA="$HOME/.ai-bastion"
mkdir -p "$BASTION_DATA"
echo "$CANARY_PID $PROC_PID $NET_PID" > "$BASTION_DATA/.fortress-pids"

# Cleanup on exit
trap 'echo ""; echo "🛡️ Fortress stopped."; kill $CANARY_PID $PROC_PID $NET_PID 2>/dev/null; rm -f "$BASTION_DATA/.fortress-pids"' EXIT
wait
