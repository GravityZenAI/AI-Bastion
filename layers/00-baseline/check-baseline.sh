#!/bin/bash
# AI-Bastion — Layer 0: Baseline Security Check
# Verifies that existing defenses are active before adding new ones.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1091
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

AGENT_DIR="${AGENT_DATA_DIR:-$HOME/.openclaw}"
PASS=0
FAIL=0
WARN=0

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 0: Baseline Security Check"
echo "═══════════════════════════════════════════════════"
echo ""

check() {
    local name="$1"
    local status="$2" # pass, fail, warn
    local detail="$3"

    case "$status" in
        pass) echo "  ✅ $name — $detail"; PASS=$((PASS + 1)) ;;
        fail) echo "  ❌ $name — $detail"; FAIL=$((FAIL + 1)) ;;
        warn) echo "  ⚠️  $name — $detail"; WARN=$((WARN + 1)) ;;
    esac
}

# --- Firewall ---
if command -v ufw &>/dev/null; then
    if sudo ufw status 2>/dev/null | grep -q "active"; then
        check "Firewall (UFW)" "pass" "Active"
    else
        check "Firewall (UFW)" "fail" "Installed but NOT active. Run: sudo ufw enable"
    fi
else
    check "Firewall (UFW)" "warn" "Not installed. Run: sudo apt install ufw"
fi

# --- Agent data directory permissions ---
if [ -d "$AGENT_DIR" ]; then
    PERMS=$(stat -c %a "$AGENT_DIR" 2>/dev/null)
    if [ "$PERMS" = "700" ] || [ "$PERMS" = "750" ]; then
        check "Agent directory permissions" "pass" "$AGENT_DIR is $PERMS"
    else
        check "Agent directory permissions" "fail" "$AGENT_DIR is $PERMS (should be 700 or 750)"
    fi
else
    check "Agent directory permissions" "warn" "$AGENT_DIR does not exist"
fi

# --- Gateway binding ---
if ss -tlnp 2>/dev/null | grep ":3000" | grep -q "127.0.0.1"; then
    check "Gateway binding" "pass" "Bound to localhost (127.0.0.1:3000)"
elif ss -tlnp 2>/dev/null | grep -q ":3000"; then
    check "Gateway binding" "fail" "Port 3000 is NOT bound to localhost — exposed to network!"
else
    check "Gateway binding" "warn" "No service detected on port 3000"
fi

# --- Sandbox configuration ---
if [ -f "$AGENT_DIR/openclaw.json" ]; then
    if grep -q '"sandbox"' "$AGENT_DIR/openclaw.json" 2>/dev/null; then
        check "Sandbox" "pass" "Sandbox configured in agent config"
    else
        check "Sandbox" "warn" "No sandbox configuration found"
    fi
else
    check "Sandbox" "warn" "No agent config file found at $AGENT_DIR"
fi

# --- SSH service ---
if systemctl is-active ssh &>/dev/null 2>&1; then
    check "SSH service" "warn" "SSH is running. Disable if not needed: sudo systemctl disable ssh"
else
    check "SSH service" "pass" "SSH is not running"
fi

# --- Core dumps ---
if ulimit -c 2>/dev/null | grep -q "^0$"; then
    check "Core dumps" "pass" "Disabled"
else
    check "Core dumps" "warn" "Core dumps enabled — can leak secrets"
fi

# --- Home directory permissions ---
HOME_PERMS=$(stat -c %a "$HOME" 2>/dev/null)
if [ "$HOME_PERMS" = "700" ] || [ "$HOME_PERMS" = "750" ]; then
    check "Home directory" "pass" "Permissions: $HOME_PERMS"
else
    check "Home directory" "warn" "Permissions: $HOME_PERMS (recommended: 750 or 700)"
fi

# --- Summary ---
echo ""
echo "═══════════════════════════════════════════════════"
echo "  Results: ✅ $PASS passed | ❌ $FAIL failed | ⚠️  $WARN warnings"
echo "═══════════════════════════════════════════════════"

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "  Fix the failures above before proceeding to Layer 1."
    exit 1
fi

exit 0
