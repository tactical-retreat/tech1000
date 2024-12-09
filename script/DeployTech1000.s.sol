// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Tech1000.sol";

contract DeployTech1000 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Tech1000 nft = new Tech1000();

        vm.stopBroadcast();
    }
}

// export PRIVATE_KEY=<private key>

// If deploying to fuji consider reducing the cost by 1/100.

// export RPC_URL=https://api.avax-test.network/ext/bc/C/rpc
// forge script DeployTech1000 --rpc-url $RPC_URL --broadcast --verify --etherscan-api-key "W5DEAR5SCEFQW5IXW2E8DU2MAIQY885SFS"
// forge verify-contract <deployed address> Tech1000 --verifier-url 'https://api-testnet.snowscan.xyz/api' --etherscan-api-key "W5DEAR5SCEFQW5IXW2E8DU2MAIQY885SFS"

// export RPC_URL=https://api.avax.network/ext/bc/C/rpc
// forge script DeployTech1000 --rpc-url $RPC_URL --broadcast --verify --etherscan-api-key "W5DEAR5SCEFQW5IXW2E8DU2MAIQY885SFS"
// forge verify-contract <deployed address> Tech1000 --verifier-url 'https://api.snowscan.xyz/api' --etherscan-api-key "W5DEAR5SCEFQW5IXW2E8DU2MAIQY885SFS"