// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface SuitLogicV0 {
    function consumeFuel() external;

    function throwFists() external view returns (bytes32);
}

contract AttackBadMechSuit1 is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        SuitLogicV0 target = SuitLogicV0(
            0x6386F128E24Db747CA5d66648F8EB0129d7ba883
        );
        address implementation = address(
            uint160(uint256(vm.load(address(target), bytes32(0))))
        );

        console.log("Implementation is", implementation);

        console.log(target.throwFists() == keccak256("WHAMM!"));
    }
}
