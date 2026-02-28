# Contributing to AI-Bastion

Thank you for your interest in making AI agents safer for everyone.

## How to Contribute

### Reporting Vulnerabilities
See [SECURITY.md](SECURITY.md) for responsible disclosure procedures.

### Submitting Changes

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Run shellcheck: `shellcheck layers/**/*.sh scripts/*.sh tests/*.sh`
5. Test your changes: `bash tests/verify-all.sh`
6. Commit: `git commit -m "Add: description of your change"`
7. Push: `git push origin feature/your-feature`
8. Open a Pull Request

### Code Standards

- All scripts must pass `shellcheck` with no warnings
- Use `set -euo pipefail` at the top of every script
- Include a header comment with description and license
- Use the configuration system (`bastion.conf`) instead of hardcoding paths
- Test on Ubuntu 22.04+ and Debian 12+

### What We Need Help With

- **New threat detection patterns** for `suspicious-processes.txt`
- **New malicious IP ranges** for `blocked-ips.txt`
- **Documentation** improvements and translations
- **Testing** on different Linux distributions
- **Adaption guides** for additional AI agent platforms

### License

By contributing, you agree that your contributions will be licensed under Apache 2.0.
