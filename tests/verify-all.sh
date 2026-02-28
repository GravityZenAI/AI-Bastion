#!/bin/bash
# AI-Bastion — Verification Suite
# Tests all 8 layers to confirm correct installation.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

AGENT_DIR="${AGENT_DATA_DIR:-$HOME/.openclaw}"
BASTION_DATA="$HOME/.ai-bastion"
PASS=0
FAIL=0
SKIP=0

echo "╔══════════════════════════════════════════════════╗"
echo "║     AI-Bastion 🏰 — Verification Suite          ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

test_layer() {
    local layer="$1"
    local name="$2"
    local result="$3" # pass, fail, skip
    local detail="$4"

    case "$result" in
        pass) echo "  ✅ Layer $layer ($name): $detail"; PASS=$((PASS + 1)) ;;
        fail) echo "  ❌ Layer $layer ($name): $detail"; FAIL=$((FAIL + 1)) ;;
        skip) echo "  ⏭️  Layer $layer ($name): $detail"; SKIP=$((SKIP + 1)) ;;
    esac
}

# --- Layer 0: Baseline ---
echo "── Layer 0: Baseline ──"
if command -v ufw &>/dev/null && sudo ufw status 2>/dev/null | grep -q "active"; then
    test_layer 0 "Firewall" "pass" "UFW active"
else
    test_layer 0 "Firewall" "fail" "UFW not active"
fi

# --- Layer 1: Network ---
echo "── Layer 1: Network ──"
if command -v nft &>/dev/null && sudo nft list table inet ai_bastion &>/dev/null 2>&1; then
    test_layer 1 "nftables" "pass" "ai_bastion table active"
else
    test_layer 1 "nftables" "skip" "ai_bastion rules not loaded"
fi

if command -v stubby &>/dev/null && systemctl is-active stubby &>/dev/null 2>&1; then
    test_layer 1 "DNS-TLS" "pass" "Stubby active"
else
    test_layer 1 "DNS-TLS" "skip" "Stubby not running"
fi

# --- Layer 2: Canary Tokens ---
echo "── Layer 2: Canary Tokens ──"
CANARY_COUNT=0
[ -f "$AGENT_DIR/canary/.env.backup" ] && CANARY_COUNT=$((CANARY_COUNT + 1))
[ -f "$AGENT_DIR/canary/passwords.txt" ] && CANARY_COUNT=$((CANARY_COUNT + 1))
[ -f "$AGENT_DIR/.credentials_backup" ] && CANARY_COUNT=$((CANARY_COUNT + 1))

if [ "$CANARY_COUNT" -eq 3 ]; then
    test_layer 2 "Canaries" "pass" "All 3 canary files deployed"
elif [ "$CANARY_COUNT" -gt 0 ]; then
    test_layer 2 "Canaries" "fail" "Only $CANARY_COUNT/3 canary files found"
else
    test_layer 2 "Canaries" "skip" "No canary files deployed"
fi

# --- Layer 3: Anti-Prompt Injection ---
echo "── Layer 3: Anti-Prompt Injection ──"
if [ -f "$AGENT_DIR/ai-bastion-security-rules.xml" ]; then
    RULE_COUNT=$(grep -c '<rule id=' "$AGENT_DIR/ai-bastion-security-rules.xml" 2>/dev/null || echo "0")
    test_layer 3 "Rules" "pass" "$RULE_COUNT rules installed"
else
    test_layer 3 "Rules" "skip" "Security rules not installed"
fi

# --- Layer 4: Monitoring ---
echo "── Layer 4: Monitoring ──"
if [ -f "$BASTION_ROOT/layers/04-monitoring/action-logger.sh" ]; then
    test_layer 4 "Logger" "pass" "Action logger available"
else
    test_layer 4 "Logger" "fail" "Action logger missing"
fi

if pgrep -f "process-monitor.sh" &>/dev/null; then
    test_layer 4 "ProcMon" "pass" "Process monitor running"
else
    test_layer 4 "ProcMon" "skip" "Process monitor not running"
fi

if pgrep -f "network-monitor.sh" &>/dev/null; then
    test_layer 4 "NetMon" "pass" "Network monitor running"
else
    test_layer 4 "NetMon" "skip" "Network monitor not running"
fi

# --- Layer 5: Integrity ---
echo "── Layer 5: Integrity ──"
if [ -f "$BASTION_DATA/integrity-baseline.sha256" ]; then
    FILE_COUNT=$(grep -c "^[a-f0-9]" "$BASTION_DATA/integrity-baseline.sha256" 2>/dev/null || echo "0")
    test_layer 5 "Baseline" "pass" "$FILE_COUNT files in baseline"
else
    test_layer 5 "Baseline" "skip" "No integrity baseline created"
fi

# --- Layer 6: SOAR ---
echo "── Layer 6: SOAR ──"
if [ -x "$BASTION_ROOT/layers/06-soar-response/auto-response.sh" ]; then
    test_layer 6 "SOAR" "pass" "Auto-response script ready"
else
    test_layer 6 "SOAR" "skip" "Auto-response not installed"
fi

# --- Layer 7: Hardening ---
echo "── Layer 7: Hardening ──"
HOME_PERMS=$(stat -c %a "$HOME" 2>/dev/null || echo "???")
if [ "$HOME_PERMS" = "700" ] || [ "$HOME_PERMS" = "750" ]; then
    test_layer 7 "HomePerms" "pass" "Home is $HOME_PERMS"
else
    test_layer 7 "HomePerms" "fail" "Home is $HOME_PERMS (should be 750)"
fi

if grep -q "umask 027" "$HOME/.bashrc" 2>/dev/null; then
    test_layer 7 "Umask" "pass" "Restrictive umask configured"
else
    test_layer 7 "Umask" "skip" "Umask not configured"
fi

# --- Summary ---
TOTAL=$((PASS + FAIL + SKIP))
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  Results: ✅ $PASS passed | ❌ $FAIL failed | ⏭️  $SKIP skipped"
echo "║  Total checks: $TOTAL"
echo "╚══════════════════════════════════════════════════╝"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
