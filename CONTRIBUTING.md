# Contributing to Blox-Apps

Thank you for your interest in contributing to **Blox-Apps**, the application hub for Bloxchain-based applications. This document covers contributing to **official applications** (e.g. Bloxchain Wallet) and adding **community blox**.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Repository Structure](#repository-structure)
- [Contributing to Official-Blox](#contributing-to-official-blox)
- [Adding a Community Blox](#adding-a-community-blox)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Process](#contributing-process)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [License Agreement](#license-agreement)

## Code of Conduct

This project follows our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold respectful and professional behavior. Report unacceptable behavior to [conduct@particlecs.com](mailto:conduct@particlecs.com).

## Repository Structure

- **`contracts/Official-Blox/`** – Official Bloxchain applications. Covered by the repository [LICENSE](LICENSE) (AGPL-3.0 / Commercial). Contributions here require agreeing to the [License Agreement](#license-agreement) below.
- **`contracts/community-blox/`** – Community-contributed applications. **Excluded** from the repo LICENSE; each blox defines its own license (default MIT). See [contracts/community-blox/README.md](contracts/community-blox/README.md).

## Contributing to Official-Blox

Contributions to Official-Blox (e.g. Bloxchain Wallet) follow the development setup, code standards, testing, and PR process described below. You must agree to the [License Agreement](#license-agreement) for your contributions to Official-Blox.

## Adding a Community Blox

To add a **community blox** under `contracts/community-blox/`:

1. Create a subfolder with a descriptive name (e.g. `my-app`).
2. Add your contracts, tests, and a README.
3. **Include a LICENSE file** (or clear license notice) in your subfolder. If you do not, the default is **MIT**.
4. Open a PR; maintainers will review for obvious issues and alignment with the hub.

Your blox is **not** covered by the repository LICENSE; only the license you specify (or MIT by default) applies. See [contracts/community-blox/README.md](contracts/community-blox/README.md) for full details.

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Node.js** (v18 or higher)
- **npm** (v8 or higher)
- **Hardhat** (v3.1.5 or higher)
- **Foundry** (latest version) - Required for Foundry-based testing and compilation
- **Git** (latest version)
- **Solidity** knowledge (0.8.33)
- Familiarity with **Bloxchain Protocol**

### Development Environment

```bash
# Clone the repository
git clone https://github.com/PracticalParticle/Blox-Apps.git
cd Blox-Apps

# Install dependencies
npm install

# Compile contracts
npm run build:contracts

# Run tests
npm test
```

## Development Setup

### Project Structure

```text
Blox-Apps/
├── contracts/
│   ├── Official-Blox/     # Official applications (e.g. Bloxchain Wallet)
│   │   └── Wallets/
│   │       └── BloxchainWallet.sol
│   └── community-blox/    # Community applications (own license each; default MIT)
├── test/                  # Test files (official apps)
├── docs/                  # Documentation and plans
└── package.json           # Dependencies
```

## Contributing Process

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/Blox-Apps.git
cd Blox-Apps

# Add upstream remote
git remote add upstream https://github.com/PracticalParticle/Blox-Apps.git
```

### 2. Create a Branch

```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Or a bugfix branch
git checkout -b fix/your-bug-description
```

### 3. Make Changes

- Write clean, well-documented code
- Follow the code standards below
- Add tests for new functionality
- Update documentation as needed

### 4. Test Your Changes

```bash
# Run all tests
npm test

# Ensure contracts compile
npm run build:contracts
```

### 5. Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with a clear message
git commit -m "feat: add new feature description"
```

**Commit Message Format:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Test additions/changes
- `refactor:` - Code refactoring
- `chore:` - Build/tooling changes

### 6. Push and Create Pull Request

```bash
# Push to your fork
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub with:
- Clear description of changes
- Reference to related issues (if any)
- Test coverage information

## Code Standards

### Solidity

- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Use Solidity 0.8.33
- Include NatSpec documentation for all public functions
- Use explicit visibility modifiers
- Follow security best practices from `.cursorrules`

### Testing

- Maintain high test coverage
- Write tests for both success and failure cases
- Use descriptive test names
- Follow Hardhat testing patterns

## Testing Requirements

- All new features must include tests
- Tests must pass before PR submission
- Aim for comprehensive coverage of edge cases
- Include fuzz tests for security-critical functions (if applicable)

## Pull Request Process

1. **Ensure your code compiles**: `npm run build:contracts`
2. **Run all tests**: `npm test`
3. **Update documentation** if needed
4. **Create PR** with clear description
5. **Respond to review feedback** promptly
6. **Ensure CI checks pass** (if configured)

## License Agreement

### Contributor License Agreement (Official-Blox only)

**IMPORTANT:** By contributing to **Official-Blox** (e.g. Bloxchain Wallet) in this repository, you agree to the following licensing terms. Contributions to **community-blox** are governed by the license you specify in your blox folder (default MIT); see [contracts/community-blox/README.md](contracts/community-blox/README.md).

1. **Your contributions to Official-Blox will be licensed under the same dual-license model** as the official applications:
   - **GNU Affero General Public License v3.0 or later (AGPL-3.0-or-later)**, AND
   - **Bloxchain Wallet Commercial License** (proprietary license)

2. **You grant Particle Crypto Security the right to relicense your Official-Blox contributions** under both:
   - The AGPL-3.0-or-later license (for the Community Edition), and
   - The Bloxchain Wallet Commercial License (for commercial customers)

3. **You represent that:**
   - You own the copyright to your contributions, or
   - You have the right to grant these licenses, or
   - Your contributions are in the public domain

4. **You understand that:**
   - Your Official-Blox contributions may be used in both open-source and commercial contexts
   - Particle Crypto Security retains the right to offer official applications under both licenses
   - This agreement does not apply to code you add under `contracts/community-blox/` (which uses the license you specify there)
   - This agreement does not grant you any rights to the commercial license beyond what AGPL-3.0 provides

By submitting a Pull Request that modifies **Official-Blox** (or other repo-licensed code), you acknowledge that you have read, understood, and agree to these terms. PRs that only add or change content under `contracts/community-blox/` are not subject to this CLA; your blox’s own license applies.

---

For questions about contributing or licensing, contact: **[legal@particlecs.com](mailto:legal@particlecs.com)**
