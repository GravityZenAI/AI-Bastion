# ROADMAP — AI-Bastion 🏰

> Future improvements and planned features.
> Updated: February 28, 2026

---

## Current Version: v1.0.0

✅ 8-layer defense-in-depth (bash scripts)
✅ OWASP ASI 10/10 mapping (infrastructure level)
✅ Sandboxing guide (bubblewrap, gVisor, Firecracker)
✅ Agent-agnostic (OpenClaw, LangChain, CrewAI, AutoGPT, Claude Code)
✅ CI with ShellCheck

---

## Short Term (v1.1 — v1.3)

### v1.1 — Testing & CI
- [ ] Add functional tests: `docker run ubuntu:22.04 bash tests/verify-all.sh --dry-run`
- [ ] Test each layer independently in CI
- [ ] Add badge to README showing CI status

### v1.2 — Releases & Versioning
- [ ] Create GitHub Release v1.0.0 with changelog
- [ ] Tag all future changes with semantic versioning
- [ ] Add version number to install.sh output

### v1.3 — Documentation
- [ ] Add architecture diagram (visual, not just ASCII)
- [ ] Add video walkthrough of installation
- [ ] Add FAQ section to docs/

---

## Medium Term (v2.0)

### Compiled Core (Rust or Go)
- [ ] Rewrite critical security scripts in Rust or Go
- [ ] Produces a single binary that is harder to tamper with
- [ ] Signed releases with checksums
- [ ] Why: Bash scripts can be modified by a compromised agent. A compiled, signed binary cannot be easily altered at runtime.

### Real-Time Dashboard
- [ ] Web-based status dashboard showing all 8 layers
- [ ] Alert feed with severity levels
- [ ] Integration with Grafana or standalone HTML

### Enhanced Monitoring (Layer 4)
- [ ] eBPF-based process monitoring (replaces polling)
- [ ] Syscall filtering with seccomp profiles
- [ ] Network flow logging with connection metadata

---

## Long Term (v3.0)

### Multi-Agent Support
- [ ] Per-agent isolation profiles
- [ ] Agent-to-agent communication firewall
- [ ] Shared threat intelligence between agents

### Cloud-Native Version
- [ ] Kubernetes operator for AI-Bastion
- [ ] Helm chart for deployment
- [ ] Integration with cloud WAFs (AWS WAF, Cloudflare)

### Threat Intelligence Feed
- [ ] Automated updates to blocked-ips.txt
- [ ] Community-contributed threat indicators
- [ ] Integration with MITRE ATT&CK for AI

### Formal Security Audit
- [ ] Third-party penetration test
- [ ] SOC 2 alignment documentation
- [ ] CIS Benchmark mapping

---

## Ecosystem

| Project | Status | Purpose |
|---------|--------|---------|
| [AI-Bastion](https://github.com/GravityZenAI/AI-Bastion) | ✅ v1.0 | Linux infrastructure defense |
| [AI-Bastion-Guardian](https://github.com/GravityZenAI/AI-Bastion-Guardian) | ✅ v1.0 | Windows perimeter defense |
| [rust-ai-governance-pack](https://github.com/GravityZenAI/rust-ai-governance-pack) | ✅ v1.0 | AI code governance for Rust |

---

## Contributing

Have ideas? Open an issue or see [CONTRIBUTING.md](CONTRIBUTING.md).

Priority is given to contributions that:
1. Fix security vulnerabilities
2. Add functional tests
3. Improve documentation
4. Port scripts to compiled languages
