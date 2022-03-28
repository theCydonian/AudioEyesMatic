const HDWalletProvider = require('@truffle/hdwallet-provider');

const fs = require('fs');
const private_key = "c8587553d380b0da03e1190861d16a8cabd4dc6bb2addc847497f56e2b0cd8ab";

module.exports = {
    networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    matic: {
      provider: () => new HDWalletProvider(private_key, `https://rpc-mumbai.matic.today`),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "^0.8.2"
    }
  },
  db: {
    enabled: false
  }
};
