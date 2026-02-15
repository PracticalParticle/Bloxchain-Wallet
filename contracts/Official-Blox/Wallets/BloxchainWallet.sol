// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (c) 2025 Particle Crypto Security
pragma solidity 0.8.33;

import { Account } from "@bloxchain/contracts/core/pattern/Account.sol";
import { BaseStateMachine } from "@bloxchain/contracts/core/base/BaseStateMachine.sol";
import { SharedValidation } from "@bloxchain/contracts/core/lib/utils/SharedValidation.sol";
import { IDefinition } from "@bloxchain/contracts/core/lib/interfaces/IDefinition.sol";
import { EngineBlox } from "@bloxchain/contracts/core/lib/EngineBlox.sol";
import { ICopyable } from "@bloxchain/contracts/standards/behavior/ICopyable.sol";

/**
 * @title BloxchainWallet
 * @dev Official ParticleCS wallet controller built on Bloxchain Protocol.
 *
 * Extends the Account pattern (GuardController + RuntimeRBAC + SecureOwnable) with
 * timelock bounds, optional roles/definitions init, and ICopyable for factory cloning.
 */
contract BloxchainWallet is Account, ICopyable {
    uint256 public constant MIN_TIME_LOCK_PERIOD = 1 days;
    uint256 public constant MAX_TIME_LOCK_PERIOD = 90 days;
    uint256 public constant MAX_DEFINITION_CONTRACTS = 50;
    uint256 public constant MAX_INITIAL_ROLES = 50;
    uint256 public constant MAX_SCHEMAS_PER_DEFINITION = 100;
    uint256 public constant MAX_PERMISSIONS_PER_DEFINITION = 200;

    bool private _cloneDataSet;

    struct RoleConfig {
        string roleName;
        uint256 maxWallets;
    }

    function initialize(
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder
    ) public virtual override(Account) initializer {
        _initializeBase(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
    }

    function initializeWithData(
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder,
        bytes calldata initData
    ) external initializer {
        _initializeBase(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
        if (initData.length > 0) {
            (RoleConfig[] memory roles, IDefinition[] memory definitionContracts) =
                abi.decode(initData, (RoleConfig[], IDefinition[]));
            _applyRolesAndDefinitions(roles, definitionContracts);
        }
    }

    function _initializeBase(
        address initialOwner,
        address broadcaster,
        address recovery,
        uint256 timeLockPeriodSec,
        address eventForwarder
    ) internal {
        _validateTimeLockPeriod(timeLockPeriodSec);
        super.initialize(initialOwner, broadcaster, recovery, timeLockPeriodSec, eventForwarder);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(Account)
        returns (bool)
    {
        return interfaceId == type(ICopyable).interfaceId || super.supportsInterface(interfaceId);
    }

    function _updateTimeLockPeriod(uint256 newTimeLockPeriodSec)
        internal
        virtual
        override(BaseStateMachine)
    {
        _validateTimeLockPeriod(newTimeLockPeriodSec);
        super._updateTimeLockPeriod(newTimeLockPeriodSec);
    }

    function _validateTimeLockPeriod(uint256 timeLockPeriodSec) internal pure {
        if (timeLockPeriodSec < MIN_TIME_LOCK_PERIOD || timeLockPeriodSec > MAX_TIME_LOCK_PERIOD) {
            revert SharedValidation.InvalidTimeLockPeriod(timeLockPeriodSec);
        }
    }

    function _applyRolesAndDefinitions(
        RoleConfig[] memory roles,
        IDefinition[] memory definitionContracts
    ) internal {
        if (roles.length > MAX_INITIAL_ROLES) {
            revert SharedValidation.BatchSizeExceeded(roles.length, MAX_INITIAL_ROLES);
        }
        for (uint256 i = 0; i < roles.length; i++) {
            _createRole(roles[i].roleName, roles[i].maxWallets, false);
        }
        if (definitionContracts.length > MAX_DEFINITION_CONTRACTS) {
            revert SharedValidation.BatchSizeExceeded(definitionContracts.length, MAX_DEFINITION_CONTRACTS);
        }
        for (uint256 i = 0; i < definitionContracts.length; i++) {
            address def = address(definitionContracts[i]);
            if (!definitionContracts[i].supportsInterface(type(IDefinition).interfaceId)) {
                revert SharedValidation.DefinitionNotIDefinition(def);
            }
            EngineBlox.FunctionSchema[] memory schemas = definitionContracts[i].getFunctionSchemas();
            IDefinition.RolePermission memory permissions = definitionContracts[i].getRolePermissions();
            if (schemas.length > MAX_SCHEMAS_PER_DEFINITION) {
                revert SharedValidation.BatchSizeExceeded(schemas.length, MAX_SCHEMAS_PER_DEFINITION);
            }
            if (permissions.roleHashes.length > MAX_PERMISSIONS_PER_DEFINITION) {
                revert SharedValidation.BatchSizeExceeded(permissions.roleHashes.length, MAX_PERMISSIONS_PER_DEFINITION);
            }
            _loadDefinitions(schemas, permissions.roleHashes, permissions.functionPermissions, false);
        }
    }
}
