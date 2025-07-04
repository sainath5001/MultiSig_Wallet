// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MultisigWallet is ReentrancyGuard {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public minNumOfConfirmations;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numOfConfirmations;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    // Events for off-chain tracking
    event Submit(uint256 indexed txIndex, address indexed owner);
    event Confirm(uint256 indexed txIndex, address indexed owner);
    event Execute(uint256 indexed txIndex, address indexed owner);
    event Deposit(address indexed sender, uint256 amount);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(
            !transactions[_txIndex].executed,
            "Transaction already executed"
        );
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(
            !isConfirmed[_txIndex][msg.sender],
            "Transaction already confirmed"
        );
        _;
    }

    constructor(address[] memory _owners, uint256 _minNumOfConfirmations) {
        require(_owners.length > 0, "At least one owner required");
        require(
            _minNumOfConfirmations > 0 &&
                _minNumOfConfirmations <= _owners.length,
            "Invalid number of confirmations"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        minNumOfConfirmations = _minNumOfConfirmations;
    }

    function submitTransaction(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numOfConfirmations: 0
            })
        );

        emit Submit(txIndex, msg.sender);
    }

    function confirmTransaction(
        uint256 _txIndex
    )
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numOfConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit Confirm(_txIndex, msg.sender);
    }

    function executeTransaction(
        uint256 _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) nonReentrant {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numOfConfirmations >= minNumOfConfirmations,
            "Not enough confirmations"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "Transaction failed");

        emit Execute(_txIndex, msg.sender);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(
        uint256 _txIndex
    )
        public
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 numOfConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numOfConfirmations
        );
    }
}
