// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (c) 2025 Particle Crypto Security
pragma solidity 0.8.33;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { GuardController } from "@bloxchain/contracts/core/execution/GuardController.sol";
import { RuntimeRBAC } from "@bloxchain/contracts/core/access/RuntimeRBAC.sol";
import { SecureOwnable } from "@bloxchain/contracts/core/security/SecureOwnable.sol";
import { IBaseStateMachine } from "@bloxchain/contracts/core/base/interface/IBaseStateMachine.sol";
import { EngineBlox } from "@bloxchain/contracts/core/lib/EngineBlox.sol";
import { ICopyable } from "@bloxchain/contracts/standards/behavior/ICopyable.sol";
import { IDefinition } from "@bloxchain/contracts/core/lib/interfaces/IDefinition.sol";
import { IEventForwarder } from "@bloxchain/contracts/core/lib/interfaces/IEventForwarder.sol";
import { SharedValidation } from "@bloxchain/contracts/core/lib/utils/SharedValidation.sol";
import { FactoryBloxDefinitions } from "./lib/FactoryBloxDefinitions.sol";

/**
 * @title FactoryBlox
 * @dev CopyBlox-style blox factory with RBAC and GuardController like AccountBlox
 *
 * Combines:
 * - GuardController: Execution workflows and time-locked transactions
 * - RuntimeRBAC: Runtime role creation and management
 * - SecureOwnable: Secure ownership transfer and management
 * - Clone factory: Clone blox contracts (EIP-1167) with RBAC-protected cloneBlox
 * - IEventForwarder: Centralize events from clones
 *
 * Only wallets with clone permission (OWNER_ROLE by default; custom roles via RuntimeRBAC)
 * can call cloneBlox. Clones are initialized with eventForwarder set to this contract.
 * When initData is non-empty, the implementation must support ICopyable and is initialized
 * via initializeWithData; otherwise initialize(address,address,address,uint256,address) is used.
 *
 * clonesWhitelist: lightweight set of trusted blox implementation addresses. Only addresses in the
 * whitelist can be cloned via cloneBlox, giving certainty about deploying the same contract.
 * addToWhitelist and removeFromWhitelist are controller-only (macro + _validateExecuteBySelf).
 */
