// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/EliteVeTokenDeadManSwitch.sol";

contract MyScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address guru = 0x167D87A906dA361A10061fe42bbe89451c2EE584;
        uint256 guruTokenId = 2153; // See https://polygonscan.com/address/0xcc835d13543cec819ac0226dd9ff35b6312b8fca#readContract

        vm.startBroadcast(privateKey);

        new EliteVeTokenDeadManSwitch(
          IVotingEscrow(0xB419cE2ea99f356BaE0caC47282B9409E38200fa),
          IVoter(0xAcCbA5e852AB85E5E3a84bc8E36795bD8cEC5C73),
          guru,
          guru,
          guruTokenId
        );

        vm.stopBroadcast();
    }
}
