// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract AttackBadMechSuit1 is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address target = 0x6386F128E24Db747CA5d66648F8EB0129d7ba883;
        console.log(address(uint160(uint256(vm.load(target, bytes32(0))))));
    }
}
