// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/WashSwapper.sol";

// Fix swaps: elRETRO-MATIC should doBuy, not doSell
contract MyScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        WashSwapper washSwapper = WashSwapper(
            0xc18FDf3D8bc8395180c34B9b9C2204E872F66E83
        );
        IERC20 WMATIC = IERC20(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
        IERC20 elRETRO = IERC20(0xFAB311FE3E3be4bB3fEd77257EE294Fb22Fa888b);
        ISwapRouter retroSwapRouter = ISwapRouter(
            0x1891783cb3497Fdad1F25C933225243c2c7c4102
        );
        WashSwapper.SwapParams[] memory swaps = new WashSwapper.SwapParams[](1);
        swaps[0] = WashSwapper.SwapParams({
            swapRouter: retroSwapRouter,
            baseToken: elRETRO,
            quoteToken: WMATIC,
            poolFee: 10000,
            doBuy: true,
            doSell: false
        });
        washSwapper.addSwaps(swaps);

        vm.stopBroadcast();
    }
}