contract FactoryBlox is GuardController, RuntimeRBAC, SecureOwnable, IEventForwarder {
    using Clones for address;
    using ERC165Checker for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _clones;
    /// @dev Trusted blox implementation addresses; only these can be cloned via cloneBlox
    EnumerableSet.AddressSet private _clonesWhitelist;
    /// @notice Whitelist entry containing implementation address and its configured clone price
    struct CloneWhitelistEntry {
        address bloxImplementation;
        EngineBlox.PaymentDetails price;
    }

    /// @dev Per-implementation clone pricing configuration
    mapping(address => EngineBlox.PaymentDetails) private _clonePrices;

    /**
     * @notice Initializer for FactoryBlox
     */
    function initialize(
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder
    ) public virtual override(GuardController, RuntimeRBAC, SecureOwnable) initializer {
        GuardController.initialize(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
        RuntimeRBAC.initialize(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
        SecureOwnable.initialize(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);

        IDefinition.RolePermission memory factoryPermissions = FactoryBloxDefinitions.getRolePermissions();
        _loadDefinitions(
            FactoryBloxDefinitions.getFunctionSchemas(),
            factoryPermissions.roleHashes,
            factoryPermissions.functionPermissions,
            true
        );

        // Register macro selectors so controller can target address(this) for time-lock/meta-tx execution
        _addMacroSelector(FactoryBloxDefinitions.CLONE_BLOX_SELECTOR);
        _addMacroSelector(FactoryBloxDefinitions.ADD_TO_WHITELIST_SELECTOR);
        _addMacroSelector(FactoryBloxDefinitions.REMOVE_FROM_WHITELIST_SELECTOR);

        // Allow cloning this factory's implementation (or proxy) by default
        _clonesWhitelist.add(address(this));
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(GuardController, RuntimeRBAC, SecureOwnable)
        returns (bool)
    {
        return interfaceId == type(IEventForwarder).interfaceId
            || GuardController.supportsInterface(interfaceId)
            || RuntimeRBAC.supportsInterface(interfaceId)
            || SecureOwnable.supportsInterface(interfaceId);
    }

    /**
     * @notice Clone a blox contract (RBAC-protected). Caller must have clone permission (e.g. OWNER_ROLE).
     * @param initData When non-empty, target must implement ICopyable and is initialized via initializeWithData; otherwise standard initialize(...) is used.
     */
    function cloneBlox(
        address bloxAddress,
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        bytes calldata initData
    ) external nonReentrant returns (address cloneAddress) {
        _validateExecuteBySelf();
        _validateBloxImplementation(bloxAddress);

        if (initData.length > 0 && !bloxAddress.supportsInterface(type(ICopyable).interfaceId)) {
            revert SharedValidation.InvalidOperation(bloxAddress);
        }
        if (!_clonesWhitelist.contains(bloxAddress)) {
            revert SharedValidation.InvalidOperation(bloxAddress);
        }

        cloneAddress = Clones.clone(bloxAddress);
        address eventForwarder = address(this);
        bool success;

        if (initData.length > 0) {
            success = _initializeCloneWithData(
                cloneAddress,
                initialOwner,
                broadcaster,
                recovery,
                timeLockPeriodSec,
                eventForwarder,
                initData
            );
        } else {
            success = _initializeClone(
                cloneAddress,
                initialOwner,
                broadcaster,
                recovery,
                timeLockPeriodSec,
                eventForwarder
            );
        }

        if (!success) revert SharedValidation.OperationFailed();

        _clones.add(cloneAddress);
        _logComponentEvent(abi.encode(bloxAddress, cloneAddress, initialOwner, _clones.length()));
        return cloneAddress;
    }

    /**
     * @notice Add a trusted blox implementation to the whitelist with an associated clone price.
     *         Only callable by the controller (macro + _validateExecuteBySelf).
     * @param bloxImplementation Address of the blox implementation contract (must be IBaseStateMachine, not zero, not this).
     * @param price Per-clone payment configuration for this implementation.
     */
    function addToWhitelist(address bloxImplementation, EngineBlox.PaymentDetails calldata price) external nonReentrant {
        _validateExecuteBySelf();
        _validateBloxImplementation(bloxImplementation);  
        if (_clonesWhitelist.add(bloxImplementation)) {
            _clonePrices[bloxImplementation] = price;
            _logComponentEvent(
                abi.encode(
                    bloxImplementation,
                    price.recipient,
                    price.nativeTokenAmount,
                    price.erc20TokenAddress,
                    price.erc20TokenAmount
                )
            );
        }
    }

    /**
     * @notice Remove a blox implementation from the whitelist. Only callable by the controller (macro + _validateExecuteBySelf).
     * @param bloxImplementation Address to remove from the whitelist.
     */
    function removeFromWhitelist(address bloxImplementation) external nonReentrant {
        _validateExecuteBySelf();
        if (_clonesWhitelist.remove(bloxImplementation)) {
            // Clear any configured price for the removed implementation
            delete _clonePrices[bloxImplementation];
            _logComponentEvent(abi.encode(bloxImplementation));
        }
    }

    /**
     * @dev Validates that an address is a deployed contract implementing IBaseStateMachine.
     */
    function _validateBloxImplementation(address bloxAddress) internal view {
        if (!bloxAddress.supportsInterface(type(IBaseStateMachine).interfaceId)) {
            revert SharedValidation.InvalidOperation(bloxAddress);
        }
    }

    function _initializeClone(
        address cloneAddress,
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder
    ) internal returns (bool) {
        (bool success, ) = cloneAddress.call(
            abi.encodeWithSignature(
                "initialize(address,address,address,uint256,address)",
                initialOwner,
                broadcaster,
                recovery,
                timeLockPeriodSec,
                eventForwarder
            )
        );
        return success;
    }

    function _initializeCloneWithData(
        address cloneAddress,
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder,
        bytes calldata initData
    ) internal returns (bool) {
        (bool success, ) = cloneAddress.call(
            abi.encodeWithSignature(
                "initializeWithData(address,address,address,uint256,address,bytes)",
                initialOwner,
                broadcaster,
                recovery,
                timeLockPeriodSec,
                eventForwarder,
                initData
            )
        );
        return success;
    }

    function getCloneAtIndex(uint256 index) external view returns (address) {
        return _clones.at(index);
    }

    function isClone(address cloneAddress) external view returns (bool) {
        return _clones.contains(cloneAddress);
    }

    function getClonesCount() external view returns (uint256) {
        return _clones.length();
    }

    function getWhitelistCount() external view returns (uint256) {
        return _clonesWhitelist.length();
    }

    function isWhitelisted(address bloxImplementation) external view returns (bool) {
        return _clonesWhitelist.contains(bloxImplementation);
    }

    /**
     * @notice Returns whitelist entry (implementation + price) at a given index.
     */
    function getWhitelistEntryAtIndex(uint256 index) external view returns (CloneWhitelistEntry memory) {
        address bloxImplementation = _clonesWhitelist.at(index);
        return CloneWhitelistEntry({ bloxImplementation: bloxImplementation, price: _clonePrices[bloxImplementation] });
    }

    /**
     * @dev Post-action hook: when cloneBlox was requested with payment, verify the tx payment matches
     *      the configured per-implementation clone price. Ensures the requestor did not alter the payment
     *      (e.g. recipient or amounts). Only runs when TxStatus is COMPLETED (e.g. not on cancellation
     *      or failed execution).
     */
    function _postActionHook(EngineBlox.TxRecord memory txRecord) internal virtual override {
        if (txRecord.params.executionSelector != FactoryBloxDefinitions.CLONE_BLOX_SELECTOR) {
            return;
        }
        if (txRecord.status != EngineBlox.TxStatus.COMPLETED) {
            return;
        }

        // Decode the blox implementation address from execution params:
        // cloneBlox(address bloxAddress, address initialOwner, address broadcaster, address recovery, uint256 timeLockPeriodSec, bytes initData)
        (address bloxImplementation, , , , , ) = abi.decode(
            txRecord.params.executionParams,
            (address, address, address, address, uint256, bytes)
        );

        EngineBlox.PaymentDetails memory expectedPrice = _clonePrices[bloxImplementation];
        EngineBlox.PaymentDetails memory payment = txRecord.payment;

        if (
            payment.recipient != expectedPrice.recipient
            || payment.nativeTokenAmount != expectedPrice.nativeTokenAmount
            || payment.erc20TokenAddress != expectedPrice.erc20TokenAddress
            || payment.erc20TokenAmount != expectedPrice.erc20TokenAmount
        ) {
            revert SharedValidation.InvalidPayment();
        }
    }

    function forwardTxEvent(
        uint256 txId,
        bytes4 functionSelector,
        EngineBlox.TxStatus status,
        address requester,
        address target,
        bytes32 operationType
    ) external override {
        if (!_clones.contains(msg.sender)) revert SharedValidation.NoPermission(msg.sender);

        address eventForwarder = _secureState.eventForwarder;
        if (eventForwarder != address(0) && eventForwarder != address(this)) {
            try IEventForwarder(eventForwarder).forwardTxEvent(
                txId, functionSelector, status, requester, target, operationType
            ) {} catch {}
        }
    }

    receive() external payable {}

    fallback() external payable {
        revert SharedValidation.NotSupported();
    }

    uint256[50] private _gap;
}
