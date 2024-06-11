// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

interface IDex {
    function getSwapPrice(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256);

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address spender
    ) external view returns (uint256);
}

contract TokenSwapAggregator {
    address[] public dexes;

    constructor(address[] memory _dexes) {
        dexes = _dexes;
    }

    function getBestPrice(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) public view returns (address bestDex, uint256 bestPrice) {
        bestPrice = 0;
        bestDex = address(0);

        for (uint256 i = 0; i < dexes.length; i++) {
            uint256 price = IDex(dexes[i]).getSwapPrice(
                tokenIn,
                tokenOut,
                amountIn
            );
            if (price > bestPrice) {
                bestPrice = price;
                bestDex = dexes[i];
            }
        }
    }

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external {
        (address bestDex, uint256 bestPrice) = getBestPrice(
            tokenIn,
            tokenOut,
            amountIn
        );
        require(bestDex != address(0), "No DEX found for the given pair");

        // Assuming the user has approved this contract to spend their tokens
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(bestDex, amountIn);

        // Swap tokens using the best DEX
        IDex(bestDex).swap(tokenIn, tokenOut, amountIn, msg.sender);
    }
}
