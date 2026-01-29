// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (c) 2025 Particle Crypto Security
pragma solidity 0.8.33;

// ============ IMPORTS ============

// Import core security components from the Bloxchain Protocol contracts package
import "@bloxchain/contracts/contracts/core/execution/GuardController.sol";
import "@bloxchain/contracts/contracts/core/access/RuntimeRBAC.sol";
import "@bloxchain/contracts/contracts/core/security/SecureOwnable.sol";
import "@bloxchain/contracts/contracts/core/base/BaseStateMachine.sol";
import "@bloxchain/contracts/contracts/utils/SharedValidation.sol";
import "@bloxchain/contracts/contracts/interfaces/IDefinition.sol";

// ============ CONTRACT DOCUMENTATION ============

/**
 * @title BloxchainWallet
 * @dev Official ParticleCS wallet controller built on Bloxchain Protocol
 *
 * This contract is based on the ControlBlox template and combines:
 * - GuardController: Execution workflows and time-locked transactions
 * - RuntimeRBAC: Runtime role creation and management
 * - SecureOwnable: Secure ownership transfer and management
 *
 * It serves as the core on-chain controller for the Bloxchain Wallet application.
 */
contract BloxchainWallet is GuardController, RuntimeRBAC, SecureOwnable {
    // ============ CONSTANTS ============

    /// @notice Minimum time lock period: 1 day (86400 seconds)
    uint256 public constant MIN_TIME_LOCK_PERIOD = 1 days;

    /// @notice Maximum time lock period: 90 days (7776000 seconds)
    uint256 public constant MAX_TIME_LOCK_PERIOD = 90 days;

    // ============ EVENTS ============

    /**
     * @dev Emitted when ETH is deposited to the wallet
     * @param from The address that deposited the ETH
     * @param amount The amount of ETH deposited
     */
    event EthReceived(address indexed from, uint256 amount);

    // ============ INITIALIZATION FUNCTIONS ============

    /**
     * @notice Initializer to configure the BloxchainWallet
     * @param initialOwner The initial owner address
     * @param broadcaster The broadcaster address
     * @param recovery The recovery address
     * @param timeLockPeriodSec The timelock period in seconds
     * @param eventForwarder The event forwarder address (optional)
     */
    function initialize(
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder
    )
        public
        virtual
        override(GuardController, RuntimeRBAC, SecureOwnable)
        initializer
    {
        _initializeBase(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
    }

    /**
     * @notice Extended initializer that accepts custom definition contracts
     * @param initialOwner The initial owner address
     * @param broadcaster The broadcaster address
     * @param recovery The recovery address
     * @param timeLockPeriodSec The timelock period in seconds
     * @param eventForwarder The event forwarder address (optional)
     * @param definitionContracts Array of definition contract addresses implementing IDefinition
     * @dev System definitions (factory settings) are loaded first, then custom definitions
     * @dev All validation (protected schemas, duplicates, existence) is handled internally by _loadDefinitions
     * @notice This allows extending the contract with additional function schemas and role permissions
     */
    function initializeWithDefinitions(
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder,
        IDefinition[] memory definitionContracts
    ) public initializer {
        // Initialize base (validates time lock period and initializes parent contracts)
        _initializeBase(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
        
        // Load custom definitions from each definition contract
        // All validation is handled internally by _loadDefinitions with allowProtectedSchemas=false
        for (uint256 i = 0; i < definitionContracts.length; i++) {
            SharedValidation.validateNotZeroAddress(address(definitionContracts[i]));
            
            EngineBlox.FunctionSchema[] memory schemas = definitionContracts[i].getFunctionSchemas();
            IDefinition.RolePermission memory permissions = definitionContracts[i].getRolePermissions();
            
            _loadDefinitions(
                schemas,
                permissions.roleHashes,
                permissions.functionPermissions
            );
              
            // This will be applicable in the next bloxchain update   
            // _loadDefinitions(
            //     schemas,
            //     permissions.roleHashes,
            //     permissions.functionPermissions,
            //     false // Custom definitions must not be protected
            // );
        }
    }

    // ============ DEPOSIT & INTERFACE FUNCTIONS ============

    /**
     * @dev Explicit deposit function for ETH deposits
     * @notice Users must call this function to deposit ETH to the wallet controller
     * @notice Direct ETH transfers to the contract will revert (no receive() function)
     */
    function deposit() external payable {
        emit EthReceived(msg.sender, msg.value);
        // ETH is automatically added to contract balance
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(GuardController, RuntimeRBAC, SecureOwnable)
        returns (bool)
    {
        return
            GuardController.supportsInterface(interfaceId) ||
            RuntimeRBAC.supportsInterface(interfaceId) ||
            SecureOwnable.supportsInterface(interfaceId);
    }

    // ============ FALLBACK & RECEIVE FUNCTIONS ============

    /**
     * @dev Fallback function to reject accidental calls
     * @notice Prevents accidental ETH transfers and unknown function calls
     * @notice Users must use deposit() function to send ETH
     */
    fallback() external payable {
        revert SharedValidation.NotSupported();
    }

    /**
     * @dev Receive function to reject direct ETH transfers
     * @notice Prevents accidental ETH transfers
     * @notice Users must use deposit() function to send ETH
     */
    receive() external payable {
        revert SharedValidation.NotSupported();
    }

    // ============ OVERRIDE FUNCTIONS ============

    /**
     * @dev Override to resolve ambiguity between BaseStateMachine and SecureOwnable
     * @param newTimeLockPeriodSec The new time lock period in seconds
     * @notice Validates that the new time lock period is between MIN_TIME_LOCK_PERIOD and MAX_TIME_LOCK_PERIOD
     */
    function _updateTimeLockPeriod(uint256 newTimeLockPeriodSec)
        internal
        virtual
        override(BaseStateMachine, SecureOwnable)
    {
        _validateTimeLockPeriod(newTimeLockPeriodSec);
        SecureOwnable._updateTimeLockPeriod(newTimeLockPeriodSec);
    }

    // ============ INTERNAL FUNCTIONS ============

    /**
     * @dev Internal function to initialize base state (common to all initialization paths)
     * @param initialOwner The initial owner address
     * @param broadcaster The broadcaster address
     * @param recovery The recovery address
     * @param timeLockPeriodSec The timelock period in seconds
     * @param eventForwarder The event forwarder address (optional)
     * @notice Validates time lock period and initializes all parent contracts
     * @notice The guarded initialization ensures BaseStateMachine is only initialized once
     */
    function _initializeBase(
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder
    ) internal {
        // Validate time lock period before initialization
        _validateTimeLockPeriod(timeLockPeriodSec);
        
        // Initialize all parent contracts.
        // The guarded initialization ensures BaseStateMachine is only initialized once.
        GuardController.initialize(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
        RuntimeRBAC.initialize(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
        SecureOwnable.initialize(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
    }

    /**
     * @dev Validates that a time lock period is within the allowed range
     * @param timeLockPeriodSec The time lock period in seconds to validate
     * @notice Reverts with InvalidTimeLockPeriod if the period is outside MIN_TIME_LOCK_PERIOD and MAX_TIME_LOCK_PERIOD
     */
    function _validateTimeLockPeriod(uint256 timeLockPeriodSec) internal pure {
        if (
            timeLockPeriodSec < MIN_TIME_LOCK_PERIOD ||
            timeLockPeriodSec > MAX_TIME_LOCK_PERIOD
        ) {
            revert SharedValidation.InvalidTimeLockPeriod(timeLockPeriodSec);
        }
    }
}

