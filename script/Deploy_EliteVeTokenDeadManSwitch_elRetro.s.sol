// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/EliteVeTokenDeadManSwitch.sol";

contract MyScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address c2ba = vm.envAddress("C2BA");
        address safe = vm.envAddress("SAFE");

        vm.startBroadcast(privateKey);

        new EliteVeTokenDeadManSwitch(
          IVotingEscrow(0xB419cE2ea99f356BaE0caC47282B9409E38200fa),
          IVoter(0xAcCbA5e852AB85E5E3a84bc8E36795bD8cEC5C73),
          c2ba,
          safe,
          18405
        );

        vm.stopBroadcast();
    }
}
