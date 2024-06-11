// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract ICO {
    address public owner; // Admin address
    IERC20 public token; // Token contract
    uint256 public tokenPrice; // Price of 1 token in wei
    uint256 public tokensSold; // Number of tokens sold
    uint256 public hardCap; // Maximum amount of tokens to be sold
    uint256 public startTime; // Start time of the ICO
    uint256 public endTime; // End time of the ICO

    event Sold(address buyer, uint256 amount);

    constructor(
        address _tokenAddress,
        uint256 _tokenPrice,
        uint256 _hardCap,
        uint256 _startTime,
        uint256 _durationInDays
    ) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
        tokenPrice = _tokenPrice;
        hardCap = _hardCap; // maximum token sold
        startTime = _startTime;
        endTime = startTime + (_durationInDays * 1 days);
    }

    // Modifier to ensure only the owner can call a function
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    // price of token price depends on eth value 1 eth = 20 token
    function setTokenPrice(uint _tokenPrice) public onlyOwner {
        require(_tokenPrice > 0,"Token Price must be greater than zero");
        tokenPrice = _tokenPrice;
    }

    // Function to buy tokens
    function buyTokens(uint256 _numberOfTokens) external payable {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "ICO is not active");
        require(tokensSold + _numberOfTokens <= hardCap, "Exceeds hard cap");
        require(msg.value == _numberOfTokens * tokenPrice, "Incorrect ether amount");

        require(token.transfer(msg.sender, _numberOfTokens), "Token transfer failed");

        tokensSold += _numberOfTokens;

        emit Sold(msg.sender, _numberOfTokens);
    }

    // Function to withdraw ether
    function withdrawEther() external  onlyOwner  {
        // Transfer funds to the owner
        (bool sent, ) = payable(owner).call{value: address(this).balance}("");
        require(sent, "Failed to send ether");
    }

    // Function to withdraw unsold tokens
    function withdrawUnsoldTokens() external onlyOwner {
        require(block.timestamp > endTime, "ICO is still active");

        uint256 remainingTokens = token.balanceOf(address(this)) - tokensSold;
        require(remainingTokens > 0, "No remaining tokens");

        require(token.transfer(owner, remainingTokens), "Token transfer failed");
    }
}
