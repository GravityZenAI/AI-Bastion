#!/bin/bash
# AI-Bastion — Uninstaller
# Removes AI-Bastion data, canary tokens, and stops monitors.
# Does NOT remove system packages (nftables, stubby, auditd).
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

AGENT_DIR="${AGENT_DATA_DIR:-$HOME/.openclaw}"
BASTION_DATA="$HOME/.ai-bastion"

echo "╔══════════════════════════════════════════════════╗"
echo "║       AI-Bastion 🏰 — Uninstaller               ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "This will remove:"
echo "  • AI-Bastion data directory ($BASTION_DATA)"
echo "  • Canary token files"
echo "  • Security rules addon from agent directory"
echo "  • Stop running monitors"
echo ""
echo "This will NOT remove:"
echo "  • System packages (nftables, stubby, auditd, inotify-tools)"
echo "  • nftables rules (flush manually: sudo nft flush ruleset)"
echo "  • System hardening changes (umask, core dumps)"
echo ""
read -p "Proceed? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Stop monitors
echo "[*] Stopping monitors..."
if [ -f "$BASTION_DATA/.fortress-pids" ]; then
    read -ra PIDS < "$BASTION_DATA/.fortress-pids"
    for pid in "${PIDS[@]}"; do
        kill "$pid" 2>/dev/null || true
    done
fi

# Remove canary tokens
echo "[*] Removing canary tokens..."
rm -rf "$AGENT_DIR/canary" 2>/dev/null || true
rm -f "$AGENT_DIR/.credentials_backup" 2>/dev/null || true

# Remove security rules addon
echo "[*] Removing security rules addon..."
rm -f "$AGENT_DIR/ai-bastion-security-rules.xml" 2>/dev/null || true

# Remove AI-Bastion data
echo "[*] Removing AI-Bastion data..."
rm -rf "$BASTION_DATA" 2>/dev/null || true

echo ""
echo "[✅] AI-Bastion uninstalled."
echo ""
echo "Manual cleanup if desired:"
echo "  • Remove nftables rules: sudo nft flush ruleset"
echo "  • Remove stubby: sudo apt remove stubby"
echo "  • Remove umask line from ~/.bashrc"
echo "  • Remove core dump lines from /etc/security/limits.conf"
