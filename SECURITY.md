# Security Policy

## Supported Versions

**⚠️ Blox-Apps and its official applications are in testing phase and not yet live on mainnet.**

We maintain security updates for the following:

| Area | Supported | Notes |
|------|-----------|--------|
| **Official-Blox** (e.g. Bloxchain Wallet) | Yes | Pre-audit; report issues to security@particlecs.com |
| **community-blox** | Per blox | Each community blox is maintained by its author; report to the blox author or open an issue in this repo |

## Reporting a Vulnerability

**Do NOT create public GitHub issues for security vulnerabilities.**

### Official-Blox and repository infrastructure

Report vulnerabilities in **Official-Blox** contracts or in the **Blox-Apps** hub itself (e.g. tooling, docs, CI) to:

- **Email**: security@particlecs.com  
- **Subject**: `[SECURITY] Blox-Apps Vulnerability Report`

Include:

1. Description of the vulnerability  
2. Steps to reproduce  
3. Potential impact  
4. Suggested remediation (if any)  
5. Your contact information  

We aim to respond within 24 hours and provide a status update within 72 hours.

### Community blox

For code under **`contracts/community-blox/`**:

- Each blox has its own maintainer and license. Prefer reporting to the blox author (e.g. via their README or repo).  
- You may also open a **private** security issue in this repository referencing the community blox; we can help route it.

## Scope

- **In scope**: Smart contract vulnerabilities, protocol/design flaws, and implementation bugs in Official-Blox and Blox-Apps infrastructure.  
- **Out of scope**: Social engineering, physical security, third-party dependencies (report upstream), and issues in unaudited community blox (report to the blox author).

## Security best practices

- Do not deploy Official-Blox or community blox with real assets without a security review.  
- Use testnets for development and integration.  
- Follow [CONTRIBUTING.md](CONTRIBUTING.md) and the Bloxchain Protocol security guidelines when contributing.

---

**Particle Crypto Security**  
- **Security**: security@particlecs.com  
- **General**: https://particlecs.com/contact  

*Last updated: February 2026*
