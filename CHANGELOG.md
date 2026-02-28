# Changelog

All notable changes to AI-Bastion will be documented in this file.

## [1.0.0] — 2026-02-27

### Added
- Initial release with 8 security layers (0-7)
- Layer 0: Baseline security check
- Layer 1: Zero Trust Network (nftables + DNS-over-TLS via Stubby)
- Layer 2: Canary Tokens (3 trap files + real-time monitor)
- Layer 3: Anti-Prompt Injection (6 PI rules + 5 anti-exfiltration rules)
- Layer 4: Monitoring (action logger, process monitor, network monitor)
- Layer 5: Integrity (SHA-256 baseline + verification)
- Layer 6: SOAR Response (4-level automated incident response)
- Layer 7: System Hardening (SSH, core dumps, umask, auditd)
- Main installer with `--all`, `--layers`, and `--dry-run` options
- Start/stop fortress script
- Uninstaller
- Verification test suite
- Configuration system (`bastion.conf`)
- Complete documentation (threat model, security doctrine, adaptation guide)
- ShellCheck CI via GitHub Actions

### Security Context
Born from the OpenClaw security crisis of February 2026:
- CVE-2026-25253 (one-click RCE)
- CVE-2026-24763 (sandbox bypass)
- CVE-2026-22708
- ClawHavoc supply chain campaign (800+ malicious skills)
- 512 vulnerabilities in January 2026 audit
- 10.8% malware infection rate in ClawHub marketplace
