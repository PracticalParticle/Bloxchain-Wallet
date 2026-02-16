/**
 * Copyright (c) 2025 Particle Crypto Security
 * SPDX-License-Identifier: AGPL-3.0-or-later
 *
 * For deployment: copy env.deployment.example to .env.deployment and set
 * DEPLOY_RPC_URL, DEPLOY_PRIVATE_KEY, DEPLOY_CHAIN_ID, DEPLOY_NETWORK_NAME.
 * Optional: npm install --save-dev dotenv @nomicfoundation/hardhat-toolbox-viem
 */

import path from "path";
import { fileURLToPath } from "url";
import { config as loadEnv } from "dotenv";
import hardhatToolboxViem from "@nomicfoundation/hardhat-toolbox-viem";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

loadEnv({ path: path.join(__dirname, ".env.deployment") });

const DEPLOY_RPC = process.env.DEPLOY_RPC_URL;
const DEPLOY_PK = process.env.DEPLOY_PRIVATE_KEY;
const rawChainId = process.env.DEPLOY_CHAIN_ID;
const chainId =
  rawChainId != null && String(rawChainId).trim() !== ""
    ? parseInt(String(rawChainId).trim(), 10)
    : 11155111;
const deployNetworkName = process.env.DEPLOY_NETWORK_NAME?.trim();

const deployNetwork =
  DEPLOY_RPC && DEPLOY_PK
    ? {
        type: "http",
        url: DEPLOY_RPC,
        chainId: Number.isNaN(chainId) || chainId <= 0 ? 11155111 : chainId,
        accounts: [DEPLOY_PK.startsWith("0x") ? DEPLOY_PK : `0x${DEPLOY_PK}`],
      }
    : null;

/** @type import('hardhat/config').HardhatUserConfig */
export default {
  plugins: [hardhatToolboxViem],
  solidity: {
    version: "0.8.33",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
      evmVersion: "osaka",
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  networks: {
    ...(deployNetwork && deployNetworkName ? { [deployNetworkName]: deployNetwork } : {}),
  },
};
