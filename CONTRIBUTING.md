# Contributing to Bloxchain Wallet

Thank you for your interest in contributing to Bloxchain Wallet! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Process](#contributing-process)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [License Agreement](#license-agreement)

## Code of Conduct

This project follows professional standards of conduct. By participating, you agree to uphold respectful and professional behavior. Please report unacceptable behavior to support@particlecs.com.

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Node.js** (v18 or higher)
- **npm** (v8 or higher)
- **Hardhat** (v3.15 or higher)
- **Git** (latest version)
- **Solidity** knowledge (0.8.33)
- Familiarity with **Bloxchain Protocol**

### Development Environment

```bash
# Clone the repository
git clone https://github.com/PracticalParticle/Bloxchain-Wallet.git
cd Bloxchain-Wallet

# Install dependencies
npm install

# Compile contracts
npm run build:contracts

# Run tests
npm test
```

## Development Setup

### Project Structure

```
Bloxchain-Wallet/
├── contracts/           # Smart contracts
│   └── BloxchainWallet.sol
├── test/               # Test files
├── hardhat.config.cjs  # Hardhat configuration
└── package.json        # Dependencies
```

## Contributing Process

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/Bloxchain-Wallet.git
cd Bloxchain-Wallet

# Add upstream remote
git remote add upstream https://github.com/PracticalParticle/Bloxchain-Wallet.git
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

### Contributor License Agreement

**IMPORTANT:** By contributing to Bloxchain Wallet, you agree to the following licensing terms:

1. **Your contributions will be licensed under the same dual-license model** as Bloxchain Wallet:
   - **GNU Affero General Public License v3.0 or later (AGPL-3.0-or-later)**, AND
   - **Bloxchain Wallet Commercial License** (proprietary license)

2. **You grant Particle Crypto Security the right to relicense your contributions** under both:
   - The AGPL-3.0-or-later license (for the Community Edition), and
   - The Bloxchain Wallet Commercial License (for commercial customers)

3. **You represent that:**
   - You own the copyright to your contributions, or
   - You have the right to grant these licenses, or
   - Your contributions are in the public domain

4. **You understand that:**
   - Your contributions may be used in both open-source and commercial contexts
   - Particle Crypto Security retains the right to offer Bloxchain Wallet under both licenses
   - This agreement does not grant you any rights to the commercial license beyond what AGPL-3.0 provides

By submitting a Pull Request or contributing code to this repository, you acknowledge that you have read, understood, and agree to these terms.

---

For questions about contributing or licensing, contact: **legal@particlecs.com**
