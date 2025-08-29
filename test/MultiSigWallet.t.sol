//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployMultiSigWallet} from "../script/DeployMultiSigWallet.s.sol";
import {MultisigWallet} from "../src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultisigWallet multisig;
    address[] public owners;
    address public owner1 = address(0x1);
    address public owner2 = address(0x2);
    address public owner3 = address(0x3);
    address public nonOwner = address(0x4);

    function setUp() public {
        owners.push(owner1);
        owners.push(owner2);
        owners.push(owner3);

        vm.prank(owner1); // simulate owner1 deploying the contract
        multisig = new MultisigWallet(owners, 2);

        // Fund the wallet with 1 ETH
        vm.deal(address(multisig), 1 ether);
    }

    function testSubmitTransaction() public {
        vm.prank(owner1);
        multisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");

        assertEq(multisig.getTransactionCount(), 1);
    }

    function testConfirmTransaction() public {
        vm.prank(owner1);
        multisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");

        vm.prank(owner1);
        multisig.confirmTransaction(0);

        // check internal state using a view call
        (,,,, uint256 numConfirmations) = multisig.getTransaction(0);
        assertEq(numConfirmations, 1);
    }

    function testCannotConfirmTwice() public {
        vm.prank(owner1);
        multisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");

        vm.prank(owner1);
        multisig.confirmTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("Transaction already confirmed");
        multisig.confirmTransaction(0);
    }

    function testNonOwnerCannotSubmit() public {
        vm.prank(nonOwner);
        vm.expectRevert("Not owner");
        multisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");
    }

    function testExecuteFailsBeforeMinConfirmations() public {
        vm.prank(owner1);
        multisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");

        vm.prank(owner1);
        multisig.confirmTransaction(0);

        vm.prank(owner1);
        vm.expectRevert("Not enough confirmations");
        multisig.executeTransaction(0);
    }

    function testExecuteTransactionSuccess() public {
        address payable recipient = payable(address(0xABCD));

        uint256 initialBalance = recipient.balance;

        vm.prank(owner1);
        multisig.submitTransaction(recipient, 0.1 ether, "");

        vm.prank(owner1);
        multisig.confirmTransaction(0);

        vm.prank(owner2);
        multisig.confirmTransaction(0);

        vm.prank(owner1);
        multisig.executeTransaction(0);

        assertEq(recipient.balance, initialBalance + 0.1 ether);

        // Ensure the transaction is marked as executed
        (,,, bool executed,) = multisig.getTransaction(0);
        assertTrue(executed);
    }

    function testDepositEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Deposit(address(this), 1 ether);

        (bool sent,) = address(multisig).call{value: 1 ether}("");
        assertTrue(sent);
    }

    function testGetTransaction() public {
        vm.prank(owner1);
        multisig.submitTransaction(payable(address(0xABCD)), 0.5 ether, "");

        (address to, uint256 value,, bool executed,) = multisig.getTransaction(0);

        assertEq(to, address(0xABCD));
        assertEq(value, 0.5 ether);
        assertFalse(executed);
    }

    // function testGetTransactionCount() public {
    //     vm.prank(owner1);
    //     multisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");

    //     uint256 count = multisig.getTransactionCount();
    //     assertEq(count, 2);
    // }

    function testGetTransactionCount() public {
        vm.prank(owner1);
        multisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");

        uint256 count = multisig.getTransactionCount();
        assertEq(count, 2);
    }

    function testfuzzing() public {
        DeployMultiSigWallet deployer = new DeployMultiSigWallet();
        address multisigAddress = deployer.run();
        MultisigWallet fuzzingMultisig = MultisigWallet(multisigAddress);

        vm.startPrank(owner1);
        fuzzingMultisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");
        vm.stopPrank();

        // Fuzzing logic can be added here
    }

    function testfuzzingWithMultipleOwners() public {
        DeployMultiSigWallet deployer = new DeployMultiSigWallet();
        address multisigAddress = deployer.run();
        MultisigWallet fuzzingMultisig = MultisigWallet(multisigAddress);

        vm.startPrank(owner1);
        fuzzingMultisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");
        vm.stopPrank();

        // Fuzzing logic can be added here
    }

    function testFuzzingWithMultipleOwnersAndTransactions() public {
        DeployMultiSigWallet deployer = new DeployMultiSigWallet();
        address multisigAddress = deployer.run();
        MultisigWallet fuzzingMultisig = MultisigWallet(multisigAddress);

        vm.startPrank(owner1);
        fuzzingMultisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");
        fuzzingMultisig.submitTransaction(payable(address(0xEF GH)), 0.2 ether, "");
        vm.stopPrank();

        // Fuzzing logic can be added here
    }

    function testfuzzingconformTransaction() public {
        DeployMultiSigWallet deployer = new DeployMultiSigWallet();
        address multisigAddress = deployer.run();
        MultisigWallet fuzzingMultisig = MultisigWallet(multisigAddress);
        vm.startPrank(owner1);
        fuzzingMultisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");
        vm.stopPrank();
        vm.startPrank(owner2);
        fuzzingMultisig.confirmTransaction(0);
        vm.stopPrank();
        // Fuzzing logic can be added here
    }

    function testfuzzingConfirmTransaction() public {
        DeployMultiSigWallet deployer = new DeployMultiSigWallet();
        address multisigAddress = deployer.run();
        MultisigWallet fuzzingMultisig = MultisigWallet(multisigAddress);
        vm.startPrank(owner1);
        fuzzingMultisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");
        vm.stopPrank();
        vm.startPrank(owner2);
        fuzzingMultisig.confirmTransaction(0);
        vm.stopPrank();
        // Fuzzing logic can be added here
    }

    function testFuzzingExecuteTransaction() public {
        DeployMultiSigWallet deployer = new DeployMultiSigWallet();
        address multisigAddress = deployer.run();
        MultisigWallet fuzzingMultisig = MultisigWallet(multisigAddress);

        vm.startPrank(owner1);
        fuzzingMultisig.submitTransaction(payable(address(0xABCD)), 0.1 ether, "");
        fuzzingMultisig.confirmTransaction(0);
        fuzzingMultisig.confirmTransaction(0);
        vm.stopPrank();

        vm.startPrank(owner1);
        fuzzingMultisig.executeTransaction(0);
        vm.stopPrank();

        // Fuzzing logic can be added here
    }
}
