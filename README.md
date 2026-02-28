# AI-Bastion 🏰

### 8-Layer Security Blueprint for Autonomous AI Agents

> **Born from the OpenClaw security crisis of February 2026.**
> CVE-2026-25253 (one-click RCE), CVE-2026-24763 (sandbox bypass), CVE-2026-22708, the ClawHavoc supply chain campaign, 512 vulnerabilities in audit, 10.8% malware infection rate in ClawHub marketplace.

AI-Bastion is a defense-in-depth security system for anyone running autonomous AI agents on Linux. It provides 8 layers of protection — from network firewalls to automated incident response — designed to stop prompt injection, data exfiltration, supply chain attacks, and credential theft.

**Works with:** OpenClaw, NanoClaw, LangChain agents, CrewAI, AutoGPT, custom agents on Ollama — any AI agent running on Linux.

---

## Security Doctrine: "Intelligent Fortress"

```
Never attack. Always defend. Always share.
Defense > Offense. Intelligence > Retaliation.
```

- We **NEVER** launch offensive attacks, even against confirmed attackers
- We **ALWAYS** share threat intelligence with the community
- We use **deception** (canary tokens, honeypots) over retaliation
- We respond with **block → isolate → snapshot → alert → share**

---

## The 8 Layers

| Layer | Name | What It Does |
|-------|------|-------------|
| 0 | **Baseline Check** | Verifies existing defenses are active (firewall, permissions, sandbox) |
| 1 | **Zero Trust Network** | nftables rules, rate limiting, DNS-over-TLS, egress control |
| 2 | **Canary Tokens** | Trap files that detect intrusions — fake API keys, fake passwords |
| 3 | **Anti-Prompt Injection** | 6 XML rules + 5 anti-exfiltration rules for SOUL.md / system prompts |
| 4 | **Monitoring** | Real-time action logging, process monitor, network monitor |
| 5 | **Integrity** | SHA-256 baseline of critical files, automatic tampering detection |
| 6 | **SOAR Response** | 4-level automated incident response (normal → alert → contain → lockdown) |
| 7 | **System Hardening** | SSH disabled, core dumps blocked, audit logging, restrictive permissions |

---

## Quick Start

```bash
# Clone
git clone https://github.com/GravityZenAI/AI-Bastion.git
cd AI-Bastion

# Review what will be installed (dry run)
bash scripts/install.sh --dry-run

# Install all 8 layers
bash scripts/install.sh --all

# Or install specific layers
bash scripts/install.sh --layers 0,1,2,5

# Verify installation
bash tests/verify-all.sh
```

### One-Layer-At-A-Time (Recommended)

```bash
# Start with the basics
bash layers/00-baseline/check-baseline.sh

# Add network hardening
sudo bash layers/01-zero-trust-network/setup-nftables.sh
sudo bash layers/01-zero-trust-network/setup-dns-tls.sh

# Deploy canary traps
bash layers/02-canary-tokens/deploy-canaries.sh
bash layers/02-canary-tokens/canary-monitor.sh &

# Continue with remaining layers...
```

---

## Requirements

- **OS:** Ubuntu 22.04+ / Debian 12+ / WSL2 (Ubuntu)
- **Privileges:** sudo access for layers 1 and 7
- **Packages:** Installed automatically — `nftables`, `stubby`, `inotify-tools`, `auditd`
- **All dependencies use permissive licenses** (MIT, BSD, Apache 2.0 or system packages)

---

## Repository Structure

```
AI-Bastion/
├── README.md                          # This file
├── LICENSE                            # Apache 2.0
├── CONTRIBUTING.md                    # How to contribute
├── SECURITY.md                        # Vulnerability reporting
├── CHANGELOG.md                       # Version history
│
├── layers/                            # The 8 security layers
│   ├── 00-baseline/
│   │   └── check-baseline.sh          # Verify existing defenses
│   ├── 01-zero-trust-network/
│   │   ├── setup-nftables.sh          # Firewall rules
│   │   └── setup-dns-tls.sh           # DNS-over-TLS (Stubby)
│   ├── 02-canary-tokens/
│   │   ├── deploy-canaries.sh         # Create trap files
│   │   └── canary-monitor.sh          # Monitor access to traps
│   ├── 03-anti-prompt-injection/
│   │   ├── security-rules.xml         # Rules for SOUL.md / system prompts
│   │   └── install-rules.sh           # Merge rules into agent config
│   ├── 04-monitoring/
│   │   ├── action-logger.sh           # Log all agent actions
│   │   ├── process-monitor.sh         # Detect suspicious processes
│   │   └── network-monitor.sh         # Monitor network connections
│   ├── 05-integrity/
│   │   ├── create-baseline.sh         # Generate SHA-256 baseline
│   │   └── verify-integrity.sh        # Check files against baseline
│   ├── 06-soar-response/
│   │   └── auto-response.sh           # 4-level incident response
│   └── 07-system-hardening/
│       └── harden-system.sh           # OS-level security hardening
│
├── configs/                           # Configuration templates
│   ├── bastion.conf                   # Main configuration file
│   ├── blocked-ips.txt                # Known malicious IPs
│   ├── suspicious-processes.txt       # Process patterns to detect
│   └── stubby.yml                     # DNS-over-TLS configuration
│
├── scripts/                           # Utility scripts
│   ├── install.sh                     # Main installer
│   ├── uninstall.sh                   # Clean removal
│   └── start-fortress.sh             # Start all security layers
│
├── tests/                             # Verification suite
│   └── verify-all.sh                  # Test all 8 layers
│
├── docs/                              # Documentation
│   ├── THREAT-MODEL.md                # What we defend against
│   ├── SECURITY-DOCTRINE.md           # Our philosophy
│   ├── WHY-NOT-HACK-BACK.md           # Why we never attack
│   ├── LAYER-DETAILS.md               # Deep dive on each layer
│   └── ADAPTING-TO-YOUR-AGENT.md      # How to use with any AI agent
│
└── .github/
    └── workflows/
        └── shellcheck.yml             # CI: lint all scripts
```

