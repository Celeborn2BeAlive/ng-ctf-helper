// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/WashSwapper.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// Test to run swaps
contract MyScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        WashSwapper washSwapper = WashSwapper(
            0xc18FDf3D8bc8395180c34B9b9C2204E872F66E83
        );

        // (, IERC20 baseToken0, , , , ) = washSwapper.swaps(1);
        // (, IERC20 baseToken1, , , , ) = washSwapper.swaps(2);
        // console.log(IERC20Metadata(address(baseToken0)).name());
        // console.log(IERC20Metadata(address(baseToken1)).name());

        uint[] memory swaps = new uint[](2);
        swaps[0] = 1;
        swaps[1] = 2;
        washSwapper.doSwaps(swaps);

        vm.stopBroadcast();
    }
}
