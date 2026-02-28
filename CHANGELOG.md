# Changelog

All notable changes to AI-Bastion will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-28

### Added
- OWASP ASI 10/10 mapping table (all 10 Agentic Security Initiative categories)
- Sandboxing guide with bubblewrap, gVisor, Firecracker, and Docker comparison
- WSL2 security guidance section
- AI-Bastion-Guardian companion project reference
- Source link for Anthropic prompt injection statistics (Claude 4.5 System Card)
- ROADMAP.md with v2.0 and v3.0 plans

### Changed
- Comparison table: OWASP ASI row updated from ❌ to ✅ 10/10 (infrastructure)
- Added sandboxing guidance row to comparison table
- "Companion Project" section expanded to "Companion Projects" (plural)
- SecureClaw comparison note updated to clarify complementary relationship

## [0.1.0] - 2026-02-23

### Added
- Initial release: 8 security layers (Baseline through System Hardening)
- Layer 0: Baseline check script
- Layer 1: Zero-trust network (nftables + DNS-over-TLS)
- Layer 2: Canary tokens (3 types + monitor)
- Layer 3: Anti-prompt injection (6 XML rules + 5 anti-exfiltration)
- Layer 4: Monitoring (action logger, process monitor, network monitor)
- Layer 5: Integrity (SHA-256 baseline + verification)
- Layer 6: SOAR response (4-level automated incident response)
- Layer 7: System hardening (SSH, core dumps, audit logging)
- Main installer with dry-run and per-layer options
- Verification test suite
- Security doctrine documentation
- Threat model documentation
- Agent adaptation guide
- CI with ShellCheck
