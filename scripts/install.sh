#!/bin/bash
# AI-Bastion — Main Installer
# Installs all 8 security layers or specific layers by number.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
source "$BASTION_ROOT/configs/bastion.conf" 2>/dev/null || true

DRY_RUN=false
LAYERS_TO_INSTALL=()
INSTALL_ALL=false

# ── Parse arguments ──
usage() {
    echo "AI-Bastion Installer"
    echo ""
    echo "Usage: bash $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all             Install all 8 layers"
    echo "  --layers 0,1,2    Install specific layers (comma-separated)"
    echo "  --dry-run         Show what would be installed without doing it"
    echo "  --help            Show this help"
    echo ""
    echo "Layers:"
    echo "  0  Baseline check (no sudo required)"
    echo "  1  Zero Trust Network — nftables + DNS-over-TLS (sudo required)"
    echo "  2  Canary Tokens (no sudo required)"
    echo "  3  Anti-Prompt Injection rules (manual integration required)"
    echo "  4  Monitoring — action, process, network (no sudo required)"
    echo "  5  Integrity — SHA-256 baseline (no sudo required)"
    echo "  6  SOAR Response (no sudo required, sudo for network control)"
    echo "  7  System Hardening (sudo required)"
    echo ""
    echo "Recommended: Start with --layers 0 to check your baseline,"
    echo "then add layers incrementally."
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all) INSTALL_ALL=true; shift ;;
        --layers) IFS=',' read -ra LAYERS_TO_INSTALL <<< "$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --help|-h) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

if ! $INSTALL_ALL && [ ${#LAYERS_TO_INSTALL[@]} -eq 0 ]; then
    usage
    exit 1
fi

if $INSTALL_ALL; then
    LAYERS_TO_INSTALL=(0 1 2 3 4 5 6 7)
fi

# ── Create working directory ──
mkdir -p "$HOME/.ai-bastion/logs"

echo "╔══════════════════════════════════════════════════╗"
echo "║        AI-Bastion 🏰 — Installer                ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  Agent directory: ${AGENT_DATA_DIR:-$HOME/.openclaw}"
echo "║  Bastion data:    $HOME/.ai-bastion"
echo "║  Layers:          ${LAYERS_TO_INSTALL[*]}"
echo "║  Dry run:         $DRY_RUN"
echo "╚══════════════════════════════════════════════════╝"
echo ""

if $DRY_RUN; then
    echo "[DRY RUN] The following would be installed:"
    echo ""
fi

# ── Install layers ──
for layer in "${LAYERS_TO_INSTALL[@]}"; do
    case "$layer" in
        0)
            echo "── Layer 0: Baseline Check ──"
            if $DRY_RUN; then
                echo "  Would run: layers/00-baseline/check-baseline.sh"
            else
                bash "$BASTION_ROOT/layers/00-baseline/check-baseline.sh" || true
            fi
            ;;
        1)
            echo "── Layer 1: Zero Trust Network ──"
            if $DRY_RUN; then
                echo "  Would run: sudo layers/01-zero-trust-network/setup-nftables.sh"
                echo "  Would run: sudo layers/01-zero-trust-network/setup-dns-tls.sh"
            else
                echo "  [*] This layer requires sudo."
                sudo bash "$BASTION_ROOT/layers/01-zero-trust-network/setup-nftables.sh"
                sudo bash "$BASTION_ROOT/layers/01-zero-trust-network/setup-dns-tls.sh"
            fi
            ;;
        2)
            echo "── Layer 2: Canary Tokens ──"
            if $DRY_RUN; then
                echo "  Would run: layers/02-canary-tokens/deploy-canaries.sh"
                echo "  Would start: layers/02-canary-tokens/canary-monitor.sh (background)"
            else
                bash "$BASTION_ROOT/layers/02-canary-tokens/deploy-canaries.sh"
            fi
            ;;
        3)
            echo "── Layer 3: Anti-Prompt Injection ──"
            if $DRY_RUN; then
                echo "  Would run: layers/03-anti-prompt-injection/install-rules.sh"
                echo "  NOTE: Manual integration into agent system prompt required"
            else
                bash "$BASTION_ROOT/layers/03-anti-prompt-injection/install-rules.sh"
            fi
            ;;
        4)
            echo "── Layer 4: Monitoring ──"
            if $DRY_RUN; then
                echo "  Would create: action logger"
                echo "  Would start: process-monitor.sh (background)"
                echo "  Would start: network-monitor.sh (background)"
            else
                echo "  [✅] Action logger available: # shellcheck disable=SC1091
source layers/04-monitoring/action-logger.sh"
                echo "  [*] Start monitors manually when ready:"
                echo "      bash layers/04-monitoring/process-monitor.sh &"
                echo "      bash layers/04-monitoring/network-monitor.sh &"
            fi
            ;;
        5)
            echo "── Layer 5: Integrity ──"
            if $DRY_RUN; then
                echo "  Would run: layers/05-integrity/create-baseline.sh"
            else
                bash "$BASTION_ROOT/layers/05-integrity/create-baseline.sh"
            fi
            ;;
        6)
            echo "── Layer 6: SOAR Response ──"
            if $DRY_RUN; then
                echo "  Would install: auto-response.sh (4-level incident response)"
            else
                chmod +x "$BASTION_ROOT/layers/06-soar-response/auto-response.sh"
                echo "  [✅] SOAR response available:"
                echo "      bash layers/06-soar-response/auto-response.sh {0|1|2|3|restore}"
            fi
            ;;
        7)
            echo "── Layer 7: System Hardening ──"
            if $DRY_RUN; then
                echo "  Would run: sudo layers/07-system-hardening/harden-system.sh"
            else
                echo "  [*] This layer requires sudo."
                sudo bash "$BASTION_ROOT/layers/07-system-hardening/harden-system.sh"
            fi
            ;;
        *)
            echo "  ⚠️ Unknown layer: $layer (valid: 0-7)"
            ;;
    esac
    echo ""
done

# ── Final summary ──
if ! $DRY_RUN; then
    echo "╔══════════════════════════════════════════════════╗"
    echo "║       AI-Bastion 🏰 — Installation Complete     ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo ""
    echo "  Verify with: bash tests/verify-all.sh"
    echo "  Start all:   bash scripts/start-fortress.sh"
    echo ""
fi
