// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Tech1000.sol";
import "./utils/Airdrop.sol";

contract WhitelistScript is Script {
    string constant FILE_PATH = "script/whitelist.csv";
    address constant CONTRACT_ADDRESS = 0x8E29FeAa0853e4148406b5c2aD30F143e08ccB98;
    uint256 WL_COUNT = 10;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Tech1000 tech1000 = Tech1000(CONTRACT_ADDRESS);

        (address[] memory recipients, uint256[] memory amounts) = readAirdropData(vm, FILE_PATH);

        tech1000.addToWhitelist(recipients, 10);

        vm.stopBroadcast();
    }
}

// export PRIVATE_KEY=<private key>

// export RPC_URL=https://api.avax-test.network/ext/bc/C/rpc
// export RPC_URL=https://api.avax.network/ext/bc/C/rpc
// forge script WhitelistScript --rpc-url $RPC_URL
// forge script WhitelistScript --rpc-url $RPC_URL --broadcast
