// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract TokenTransfer {
    IERC20 public token; // Declare a state variable of type IERC20
    address public owner; // Owner of the contract
    uint public timeInterval = 30; // 30 seconds
    uint public withdrawLock;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress); // Initialize the token contract address
        owner = msg.sender; // Set the contract creator as the owner
        withdrawLock = block.timestamp + timeInterval;
    }

    function transferTokens(
        address _from,
        address _to,
        uint256 _amount
    ) external {
        require(_from != address(0), "Invalid sender address");
        require(_to != address(0), "Invalid recipient address");
        require(_amount > 0, "Invalid amount");

        // Ensure the sender has enough balance to transfer
        require(token.balanceOf(_from) >= _amount, "Insufficient balance");

        // Perform the transfer
        bool success = token.transferFrom(_from, _to, _amount);
        require(success, "Transfer failed");
    }

    // Modifier to ensure only the owner can call a function
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function setTimeInterval(uint _interval) public onlyOwner{
        require(_interval>0,"Invalid interval");
        timeInterval=_interval;
    }
    
    function deposit() external payable {
        require(msg.value > 0, "Invalid value");
        withdrawLock = block.timestamp + timeInterval;
    }
    
    // Function to allow the owner to withdraw funds from the contract
    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Invalid amount");
        require(address(this).balance >= _amount, "Insufficient balance");
        require(withdrawLock < block.timestamp,"Withdraw is locked try after some time");

        withdrawLock = block.timestamp + timeInterval;

        // Transfer funds to the owner
        (bool sent, ) = payable(owner).call{value: _amount}("");
        require(sent, "Failed to send ether");
    }

    // Fallback function to receive ether
    receive() external payable {}

    fallback() external payable {}
}
