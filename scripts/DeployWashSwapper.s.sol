// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/WashSwapper.sol";

// Deploy WashSwapper, add initial swaps on elRETRO-MATIC and JRT-WETH on Retro, set roles
contract MyScript is Script {
    function run() external {
        address me = vm.envAddress("ME");
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address c2ba = vm.envAddress("C2BA");
        vm.startBroadcast(privateKey);

        WashSwapper washSwapper = new WashSwapper();
        washSwapper.grantRole(washSwapper.DEFAULT_ADMIN_ROLE(), c2ba);
        washSwapper.grantRole(washSwapper.SWAPPER(), c2ba);
        washSwapper.grantRole(washSwapper.SWAPPER(), me);

        IERC20 WMATIC = IERC20(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
        IERC20 elRETRO = IERC20(0xFAB311FE3E3be4bB3fEd77257EE294Fb22Fa888b);
        IERC20 JRT = IERC20(0x596eBE76e2DB4470966ea395B0d063aC6197A8C5);
        IERC20 WETH = IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
        ISwapRouter retroSwapRouter = ISwapRouter(
            0x1891783cb3497Fdad1F25C933225243c2c7c4102
        );

        WashSwapper.SwapParams[] memory swaps = new WashSwapper.SwapParams[](2);
        swaps[0] = WashSwapper.SwapParams({
            swapRouter: retroSwapRouter,
            baseToken: elRETRO,
            quoteToken: WMATIC,
            poolFee: 10000,
            doBuy: false,
            doSell: true
        });
        swaps[1] = WashSwapper.SwapParams({
            swapRouter: retroSwapRouter,
            baseToken: JRT,
            quoteToken: WETH,
            poolFee: 3000,
            doBuy: true,
            doSell: true
        });

        washSwapper.addSwaps(swaps);

        vm.stopBroadcast();
    }
}
