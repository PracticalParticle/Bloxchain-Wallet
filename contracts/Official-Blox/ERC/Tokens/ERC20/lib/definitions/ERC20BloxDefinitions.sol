// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (c) 2025 Particle Crypto Security
pragma solidity 0.8.33;

import { EngineBlox } from "@bloxchain/contracts/core/lib/EngineBlox.sol";
import { IDefinition } from "@bloxchain/contracts/core/lib/interfaces/IDefinition.sol";

/**
 * @title ERC20BloxDefinitions
 * @dev Definition library for ERC20Blox execution selectors (transfer, transferFrom, mint, burn, burnFrom).
 * Registers function schemas and role permissions so the GuardController can execute these functions
 * via time-lock and meta-transaction workflows. Handler permissions (executeWithTimeLock, etc.) are
 * defined in GuardControllerDefinitions.
 * @custom:security-contact security@particlecrypto.com
 */
library ERC20BloxDefinitions {

    // System macro selectors (allowed to target address(this) for GuardController execution)
    bytes4 public constant TRANSFER_SELECTOR = bytes4(keccak256("transfer(address,uint256)"));
    bytes4 public constant TRANSFER_FROM_SELECTOR = bytes4(keccak256("transferFrom(address,address,uint256)"));
    bytes4 public constant MINT_SELECTOR = bytes4(keccak256("mint(address,uint256)"));
    bytes4 public constant BURN_SELECTOR = bytes4(keccak256("burn(uint256)"));
    bytes4 public constant BURN_FROM_SELECTOR = bytes4(keccak256("burnFrom(address,uint256)"));
    bytes4 public constant SET_ACCESS_MODE_SELECTOR = bytes4(keccak256("setAccessMode(uint256)"));

    bytes32 public constant ERC20_OPERATION = keccak256("ERC20_OPERATION");

    /**
     * @dev Returns function schemas for ERC20Blox execution selectors (used by controller).
     */
    function getFunctionSchemas() public pure returns (EngineBlox.FunctionSchema[] memory) {
        EngineBlox.FunctionSchema[] memory schemas = new EngineBlox.FunctionSchema[](6);

        EngineBlox.TxAction[] memory timeDelayRequestActions = new EngineBlox.TxAction[](1);
        timeDelayRequestActions[0] = EngineBlox.TxAction.EXECUTE_TIME_DELAY_REQUEST;
        EngineBlox.TxAction[] memory timeDelayApproveActions = new EngineBlox.TxAction[](1);
        timeDelayApproveActions[0] = EngineBlox.TxAction.EXECUTE_TIME_DELAY_APPROVE;
        EngineBlox.TxAction[] memory timeDelayCancelActions = new EngineBlox.TxAction[](1);
        timeDelayCancelActions[0] = EngineBlox.TxAction.EXECUTE_TIME_DELAY_CANCEL;
        EngineBlox.TxAction[] memory metaTxRequestApproveActions = new EngineBlox.TxAction[](2);
        metaTxRequestApproveActions[0] = EngineBlox.TxAction.SIGN_META_REQUEST_AND_APPROVE;
        metaTxRequestApproveActions[1] = EngineBlox.TxAction.EXECUTE_META_REQUEST_AND_APPROVE;
        EngineBlox.TxAction[] memory metaTxApproveActions = new EngineBlox.TxAction[](2);
        metaTxApproveActions[0] = EngineBlox.TxAction.SIGN_META_APPROVE;
        metaTxApproveActions[1] = EngineBlox.TxAction.EXECUTE_META_APPROVE;
        EngineBlox.TxAction[] memory metaTxCancelActions = new EngineBlox.TxAction[](2);
        metaTxCancelActions[0] = EngineBlox.TxAction.SIGN_META_CANCEL;
        metaTxCancelActions[1] = EngineBlox.TxAction.EXECUTE_META_CANCEL;

        uint16 actionsBitmap = EngineBlox.createBitmapFromActions(timeDelayRequestActions)
            | EngineBlox.createBitmapFromActions(timeDelayApproveActions)
            | EngineBlox.createBitmapFromActions(timeDelayCancelActions)
            | EngineBlox.createBitmapFromActions(metaTxRequestApproveActions)
            | EngineBlox.createBitmapFromActions(metaTxApproveActions)
            | EngineBlox.createBitmapFromActions(metaTxCancelActions);

        bytes4[] memory transferHandlers = new bytes4[](1);
        transferHandlers[0] = TRANSFER_SELECTOR;
        bytes4[] memory transferFromHandlers = new bytes4[](1);
        transferFromHandlers[0] = TRANSFER_FROM_SELECTOR;
        bytes4[] memory mintHandlers = new bytes4[](1);
        mintHandlers[0] = MINT_SELECTOR;
        bytes4[] memory burnHandlers = new bytes4[](1);
        burnHandlers[0] = BURN_SELECTOR;
        bytes4[] memory burnFromHandlers = new bytes4[](1);
        burnFromHandlers[0] = BURN_FROM_SELECTOR;

        schemas[0] = EngineBlox.FunctionSchema({
            functionSignature: "transfer(address,uint256)",
            functionSelector: TRANSFER_SELECTOR,
            operationType: ERC20_OPERATION,
            operationName: "ERC20_TRANSFER",
            supportedActionsBitmap: actionsBitmap,
            isProtected: true,
            handlerForSelectors: transferHandlers
        });
        schemas[1] = EngineBlox.FunctionSchema({
            functionSignature: "transferFrom(address,address,uint256)",
            functionSelector: TRANSFER_FROM_SELECTOR,
            operationType: ERC20_OPERATION,
            operationName: "ERC20_TRANSFER_FROM",
            supportedActionsBitmap: actionsBitmap,
            isProtected: true,
            handlerForSelectors: transferFromHandlers
        });
        schemas[2] = EngineBlox.FunctionSchema({
            functionSignature: "mint(address,uint256)",
            functionSelector: MINT_SELECTOR,
            operationType: ERC20_OPERATION,
            operationName: "ERC20_MINT",
            supportedActionsBitmap: actionsBitmap,
            isProtected: true,
            handlerForSelectors: mintHandlers
        });
        schemas[3] = EngineBlox.FunctionSchema({
            functionSignature: "burn(uint256)",
            functionSelector: BURN_SELECTOR,
            operationType: ERC20_OPERATION,
            operationName: "ERC20_BURN",
            supportedActionsBitmap: actionsBitmap,
            isProtected: true,
            handlerForSelectors: burnHandlers
        });
        schemas[4] = EngineBlox.FunctionSchema({
            functionSignature: "burnFrom(address,uint256)",
            functionSelector: BURN_FROM_SELECTOR,
            operationType: ERC20_OPERATION,
            operationName: "ERC20_BURN_FROM",
            supportedActionsBitmap: actionsBitmap,
            isProtected: true,
            handlerForSelectors: burnFromHandlers
        });

        bytes4[] memory setAccessModeHandlers = new bytes4[](1);
        setAccessModeHandlers[0] = SET_ACCESS_MODE_SELECTOR;
        schemas[5] = EngineBlox.FunctionSchema({
            functionSignature: "setAccessMode(uint256)",
            functionSelector: SET_ACCESS_MODE_SELECTOR,
            operationType: ERC20_OPERATION,
            operationName: "ERC20_SET_ACCESS_MODE",
            supportedActionsBitmap: actionsBitmap,
            isProtected: true,
            handlerForSelectors: setAccessModeHandlers
        });

        return schemas;
    }

    /**
     * @dev Returns role permissions for ERC20Blox execution selectors (OWNER and BROADCASTER).
     */
    function getRolePermissions() public pure returns (IDefinition.RolePermission memory) {
        bytes32[] memory roleHashes = new bytes32[](11);
        EngineBlox.FunctionPermission[] memory functionPermissions = new EngineBlox.FunctionPermission[](11);

        EngineBlox.TxAction[] memory ownerTimeLockRequest = new EngineBlox.TxAction[](1);
        ownerTimeLockRequest[0] = EngineBlox.TxAction.EXECUTE_TIME_DELAY_REQUEST;
        EngineBlox.TxAction[] memory ownerTimeLockApprove = new EngineBlox.TxAction[](1);
        ownerTimeLockApprove[0] = EngineBlox.TxAction.EXECUTE_TIME_DELAY_APPROVE;
        EngineBlox.TxAction[] memory ownerTimeLockCancel = new EngineBlox.TxAction[](1);
        ownerTimeLockCancel[0] = EngineBlox.TxAction.EXECUTE_TIME_DELAY_CANCEL;
        EngineBlox.TxAction[] memory ownerMetaSign = new EngineBlox.TxAction[](1);
        ownerMetaSign[0] = EngineBlox.TxAction.SIGN_META_REQUEST_AND_APPROVE;
        EngineBlox.TxAction[] memory ownerMetaApprove = new EngineBlox.TxAction[](1);
        ownerMetaApprove[0] = EngineBlox.TxAction.SIGN_META_APPROVE;
        EngineBlox.TxAction[] memory ownerMetaCancel = new EngineBlox.TxAction[](1);
        ownerMetaCancel[0] = EngineBlox.TxAction.SIGN_META_CANCEL;
        EngineBlox.TxAction[] memory broadcasterMetaExec = new EngineBlox.TxAction[](1);
        broadcasterMetaExec[0] = EngineBlox.TxAction.EXECUTE_META_REQUEST_AND_APPROVE;
        EngineBlox.TxAction[] memory broadcasterMetaApprove = new EngineBlox.TxAction[](1);
        broadcasterMetaApprove[0] = EngineBlox.TxAction.EXECUTE_META_APPROVE;
        EngineBlox.TxAction[] memory broadcasterMetaCancel = new EngineBlox.TxAction[](1);
        broadcasterMetaCancel[0] = EngineBlox.TxAction.EXECUTE_META_CANCEL;

        uint16 ownerBitmap = EngineBlox.createBitmapFromActions(ownerTimeLockRequest)
            | EngineBlox.createBitmapFromActions(ownerTimeLockApprove)
            | EngineBlox.createBitmapFromActions(ownerTimeLockCancel)
            | EngineBlox.createBitmapFromActions(ownerMetaSign)
            | EngineBlox.createBitmapFromActions(ownerMetaApprove)
            | EngineBlox.createBitmapFromActions(ownerMetaCancel);
        uint16 broadcasterBitmap = EngineBlox.createBitmapFromActions(broadcasterMetaExec)
            | EngineBlox.createBitmapFromActions(broadcasterMetaApprove)
            | EngineBlox.createBitmapFromActions(broadcasterMetaCancel);

        bytes4[5] memory selectors = [TRANSFER_SELECTOR, TRANSFER_FROM_SELECTOR, MINT_SELECTOR, BURN_SELECTOR, BURN_FROM_SELECTOR];
        for (uint256 i = 0; i < 5; i++) {
            bytes4[] memory selfRef = new bytes4[](1);
            selfRef[0] = selectors[i];
            roleHashes[i] = EngineBlox.OWNER_ROLE;
            functionPermissions[i] = EngineBlox.FunctionPermission({
                functionSelector: selectors[i],
                grantedActionsBitmap: ownerBitmap,
                handlerForSelectors: selfRef
            });
        }
        for (uint256 i = 0; i < 5; i++) {
            bytes4[] memory selfRef = new bytes4[](1);
            selfRef[0] = selectors[i];
            roleHashes[5 + i] = EngineBlox.BROADCASTER_ROLE;
            functionPermissions[5 + i] = EngineBlox.FunctionPermission({
                functionSelector: selectors[i],
                grantedActionsBitmap: broadcasterBitmap,
                handlerForSelectors: selfRef
            });
        }

        bytes4[] memory setAccessModeSelfRef = new bytes4[](1);
        setAccessModeSelfRef[0] = SET_ACCESS_MODE_SELECTOR;
        roleHashes[10] = EngineBlox.OWNER_ROLE;
        functionPermissions[10] = EngineBlox.FunctionPermission({
            functionSelector: SET_ACCESS_MODE_SELECTOR,
            grantedActionsBitmap: ownerBitmap,
            handlerForSelectors: setAccessModeSelfRef
        });

        return IDefinition.RolePermission({
            roleHashes: roleHashes,
            functionPermissions: functionPermissions
        });
    }

    /**
     * @dev ERC165: report support for IDefinition when this library is used at an address
     */
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IDefinition).interfaceId;
    }
}
