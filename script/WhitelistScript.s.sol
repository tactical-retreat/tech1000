// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Tech1000.sol";

contract WhitelistScript is Script {
    // This is the fuji test deployment.
    address constant CONTRACT_ADDRESS = 0x42d50F7cc597e52Ef7666e9799a5291BAE99eA94;

    function run() public {
        address[] memory addresses = new address[](4);
        // Addresses provided for WL testing on fuji.
        addresses[0] = 0xE98fAA3D5029d7c18f5B955bCF813aE1e0B03338;
        addresses[1] = 0xf4170848C96E04f3d9C4a568d099A8c2dEaF3FcD;
        addresses[2] = 0xC4C55Cb8685CA32211cEb2E42d0C6156240055a5;
        addresses[3] = 0x90B780d7546ab754e35e0d2E80d76557A012D4fE;

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Tech1000 tech1000 = Tech1000(CONTRACT_ADDRESS);

        // Add addresses to whitelist with 10 mints each.
        tech1000.addToWhitelist(addresses, 10);

        vm.stopBroadcast();
    }
}

// export PRIVATE_KEY=<private key>

// export RPC_URL=https://api.avax-test.network/ext/bc/C/rpc
// forge script WhitelistScript --rpc-url $RPC_URL --broadcast

// export RPC_URL=https://api.avax.network/ext/bc/C/rpc
// forge script WhitelistScript --rpc-url $RPC_URL --broadcast