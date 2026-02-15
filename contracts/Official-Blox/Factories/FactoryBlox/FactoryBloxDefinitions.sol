// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (c) 2025 Particle Crypto Security
pragma solidity 0.8.33;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@bloxchain/contracts/core/lib/EngineBlox.sol";
import "@bloxchain/contracts/core/lib/interfaces/IDefinition.sol";

/**
 * @title FactoryBloxDefinitions
 * @dev Library containing definitions for FactoryBlox cloneBlox, whitelist, pricing, and macro registration.
 *
 * Registers cloneBlox, whitelist (addToWhitelist, removeFromWhitelist), and pricing (setClonePrice)
 * function schemas. OWNER_ROLE gets EXECUTE_TIME_DELAY_REQUEST so requests go via the controller.
 * All four are macro selectors so the controller can target address(this).
 */
library FactoryBloxDefinitions {
    bytes32 public constant CLONE_OPERATION = keccak256("CLONE_OPERATION");
    bytes32 public constant WHITELIST_OPERATION = keccak256("WHITELIST_OPERATION");
    bytes32 public constant CLONE_PRICE_OPERATION = keccak256("CLONE_PRICE_OPERATION");

    /// @dev Macro selectors (allowed to target address(this) for GuardController execution)
    bytes4 public constant CLONE_BLOX_SELECTOR =
        bytes4(keccak256("cloneBlox(address,address,address,address,uint256,bytes)"));
    // addToWhitelist(address,(address,uint256,address,uint256))
    bytes4 public constant ADD_TO_WHITELIST_SELECTOR =
        bytes4(keccak256("addToWhitelist(address,(address,uint256,address,uint256))"));
    bytes4 public constant REMOVE_FROM_WHITELIST_SELECTOR = bytes4(keccak256("removeFromWhitelist(address)"));
    // setClonePrice(address,(address,uint256,address,uint256))
    bytes4 public constant SET_CLONE_PRICE_SELECTOR =
        bytes4(keccak256("setClonePrice(address,(address,uint256,address,uint256))"));

    function getFunctionSchemas() public pure returns (EngineBlox.FunctionSchema[] memory) {
        EngineBlox.FunctionSchema[] memory schemas = new EngineBlox.FunctionSchema[](4);

        EngineBlox.TxAction[] memory timeDelayRequestActions = new EngineBlox.TxAction[](1);
        timeDelayRequestActions[0] = EngineBlox.TxAction.EXECUTE_TIME_DELAY_REQUEST;

        bytes4[] memory cloneHandlers = new bytes4[](1);
        cloneHandlers[0] = CLONE_BLOX_SELECTOR;
        schemas[0] = EngineBlox.FunctionSchema({
            functionSignature: "cloneBlox(address,address,address,address,uint256,bytes)",
            functionSelector: CLONE_BLOX_SELECTOR,
            operationType: CLONE_OPERATION,
            operationName: "CLONE_OPERATION",
            supportedActionsBitmap: EngineBlox.createBitmapFromActions(timeDelayRequestActions),
            isProtected: true,
            handlerForSelectors: cloneHandlers
        });

        bytes4[] memory addWhitelistHandlers = new bytes4[](1);
        addWhitelistHandlers[0] = ADD_TO_WHITELIST_SELECTOR;
        schemas[1] = EngineBlox.FunctionSchema({
            functionSignature: "addToWhitelist(address,(address,uint256,address,uint256))",
            functionSelector: ADD_TO_WHITELIST_SELECTOR,
            operationType: WHITELIST_OPERATION,
            operationName: "WHITELIST_OPERATION",
            supportedActionsBitmap: EngineBlox.createBitmapFromActions(timeDelayRequestActions),
            isProtected: true,
            handlerForSelectors: addWhitelistHandlers
        });

        bytes4[] memory removeWhitelistHandlers = new bytes4[](1);
        removeWhitelistHandlers[0] = REMOVE_FROM_WHITELIST_SELECTOR;
        schemas[2] = EngineBlox.FunctionSchema({
            functionSignature: "removeFromWhitelist(address)",
            functionSelector: REMOVE_FROM_WHITELIST_SELECTOR,
            operationType: WHITELIST_OPERATION,
            operationName: "WHITELIST_OPERATION",
            supportedActionsBitmap: EngineBlox.createBitmapFromActions(timeDelayRequestActions),
            isProtected: true,
            handlerForSelectors: removeWhitelistHandlers
        });

        // Schema 3: setClonePrice (per-implementation pricing configuration for cloneBlox)
        bytes4[] memory setClonePriceHandlers = new bytes4[](1);
        setClonePriceHandlers[0] = SET_CLONE_PRICE_SELECTOR;
        schemas[3] = EngineBlox.FunctionSchema({
            functionSignature: "setClonePrice(address,(address,uint256,address,uint256))",
            functionSelector: SET_CLONE_PRICE_SELECTOR,
            operationType: CLONE_PRICE_OPERATION,
            operationName: "CLONE_PRICE_OPERATION",
            supportedActionsBitmap: EngineBlox.createBitmapFromActions(timeDelayRequestActions),
            isProtected: true,
            handlerForSelectors: setClonePriceHandlers
        });

        return schemas;
    }

    function getRolePermissions() public pure returns (IDefinition.RolePermission memory) {
        bytes32[] memory roleHashes = new bytes32[](4);
        EngineBlox.FunctionPermission[] memory functionPermissions = new EngineBlox.FunctionPermission[](4);

        EngineBlox.TxAction[] memory ownerRequestActions = new EngineBlox.TxAction[](1);
        ownerRequestActions[0] = EngineBlox.TxAction.EXECUTE_TIME_DELAY_REQUEST;

        roleHashes[0] = EngineBlox.OWNER_ROLE;
        bytes4[] memory cloneHandlers = new bytes4[](1);
        cloneHandlers[0] = CLONE_BLOX_SELECTOR;
        functionPermissions[0] = EngineBlox.FunctionPermission({
            functionSelector: CLONE_BLOX_SELECTOR,
            grantedActionsBitmap: EngineBlox.createBitmapFromActions(ownerRequestActions),
            handlerForSelectors: cloneHandlers
        });

        roleHashes[1] = EngineBlox.OWNER_ROLE;
        bytes4[] memory addWhitelistHandlers = new bytes4[](1);
        addWhitelistHandlers[0] = ADD_TO_WHITELIST_SELECTOR;
        functionPermissions[1] = EngineBlox.FunctionPermission({
            functionSelector: ADD_TO_WHITELIST_SELECTOR,
            grantedActionsBitmap: EngineBlox.createBitmapFromActions(ownerRequestActions),
            handlerForSelectors: addWhitelistHandlers
        });

        roleHashes[2] = EngineBlox.OWNER_ROLE;
        bytes4[] memory removeWhitelistHandlers = new bytes4[](1);
        removeWhitelistHandlers[0] = REMOVE_FROM_WHITELIST_SELECTOR;
        functionPermissions[2] = EngineBlox.FunctionPermission({
            functionSelector: REMOVE_FROM_WHITELIST_SELECTOR,
            grantedActionsBitmap: EngineBlox.createBitmapFromActions(ownerRequestActions),
            handlerForSelectors: removeWhitelistHandlers
        });

        // Owner: setClonePrice
        roleHashes[3] = EngineBlox.OWNER_ROLE;
        bytes4[] memory setClonePriceHandlers = new bytes4[](1);
        setClonePriceHandlers[0] = SET_CLONE_PRICE_SELECTOR;
        functionPermissions[3] = EngineBlox.FunctionPermission({
            functionSelector: SET_CLONE_PRICE_SELECTOR,
            grantedActionsBitmap: EngineBlox.createBitmapFromActions(ownerRequestActions),
            handlerForSelectors: setClonePriceHandlers
        });

        return IDefinition.RolePermission({
            roleHashes: roleHashes,
            functionPermissions: functionPermissions
        });
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(IDefinition).interfaceId;
    }
}
