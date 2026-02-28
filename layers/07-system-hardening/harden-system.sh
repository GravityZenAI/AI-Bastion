#!/bin/bash
# AI-Bastion — Layer 7: System Hardening
# OS-level security hardening for Linux hosts running AI agents.
# Requires: sudo
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "❌ This script requires root. Run with: sudo bash $0"
    exit 1
fi

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 7: System Hardening"
echo "═══════════════════════════════════════════════════"
echo ""

# --- 7A: Disable SSH if not needed ---
echo "[*] Checking SSH..."
if systemctl is-active ssh &>/dev/null 2>&1; then
    echo "  ⚠️  SSH is active."
    read -p "  Disable SSH? (y/N): " DISABLE_SSH
    if [[ "$DISABLE_SSH" =~ ^[Yy]$ ]]; then
        systemctl disable ssh 2>/dev/null || true
        systemctl stop ssh 2>/dev/null || true
        echo "  [✅] SSH disabled"
    else
        echo "  [⏭️] SSH left active (your choice)"
    fi
else
    echo "  [✅] SSH already disabled"
fi

# --- 7B: Restrictive home directory permissions ---
echo "[*] Setting home directory permissions..."
chmod 750 "$REAL_HOME"
echo "  [✅] $REAL_HOME set to 750"

# --- 7C: Restrictive umask ---
echo "[*] Configuring umask..."
BASHRC="$REAL_HOME/.bashrc"
if ! grep -q "umask 027" "$BASHRC" 2>/dev/null; then
    echo "" >> "$BASHRC"
    echo "# AI-Bastion: restrictive umask (new files not world-readable)" >> "$BASHRC"
    echo "umask 027" >> "$BASHRC"
    echo "  [✅] umask 027 added to .bashrc"
else
    echo "  [✅] umask 027 already configured"
fi

# --- 7D: Disable core dumps ---
echo "[*] Disabling core dumps..."
if ! grep -q "hard core 0" /etc/security/limits.conf 2>/dev/null; then
    echo "" >> /etc/security/limits.conf
    echo "# AI-Bastion: disable core dumps (can leak secrets)" >> /etc/security/limits.conf
    echo "* hard core 0" >> /etc/security/limits.conf
    echo "  [✅] Core dumps disabled in limits.conf"
else
    echo "  [✅] Core dumps already disabled"
fi

if ! grep -q "ulimit -c 0" "$BASHRC" 2>/dev/null; then
    echo "# AI-Bastion: disable core dumps" >> "$BASHRC"
    echo "ulimit -c 0" >> "$BASHRC"
fi

# --- 7E: Enable audit logging ---
echo "[*] Setting up audit logging..."
if ! command -v auditd &>/dev/null; then
    apt-get install -y -qq auditd 2>/dev/null || true
fi

if command -v auditd &>/dev/null; then
    systemctl enable auditd 2>/dev/null || true
    systemctl start auditd 2>/dev/null || true

    # Audit access to common agent directories
    AGENT_DIRS=("$REAL_HOME/.openclaw" "$REAL_HOME/.ai-bastion")
    for dir in "${AGENT_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            auditctl -w "$dir" -p rwa -k ai_agent_access 2>/dev/null || true
            echo "  [✅] Audit rule added for: $dir"
        fi
    done
else
    echo "  [⚠️] Could not install auditd"
fi

# --- Summary ---
echo ""
echo "═══════════════════════════════════════════════════"
echo "  [✅] Layer 7 (System Hardening) complete"
echo "═══════════════════════════════════════════════════"
echo "  • Home directory: 750"
echo "  • Umask: 027 (new files not world-readable)"
echo "  • Core dumps: disabled"
echo "  • Audit logging: active"
echo ""
echo "  Log out and back in for umask changes to take effect."
