# Community Blox Applications

This folder contains **community-contributed** Bloxchain-based applications. Each application is a standalone contract (or set of contracts) that builds on the [Bloxchain Protocol](https://github.com/PracticalParticle/Bloxchain-Protocol).

## Scope

- Blox applications, integrations, and experiments maintained by the community
- Code here is **not** part of the official Blox-Apps/Official-Blox offering
- **Not audited** by Blox-Apps or Bloxchain Protocol maintainers; use at your own risk

## Licensing

**Each blox must define its own licensing.**

- **Default**: If an author does not specify a license, the default is **MIT License**.
- **Override**: Authors may choose any license (e.g. MIT, Apache-2.0, GPL-3.0) and must make it clear in their blox directory (e.g. a `LICENSE` file or a clear notice in a README).

The **repository root LICENSE** (Blox-Apps / Particle Crypto Security) **does not apply** to this folder. Only the license specified by each blox author applies to that blox.

## Adding a Community Blox

1. Create a subfolder under `community-blox/` with a descriptive name (e.g. `my-defi-vault`).
2. Add your contracts, tests, and documentation.
3. Include a **LICENSE** file (or explicit license notice) in your subfolder. If you do not include one, the default is MIT.
4. Add a README describing your blox, how to build/test, and any disclaimers.
5. Open a pull request; maintainers will review for obvious issues and alignment with the hub.

## Relationship to Blox-Apps

- **Official-Blox** (`contracts/Official-Blox/`): Official applications; covered by the repo’s dual license (AGPL-3.0 / Commercial).
- **community-blox** (this folder): Community applications; excluded from the repo license; each blox has its own license (default MIT).

For contribution and conduct guidelines, see the root [CONTRIBUTING.md](../../CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](../../CODE_OF_CONDUCT.md).
