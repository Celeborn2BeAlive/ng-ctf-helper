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

        EliteVeTokenDeadManSwitch dmSwitch = new EliteVeTokenDeadManSwitch(
          IVotingEscrow(0xB419cE2ea99f356BaE0caC47282B9409E38200fa),
          IVoter(0x71F6CAc5C79A9AF50f47Df0568c075A6055ba830),
          c2ba,
          safe,
          18405
        );

        vm.stopBroadcast();
    }
}
