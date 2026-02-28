#!/bin/bash
# AI-Bastion — Layer 4: Action Logger
# Logs all agent actions with timestamps and cryptographic hashes.
# Source this file to use log_action() in other scripts.
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

LOG_DIR="${LOG_DIR:-$HOME/.ai-bastion/logs}"
mkdir -p "$LOG_DIR"

log_action() {
    local level="$1"    # INFO, WARN, ALERT, CRITICAL
    local action="$2"   # Description
    local detail="${3:-}"   # Additional detail

    local timestamp
    timestamp=$(date -Is)
    local hash
    hash=$(echo "$timestamp$action$detail" | sha256sum | cut -d' ' -f1)
    local log_file="$LOG_DIR/actions-$(date +%Y%m%d).log"

    echo "[$timestamp] [$level] $action | $detail | hash:${hash:0:16}" >> "$log_file"

    # Critical alerts also go to a separate append-only file
    if [ "$level" = "CRITICAL" ] || [ "$level" = "ALERT" ]; then
        echo "[$timestamp] [$level] $action | $detail" >> "$LOG_DIR/alerts.log"
    fi
}

# Export for use in other scripts
export -f log_action
export LOG_DIR

# If executed directly (not sourced), show usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "AI-Bastion Action Logger"
    echo ""
    echo "Usage: # shellcheck disable=SC1091
source $(basename $0)"
    echo "  Then: log_action LEVEL \"action\" \"detail\""
    echo ""
    echo "Levels: INFO, WARN, ALERT, CRITICAL"
    echo "Log directory: $LOG_DIR"
    echo ""
    echo "Example:"
    echo "  # shellcheck disable=SC1091
source $(basename $0)"
    echo '  log_action INFO "Agent started" "PID: $$"'
    echo '  log_action ALERT "Suspicious command" "curl | sh detected"'
fi
