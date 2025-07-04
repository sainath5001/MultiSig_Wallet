//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MultisigWallet} from "../src/MultiSigWallet.sol";
import "forge-std/console.sol";
// This script deploys a MultisigWallet contract with three owners and a minimum of two confirmations required for transactions.

contract DeployMultiSigWallet is Script {
    function run() external {
        address[] memory owners = new address[](3);
        owners[0] = vm.envAddress("OWNER_1");
        owners[1] = vm.envAddress("OWNER_2");
        owners[2] = vm.envAddress("OWNER_3");

        uint256 minNumOfConfirmations = 2;

        vm.startBroadcast();
        MultisigWallet multisigWallet = new MultisigWallet(owners, minNumOfConfirmations);
        vm.stopBroadcast();

        console.log("Multisig Wallet deployed at:", address(multisigWallet));
    }
}
