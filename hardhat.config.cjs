require('hardhat');

/** @type import('hardhat/config').HardhatUserConfig */
const config = {
  solidity: {
    version: '0.8.33',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
};

module.exports = config;