---

## Threat Model

AI-Bastion defends against these documented attack vectors:

| Threat | Real-World Example | Layers That Defend |
|--------|-------------------|-------------------|
| **Prompt injection (indirect)** | Attacker hides instructions in web pages/emails | 3, 4 |
| **Memory poisoning** | Agent develops persistent false beliefs | 3 |
| **Tool/skill poisoning** | ClawHavoc: 800+ malicious skills on ClawHub | 0, 2, 4, 5 |
| **Credential theft** | Infostealer extracts API keys from .env | 2, 5, 7 |
| **Data exfiltration** | Agent leaks private data to attacker's server | 1, 3, 4 |
| **Reverse shells** | Attacker gains remote access to host | 1, 4, 6 |
| **Salami slicing** | 10 benign messages gradually compromise agent | 3 |
| **Gateway exposure** | OpenClaw bound to 0.0.0.0 without auth | 0, 1 |

> Even with ALL defenses: automated attacks achieve prompt injection ~8% of the time on first attempt, ~50% with unlimited attempts (Anthropic Claude 4.5 System Card). **There is no perfect defense. Only defense in depth.**

---

## Adapting to Your Agent

AI-Bastion is designed to be **agent-agnostic**. While the examples reference OpenClaw, every layer works with any AI agent on Linux:

| Your Agent | What to Adjust |
|-----------|---------------|
| **OpenClaw** | Works out of the box. Layer 3 XML goes in SOUL.md |
| **LangChain / CrewAI** | Adapt Layer 3 rules to your system prompt format |
| **AutoGPT** | Adapt Layer 3 rules; Layer 0 checks need path updates |
| **Ollama + custom** | Edit `bastion.conf` to point to your agent's data directory |
| **Claude Code** | Layer 3 rules go in CLAUDE.md; everything else works as-is |

See [`docs/ADAPTING-TO-YOUR-AGENT.md`](docs/ADAPTING-TO-YOUR-AGENT.md) for detailed instructions.

---

## Comparison with Other Tools

| Feature | AI-Bastion | SecureClaw | openclaw-secure-start | SaferClaw |
|---------|-----------|-----------|----------------------|-----------|
| Agent-agnostic | ✅ Any agent | ❌ OpenClaw only | ❌ OpenClaw only | ❌ OpenClaw only |
| Network hardening | ✅ nftables + DNS-over-TLS | ❌ | ✅ UFW basic | ✅ UFW |
| Canary tokens | ✅ 3 types + monitor | ❌ | ❌ | ❌ |
| Anti-prompt injection | ✅ 11 rules (6+5) | ✅ 15 rules | ❌ | ❌ |
| Process monitoring | ✅ 9 suspicious patterns | ❌ | ❌ | ❌ |
| File integrity | ✅ SHA-256 baseline | ✅ Memory integrity | ❌ | ❌ |
| Automated response | ✅ 4-level SOAR | ❌ | ❌ | ❌ |
| System hardening | ✅ SSH, core dumps, audit | ❌ | ❌ | ✅ systemd |
| OWASP ASI mapping | ❌ | ✅ Full 10/10 | ❌ | ❌ |
| License | Apache 2.0 | MIT | MIT | MIT |

**AI-Bastion focuses on infrastructure-level defense.** It complements plugin-level tools like SecureClaw — use both for maximum protection.

---

## Companion Project

**[rust-ai-governance-pack](https://github.com/GravityZenAI/rust-ai-governance-pack)** — Governs HOW AI writes code (8 verification gates, 27 test katas, CI/CD pipeline for Rust).

Together:
- **rust-ai-governance-pack** = Code governance (the rules AI follows when coding)
- **AI-Bastion** = Infrastructure security (the fortress AI lives inside)

---

## License

Apache License 2.0 — See [LICENSE](LICENSE) for details.

All external dependencies are system packages available through apt with permissive or system licenses (nftables, stubby/BSD-3, inotify-tools/GPL system util, auditd/GPL system util). AI-Bastion scripts themselves are original work under Apache 2.0.

---

## Credits

Created by **[GravityZen AI](https://github.com/GravityZenAI)** — Trinidad Operativa (Cerebro + Manos + Jefe)

Built during the February 2026 OpenClaw security crisis as a response to real threats, real CVEs, and real malware campaigns. Every layer exists because something actually happened.

---

*"The butler is brilliant. Just make sure he remembers to lock the door."*
— Jamieson O'Reilly, Dvuln
