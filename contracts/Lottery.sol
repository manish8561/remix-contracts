// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;


contract Lottery {
    address public manager; // Address of the manager who organizes the lottery
    address[] public players; // Array to store addresses of participants
    uint256 public ticketPrice; // Price of a ticket in wei
    uint256 public prizePool; // Total prize pool accumulated from ticket sales
    uint256 public randomNumber; // Random number to determine the winner

    event Winner(address winner, uint256 prize);

    constructor(uint256 _ticketPrice) {
        manager = msg.sender;
        ticketPrice = _ticketPrice;
    }

    // Function to buy tickets
    function buyTicket() external payable {
        require(msg.value >= ticketPrice, "Insufficient funds sent");
        players.push(msg.sender);
        prizePool += msg.value;
    }

    // Function to generate a random number and pick a winner
    function pickWinner() external {
        require(msg.sender == manager, "Only manager can pick winner");
        require(players.length > 0, "No players participated");

        // Generate a random number using block variables
        randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, players.length)));

        // Pick a winner based on the random number
        address winner = players[randomNumber % players.length];

        // Transfer prize to the winner
        payable(winner).transfer(prizePool);

        // Reset lottery state
        delete players;
        prizePool = 0;
        randomNumber = 0;

        emit Winner(winner, prizePool);
    }

    // Function to get the number of participants
    function getNumberOfPlayers() external view returns (uint256) {
        return players.length;
    }
}
