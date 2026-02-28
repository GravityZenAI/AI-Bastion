#!/bin/bash
# AI-Bastion — Layer 6: SOAR Automated Response
# Security Orchestration, Automation and Response
# 4-level automated incident response system.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1091
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

LOG_DIR="${LOG_DIR:-$HOME/.ai-bastion/logs}"
LOG="$LOG_DIR/soar.log"
THREAT_LEVEL="${1:-0}"

mkdir -p "$LOG_DIR"

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 6: SOAR Response"
echo "  Threat Level: $THREAT_LEVEL"
echo "═══════════════════════════════════════════════════"

case "$THREAT_LEVEL" in
    0)
        echo "[$(date -Is)] [LEVEL 0] Normal operation" >> "$LOG"
        echo ""
        echo "  ✅ Level 0: Normal operation"
        echo "  All monitors running. No threats detected."
        ;;

    1)
        echo "[$(date -Is)] [LEVEL 1] ALERT — Increasing monitoring" >> "$LOG"
        echo ""
        echo "  ⚠️ Level 1: ALERT"
        echo "  Increasing monitoring frequency."
        notify-send -u normal "⚠️ AI-Bastion Security Alert" \
            "Threat level elevated to 1 — increased monitoring" 2>/dev/null || true
        ;;

    2)
        echo "[$(date -Is)] [LEVEL 2] CONTAIN — Isolating threat" >> "$LOG"
        echo ""
        echo "  🚨 Level 2: CONTAINMENT"
        echo "  Stopping AI agent and restricting network..."

        # Stop the AI agent
        if command -v openclaw &>/dev/null; then
            openclaw stop 2>/dev/null || true
            echo "  [*] OpenClaw stopped"
        fi

        # Kill common agent processes
        pkill -f "node.*openclaw" 2>/dev/null || true
        pkill -f "node.*gateway" 2>/dev/null || true

        # Restrict outgoing network (keep DNS)
        if [ "$EUID" -eq 0 ] || sudo -n true 2>/dev/null; then
            sudo ufw deny out to any 2>/dev/null || true
            sudo ufw allow out 53 2>/dev/null || true
            echo "  [*] Network restricted (outbound blocked, DNS allowed)"
        else
            echo "  [!] Cannot restrict network without sudo"
        fi

        notify-send -u critical "🚨 AI-BASTION: CONTAINMENT" \
            "Agent stopped. Network restricted." 2>/dev/null || true
        echo "[$(date -Is)] [LEVEL 2] Agent stopped, network restricted" >> "$LOG"
        ;;

    3)
        echo "[$(date -Is)] [LEVEL 3] LOCKDOWN — Emergency shutdown" >> "$LOG"
        echo ""
        echo "  🚨🚨 Level 3: FULL LOCKDOWN"
        echo "  Emergency shutdown of all AI services..."

        # Kill everything AI-related
        if command -v openclaw &>/dev/null; then
            openclaw stop 2>/dev/null || true
        fi
        pkill -f "node.*openclaw" 2>/dev/null || true
        pkill -f "node.*gateway" 2>/dev/null || true
        pkill -f ollama 2>/dev/null || true

        # Block all outbound network
        if [ "$EUID" -eq 0 ] || sudo -n true 2>/dev/null; then
            sudo ufw deny out to any 2>/dev/null || true
            echo "  [*] ALL outbound network blocked"
        fi

        # Emergency backup of logs
        BACKUP_DIR="$HOME/.ai-bastion/logs-backup-$(date +%Y%m%d%H%M)"
        cp -r "$LOG_DIR" "$BACKUP_DIR" 2>/dev/null || true
        echo "  [*] Logs backed up to: $BACKUP_DIR"

        notify-send -u critical "🚨🚨 AI-BASTION: LOCKDOWN" \
            "ALL AI services stopped. Network blocked." 2>/dev/null || true
        echo "[$(date -Is)] [LEVEL 3] FULL LOCKDOWN ACTIVATED" >> "$LOG"
        ;;

    restore)
        echo "[$(date -Is)] [RESTORE] Restoring normal operation" >> "$LOG"
        echo ""
        echo "  🔄 Restoring normal operation..."

        # Re-enable outbound network
        if [ "$EUID" -eq 0 ] || sudo -n true 2>/dev/null; then
            sudo ufw default allow outgoing 2>/dev/null || true
            echo "  [*] Outbound network restored"
        fi

        echo "  [✅] System restored to normal."
        echo "  [*] Restart your AI agent manually when ready."
        ;;

    *)
        echo "Usage: $0 {0|1|2|3|restore}"
        echo ""
        echo "  0       Normal operation"
        echo "  1       Alert — increase monitoring"
        echo "  2       Contain — stop agent, restrict network"
        echo "  3       Lockdown — kill everything, block network"
        echo "  restore Restore normal operation after incident"
        exit 1
        ;;
esac
