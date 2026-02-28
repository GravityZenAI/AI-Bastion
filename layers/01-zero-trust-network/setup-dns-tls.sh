#!/bin/bash
# AI-Bastion — Layer 1: DNS-over-TLS (Stubby)
# Encrypts DNS queries to prevent DNS exfiltration and sniffing.
# Stubby license: BSD-3-Clause
# Requires: sudo
# License: Apache 2.0 | https://github.com/GravityZenAI/AI-Bastion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASTION_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
STUBBY_CONF="$BASTION_ROOT/configs/stubby.yml"

if [ "$EUID" -ne 0 ]; then
    echo "❌ This script requires root. Run with: sudo bash $0"
    exit 1
fi

echo "═══════════════════════════════════════════════════"
echo "  AI-Bastion — Layer 1: DNS-over-TLS (Stubby)"
echo "═══════════════════════════════════════════════════"
echo ""

# --- Install Stubby ---
if ! command -v stubby &>/dev/null; then
    echo "[*] Installing stubby..."
    apt-get update -qq && apt-get install -y -qq stubby
fi

# --- Apply configuration ---
echo "[*] Configuring DNS-over-TLS..."

if [ -f "$STUBBY_CONF" ]; then
    cp "$STUBBY_CONF" /etc/stubby/stubby.yml
    echo "[✅] Applied AI-Bastion stubby configuration"
else
    # Write default secure config
    cat > /etc/stubby/stubby.yml << 'STUBBY_CONFIG'
# AI-Bastion DNS-over-TLS Configuration
# Uses Cloudflare (1.1.1.1) and Quad9 (9.9.9.9) for encrypted DNS
resolution_type: GETDNS_RESOLUTION_STUB
dns_transport_list:
  - GETDNS_TRANSPORT_TLS
tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
tls_query_padding_blocksize: 128
round_robin_upstreams: 1
idle_timeout: 10000
listen_addresses:
  - 127.0.0.1@5353
upstream_recursive_servers:
  - address_data: 1.1.1.1
    tls_auth_name: "cloudflare-dns.com"
  - address_data: 1.0.0.1
    tls_auth_name: "cloudflare-dns.com"
  - address_data: 9.9.9.9
    tls_auth_name: "dns.quad9.net"
  - address_data: 149.112.112.112
    tls_auth_name: "dns.quad9.net"
STUBBY_CONFIG
    echo "[✅] Created default secure DNS configuration"
fi

# --- Enable and restart Stubby ---
systemctl enable stubby 2>/dev/null || true
systemctl restart stubby 2>/dev/null || true

echo ""
echo "[✅] Layer 1 (DNS-over-TLS) complete"
echo "    Listening on: 127.0.0.1:5353"
echo "    Providers: Cloudflare + Quad9 (TLS required)"
echo ""
echo "    To route system DNS through Stubby, update /etc/resolv.conf:"
echo "    nameserver 127.0.0.1"
echo ""
echo "    Verify with: dig @127.0.0.1 -p 5353 example.com"
