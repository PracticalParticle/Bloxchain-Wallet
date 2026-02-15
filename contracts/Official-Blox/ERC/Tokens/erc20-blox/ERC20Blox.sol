// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (c) 2025 Particle Crypto Security
pragma solidity 0.8.33;

// OpenZeppelin
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Core
import "@bloxchain/contracts/core/pattern/Account.sol";
import "@bloxchain/contracts/core/lib/interfaces/IDefinition.sol";
import "@bloxchain/contracts/core/lib/utils/SharedValidation.sol";
import "./lib/definitions/ERC20BloxDefinitions.sol";

// Standards
import "@bloxchain/contracts/standards/behavior/ICopyable.sol";

/**
 * @title ERC20Blox
 * @dev ERC20 token (IERC20) with Account pattern and ICopyable for cloning.
 * Exposes transfer (ERC20), mint (owner-only), and burn (ERC20Burnable).
 * @custom:security-contact security@particlecrypto.com
 */
contract ERC20Blox is
    IERC20,
    ICopyable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    Account
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev ICopyable: full init with custom data. initData must be abi.encode(name, symbol).
     * Runs Account init, ERC20Blox definitions, and ERC20 name/symbol in one step.
     */
    function initializeWithData(
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder,
        bytes calldata initData
    ) external virtual initializer {
        super.initialize(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
        
        IDefinition.RolePermission memory erc20Permissions = ERC20BloxDefinitions.getRolePermissions();
        _loadDefinitions(
            ERC20BloxDefinitions.getFunctionSchemas(),
            erc20Permissions.roleHashes,
            erc20Permissions.functionPermissions,
            true
        );
        
        // Add macro selectors for the ERC20Blox definitions
        _addMacroSelector(ERC20BloxDefinitions.TRANSFER_SELECTOR);
        _addMacroSelector(ERC20BloxDefinitions.TRANSFER_FROM_SELECTOR);
        _addMacroSelector(ERC20BloxDefinitions.MINT_SELECTOR);
        _addMacroSelector(ERC20BloxDefinitions.BURN_SELECTOR);
        _addMacroSelector(ERC20BloxDefinitions.BURN_FROM_SELECTOR);
        (string memory name, string memory symbol) = abi.decode(initData, (string, string));
        __ERC20_init(name, symbol);
    }

    /**
     * @notice Transfer tokens to an account (callable only by this contract via GuardController)
     * @param to Recipient address
     * @param value Amount to transfer
     */
    function transfer(address to, uint256 value) public virtual override(ERC20Upgradeable, IERC20) returns (bool) {
        _validateExecuteBySelf();
        return super.transfer(to, value);
    }

    /**
     * @notice Transfer tokens from one account to another (with allowance); callable only by this contract via GuardController
     * @param from Sender address
     * @param to Recipient address
     * @param value Amount to transfer
     */
    function transferFrom(address from, address to, uint256 value) public virtual override(ERC20Upgradeable, IERC20) returns (bool) {
        _validateExecuteBySelf();
        return super.transferFrom(from, to, value);
    }

    /**
     * @notice Mint tokens to an account (callable only by this contract via GuardController)
     * @param to Recipient address
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) external virtual {
        _validateExecuteBySelf();
        _mint(to, amount);
    }

    /**
     * @notice Burn tokens from caller (callable only by this contract via GuardController)
     * @param value Amount to burn
     */
    function burn(uint256 value) public virtual override(ERC20BurnableUpgradeable) {
        _validateExecuteBySelf();
        super.burn(value);
    }

    /**
     * @notice Burn tokens from an account (with allowance); callable only by this contract via GuardController
     * @param account Account to burn from
     * @param value Amount to burn
     */
    function burnFrom(address account, uint256 value) public virtual override(ERC20BurnableUpgradeable) {
        _validateExecuteBySelf();
        super.burnFrom(account, value);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(Account) returns (bool) {
        return interfaceId == type(IERC20).interfaceId || interfaceId == type(ICopyable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Base initialization (5 params only) is disallowed; use initializeWithData(..., initData) with abi.encode(name, symbol).
     */
    function initialize(
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder
    ) public virtual override(Account) initializer {
        revert SharedValidation.NotSupported();
    }
}
