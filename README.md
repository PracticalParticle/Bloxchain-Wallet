# Bloxchain Wallet

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-green.svg)](https://opensource.org/licenses/AGPL-3.0)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.33-blue.svg)](https://soliditylang.org/)
[![Bloxchain Protocol](https://img.shields.io/badge/Bloxchain-Protocol-blue.svg)](https://github.com/PracticalParticle/Bloxchain-Protocol)
[![Particle CS](https://img.shields.io/badge/Particle-CS-blue.svg)](https://particlecs.com/)

The **official on-chain smart programable account** for the Bloxchain Wallet application, built on the [Bloxchain Protocol](https://github.com/PracticalParticle/Bloxchain-Protocol). Bloxchain Wallet combines **GuardController**, **RuntimeRBAC**, and **SecureOwnable** to provide enterprise-grade multi-signature workflows, dynamic role-based access control, and secure ownership management in a single deployable contract.

> **⚠️ EXPERIMENTAL SOFTWARE WARNING**  
> This repository contains experimental smart contract code. While the framework is feature-complete and tested, it is not yet audited for production use. Use at your own risk and do not deploy with real assets without proper security review.

---

## What is Bloxchain Wallet?

Bloxchain Wallet is the **core on-chain infrastructure** for the Bloxchain Wallet application. It is powered by the Bloxchain Protocol and provides:

- **GuardController** – Execution workflows, time-locked transactions, and controlled external contract interactions
- **RuntimeRBAC** – Runtime role creation and management with function-level permissions
- **SecureOwnable** – Secure ownership transfer and multi-role security (Owner, Broadcaster, Recovery)

The contract serves as the single on-chain entry point for the Bloxchain Wallet app: all critical operations (ownership changes, role configuration, external calls) flow through this controller with mandatory multi-signature and time-lock guarantees.

---

## Architecture Overview

### Contract Hierarchy

```
BloxchainWallet
    ├── GuardController   (execution workflows, time-locks, external call control)
    ├── RuntimeRBAC      (dynamic roles, function permissions, batch config)
    └── SecureOwnable    (owner/broadcaster/recovery, time-locked ownership)
            └── BaseStateMachine (state machine, meta-transactions)
                    └── EngineBlox (core library: SecureOperationState, multi-phase workflows)
```

### Core Components (from Bloxchain Protocol)

| Component | Role in Bloxchain Wallet |
|-----------|---------------------------|
| **GuardController** | Defines which external contracts and functions can be called, with time-lock or meta-transaction workflows. |
| **RuntimeRBAC** | Manages roles (beyond Owner/Broadcaster/Recovery), wallet limits per role, and which functions each role can request/approve/sign/execute. |
| **SecureOwnable** | Manages Owner, Broadcaster, and Recovery addresses and time-locked ownership transfer. |
| **BaseStateMachine** | Shared state, transaction records, time-lock period, and meta-transaction support. |
| **EngineBlox** | Core library: SecureOperationState, multi-phase workflows, and state machine logic; used by BaseStateMachine. |

### Security Model

- **Multi-signature workflows**: Time-delay (request → wait → approve) or meta-transaction (sign → execute) with role separation.
- **No single-point failure**: The contract controls storage and execution policy; individual keys cannot bypass workflows.
- **Explicit ETH handling**: ETH must be sent via `deposit()`. Direct `receive()`/`fallback()` transfers **revert** to avoid accidental or malicious sends.
- **Bounded initialization**: `MAX_DEFINITION_CONTRACTS` (50) and `MAX_INITIAL_ROLES` (50) limit gas and DoS risk during setup.

---

## Contract Reference

### Constants

| Constant | Value | Description |
|----------|--------|-------------|
| `MIN_TIME_LOCK_PERIOD` | 1 day | Minimum timelock period for time-delay operations. |
| `MAX_TIME_LOCK_PERIOD` | 90 days | Maximum timelock period. |
| `MAX_DEFINITION_CONTRACTS` | 50 | Maximum definition contracts in `initializeWithRolesAndDefinitions`. |
| `MAX_INITIAL_ROLES` | 50 | Maximum custom roles in `initializeWithRolesAndDefinitions`. |

### Initialization

Two initializers are available:

#### 1. `initialize` (simple)

Sets up Owner, Broadcaster, Recovery, timelock period, and optional event forwarder. Uses protocol default roles and definitions only.

```solidity
function initialize(
    address initialOwner,
    address broadcaster,
    address recovery,
    uint256 timeLockPeriodSec,
    address eventForwarder
) public initializer
```

- `timeLockPeriodSec` must be between `MIN_TIME_LOCK_PERIOD` and `MAX_TIME_LOCK_PERIOD`.
- `eventForwarder` can be `address(0)` if not used.

#### 2. `initializeWithRolesAndDefinitions` (extended)

Same base setup as above, plus:

- **Custom roles**: Array of `RoleConfig` (role name + max wallets). Roles are created as non-protected so they can be modified later.
- **Definition contracts**: Array of `IDefinition` addresses. Each definition supplies function schemas and role–permission mappings. Definitions are loaded after roles so that permissions can reference the new roles.

```solidity
struct RoleConfig {
    string roleName;
    uint256 maxWallets;
}

function initializeWithRolesAndDefinitions(
    address initialOwner,
    address broadcaster,
    address recovery,
    uint256 timeLockPeriodSec,
    address eventForwarder,
    RoleConfig[] memory roles,
    IDefinition[] memory definitionContracts
) public initializer
```

- `roles.length` must be ≤ `MAX_INITIAL_ROLES`.
- `definitionContracts.length` must be ≤ `MAX_DEFINITION_CONTRACTS`.
- Function permissions for custom roles are **not** set in `RoleConfig`; they are added via definition contracts.

### ETH Deposit

| Function | Description |
|----------|-------------|
| `deposit()` | **Payable.** Sends ETH to the wallet and emits `EthReceived(from, amount)`. Use this for all ETH inflows. |
| `receive()` | **Reverts** with `SharedValidation.NotSupported()`. Prevents accidental or direct ETH transfers. |
| `fallback()` | **Reverts** with `SharedValidation.NotSupported()`. Rejects unknown calls and accidental ETH. |

Only `deposit()` is accepted for ETH. This keeps behavior explicit and avoids misdirected funds.

### Events

- **`EthReceived(address indexed from, uint256 amount)`** – Emitted when ETH is deposited via `deposit()`.

### Inheritance and Overrides

- **`supportsInterface(bytes4)`** – Aggregates GuardController, RuntimeRBAC, and SecureOwnable EIP-165 support.
- **`_updateTimeLockPeriod(uint256)`** – Validates against `MIN_TIME_LOCK_PERIOD` and `MAX_TIME_LOCK_PERIOD`, then delegates to SecureOwnable.

---

## Quick Start

### Prerequisites

- Node.js (v18+)
- npm or yarn

### Installation

```bash
git clone https://github.com/PracticalParticle/Bloxchain-Wallet.git
cd Bloxchain-Wallet

npm install
```

The project depends on `@bloxchain/contracts` and `@bloxchain/sdk`; they are installed with `npm install`.

### Compile

```bash
# Foundry
npm run compile:foundry

# Contract size report (e.g. stay under 24KB)
npm run compile:foundry:size

# Hardhat
npm run build:contracts
```

### Test

```bash
# Foundry
npm run test:foundry

# Verbose
npm run test:foundry:verbose

# Fuzz (higher runs)
npm run test:foundry:fuzz

# Coverage
npm run test:foundry:coverage
```

---

## Usage with the Bloxchain Protocol SDK

Bloxchain Wallet is a ControlBlox-style contract. Use the same SDK clients as for other Bloxchain controllers: **SecureOwnable**, **RuntimeRBAC**, and **Definitions** (and GuardController-related helpers as exposed by the SDK).

### Basic setup

```typescript
import {
  SecureOwnable,
  RuntimeRBAC,
  type Address,
  type PublicClient,
  type WalletClient,
} from "@bloxchain/sdk";
import { createPublicClient, createWalletClient, http } from "viem";
import { sepolia } from "viem/chains";

const publicClient = createPublicClient({ chain: sepolia, transport: http() });
const walletClient = createWalletClient({ chain: sepolia, transport: http() });

const walletAddress = "0x..."; // Deployed BloxchainWallet

const secureOwnable = new SecureOwnable(
  publicClient,
  walletClient,
  walletAddress,
  sepolia
);

const runtimeRBAC = new RuntimeRBAC(
  publicClient,
  walletClient,
  walletAddress,
  sepolia
);
```

### Ownership (SecureOwnable)

```typescript
// Request time-locked ownership transfer
const { hash } = await secureOwnable.transferOwnershipRequest({
  from: ownerAddress,
});

// After timelock, approve
await secureOwnable.transferOwnershipDelayedApproval(txId, {
  from: ownerAddress,
});
```

### Roles (RuntimeRBAC)

```typescript
// Create custom role via batch (e.g. after initialization)
// See Bloxchain Protocol docs for roleConfigBatch / meta-transaction flows
const role = await runtimeRBAC.getRole(roleHash);
const wallets = await runtimeRBAC.getWalletsInRole(roleHash);
```

### Depositing ETH (front-end / script)

Users and scripts must call the wallet’s `deposit()` with the desired value. Example (viem):

```typescript
await walletClient.writeContract({
  address: walletAddress,
  abi: BloxchainWalletABI,
  functionName: "deposit",
  value: parseEther("1"),
  account: userAccount,
});
```

Listen for `EthReceived` to confirm deposits.

---

## Relationship to Bloxchain Protocol

- **Bloxchain Protocol** provides the security primitives (GuardController, RuntimeRBAC, SecureOwnable, BaseStateMachine, EngineBlox, definitions).
- **Bloxchain Wallet** is a concrete application: a single contract that composes these primitives as the on-chain controller for the Bloxchain Wallet app.

For deeper concepts (multi-phase workflows, meta-transactions, RBAC, GuardController target whitelisting, definition data layer), see the [Bloxchain Protocol README](https://github.com/PracticalParticle/Bloxchain-Protocol) and its documentation.

---

## Development

### Scripts (from `package.json`)

| Script | Command | Description |
|--------|---------|-------------|
| Build (Hardhat) | `npm run build:contracts` | Compile with Hardhat. |
| Build (Foundry) | `npm run compile:foundry` | Compile with Forge. |
| Size | `npm run compile:foundry:size` | Show contract sizes. |
| Test | `npm run test:foundry` | Run Forge tests. |
| Fuzz | `npm run test:foundry:fuzz` | Fuzz with 10k runs. |
| Coverage | `npm run test:foundry:coverage` | Forge coverage. |
| Invariant | `npm run test:foundry:invariant` | Invariant tests. |

### Foundry config (`foundry.toml`)

- Solidity: `0.8.33`
- Optimizer: enabled, 200 runs
- Via-IR: enabled
- EVM: Osaka
- Remappings: OpenZeppelin and forge-std; `@bloxchain/contracts` resolves via `node_modules` (from `libs`).

---

## Security Considerations

- **Explicit deposits only**: Use `deposit()` for ETH; direct transfers are rejected.
- **Time-lock bounds**: Timelock is enforced between 1 and 90 days.
- **Initialization limits**: Bounded roles and definition contracts to reduce gas and DoS risk.
- **Definition trust**: Definition contracts are called during initialization; only use audited or trusted definitions.
- **Upgradeability**: The contract uses `initializer` modifiers; deployment pattern (e.g. proxy) is defined by the deployer. Follow the Bloxchain Protocol and OpenZeppelin upgrade guidelines if using a proxy.

For protocol-level security (multi-sig, RBAC, GuardController), see the [Bloxchain Protocol documentation](https://github.com/PracticalParticle/Bloxchain-Protocol).

---

## License

Bloxchain Wallet is **dual-licensed**:

- **Community Edition**: **GNU Affero General Public License v3.0 or later (AGPL-3.0-or-later)**.
- **Commercial**: Proprietary **Bloxchain Wallet Commercial License** for organizations that need to integrate Bloxchain Wallet into proprietary products or run it as a hosted/SaaS service without AGPL copyleft obligations.

See:

- `LICENSE` – dual-licensing notice and full AGPL-3.0 text  
- `LICENSE-COMMERCIAL.md` – commercial license summary and contact details  

---

## Contributing

We welcome contributions. See [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Development setup and guidelines  
- Code standards and testing requirements  
- Pull request process  
- **Important:** Contributor License Agreement for dual licensing  

---

## Acknowledgments

- **[Bloxchain Protocol](https://github.com/PracticalParticle/Bloxchain-Protocol)** – Core security framework and ControlBlox template  
- **[Particle Crypto Security](https://particlecs.com/)** – Bloxchain Wallet implementation  
- **OpenZeppelin** – Upgradeable and security patterns  
- **Foundry / Hardhat** – Compilation and testing  

---

Created by [Particle Crypto Security](https://particlecs.com/)  
Copyright © 2025 Particle Crypto Security. All rights reserved.
