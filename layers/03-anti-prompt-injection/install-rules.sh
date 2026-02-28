#!/bin/bash
# AI-Bastion — Layer 3: Install Anti-Prompt Injection Rules
# Copies security rules to your agent's configuration directory.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

AGENT_DIR="${AGENT_DATA_DIR:-$HOME/.openclaw}"
RULES_FILE="$SCRIPT_DIR/security-rules.xml"

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 3: Anti-Prompt Injection"
echo "═══════════════════════════════════════════════════"
echo ""

if [ ! -f "$RULES_FILE" ]; then
    echo "❌ security-rules.xml not found at $RULES_FILE"
    exit 1
fi

# --- Copy rules to agent directory ---
mkdir -p "$AGENT_DIR"
cp "$RULES_FILE" "$AGENT_DIR/ai-bastion-security-rules.xml"
chmod 644 "$AGENT_DIR/ai-bastion-security-rules.xml"

echo "[✅] Security rules copied to: $AGENT_DIR/ai-bastion-security-rules.xml"
echo ""
echo "═══════════════════════════════════════════════════"
echo "  IMPORTANT: Manual Integration Required"
echo "═══════════════════════════════════════════════════"
echo ""
echo "  The rules file has been placed in your agent directory."
echo "  You must now MERGE these rules into your agent's system prompt."
echo ""
echo "  For OpenClaw:"
echo "    Add the XML content to your SOUL.md file"
echo ""
echo "  For Claude Code:"
echo "    Add the XML content to your CLAUDE.md file"
echo ""
echo "  For LangChain / CrewAI / custom agents:"
echo "    Include the rules in your system prompt template"
echo ""
echo "  See docs/ADAPTING-TO-YOUR-AGENT.md for detailed instructions."
