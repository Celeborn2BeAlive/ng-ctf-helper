// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WashSwapper {
    address public owner;
    address public swapper;

    struct SwapParams {
        ISwapRouter swapRouter;
        IERC20 baseToken;
        IERC20 quoteToken;
        uint24 poolFee;
        bool doBuy;
        bool doSell;
    }
    SwapParams[] public swaps;

    constructor() {
        owner = msg.sender;
        swapper = msg.sender;
    }

    function setSwapper(address _swapper) external {
        require(owner == msg.sender, "Only owner");
        swapper = _swapper;
    }

    function addSwap(SwapParams memory _swap) external {
        require(owner == msg.sender, "Only owner");
        swaps.push(_swap);
    }

    function doSwaps(uint[] memory _swaps) external {
        require(swapper == msg.sender, "Only swapper");
        for (uint i = 0; i < _swaps.length; ++i) {
            SwapParams storage swap = swaps[i];
            _doSwap(
                swap.swapRouter,
                swap.baseToken,
                swap.quoteToken,
                swap.poolFee,
                swap.doBuy,
                swap.doSell
            );
        }
    }

    function _doSwap(
        ISwapRouter swapRouter,
        IERC20 baseToken,
        IERC20 quoteToken,
        uint24 poolFee,
        bool doBuy,
        bool doSell
    ) internal returns (uint256 baseAmountOut, uint256 quoteAmountOut) {
        uint baseBalance = baseToken.balanceOf(address(this));
        if (baseBalance > 0 && doSell) {
            uint amountIn = (50 * baseBalance) / 1000; // 5% of bag
            TransferHelper.safeApprove(
                address(baseToken),
                address(swapRouter),
                amountIn
            );

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
                .ExactInputSingleParams({
                    tokenIn: address(baseToken),
                    tokenOut: address(quoteToken),
                    fee: poolFee,
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: amountIn,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

            // The call to `exactInputSingle` executes the swap.
            baseAmountOut = swapRouter.exactInputSingle(params);
        }

        uint quoteBalance = quoteToken.balanceOf(address(this));
        if (quoteBalance > 0 && doBuy) {
            uint amountIn = (50 * quoteBalance) / 1000; // 5% of bag
            TransferHelper.safeApprove(
                address(quoteToken),
                address(swapRouter),
                amountIn
            );

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
                .ExactInputSingleParams({
                    tokenIn: address(quoteToken),
                    tokenOut: address(baseToken),
                    fee: poolFee,
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: amountIn,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

            // The call to `exactInputSingle` executes the swap.
            quoteAmountOut = swapRouter.exactInputSingle(params);
        }
    }

    function deposit(IERC20 tokenIn, uint256 amountIn) external {
        TransferHelper.safeTransferFrom(
            address(tokenIn),
            msg.sender,
            address(this),
            amountIn
        );
    }

    function withdraw(IERC20 token) external {
        require(owner == msg.sender, "Only owner");
        TransferHelper.safeTransfer(
            address(token),
            msg.sender,
            token.balanceOf(address(this))
        );
    }
}