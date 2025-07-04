# 🔐 MultiSig Wallet using Foundry on Rootstock

A smart contract that enables multiple wallet owners to collectively manage and approve transactions before they are executed. Built using [Foundry](https://getfoundry.sh/) and deployed on the [Rootstock Testnet](https://rootstock.io/).


## 📌 Features

- Multiple Owners: Allows deploying the wallet with multiple addresses as co-owners.
- Transaction Submission: Any owner can propose a transaction to be approved.
- Confirmation Threshold: A transaction executes only after a set number of owners approve it.
- Revoke Confirmation: An owner can revoke their confirmation before execution.
- Secure Execution: Only transactions with enough approvals are executed on-chain.
- Rootstock Support: Fully compatible with the Rootstock Testnet for development and deployment.


## 📋 Prerequisites

Before running this project, make sure you have the following:

- [Foundry](https://getfoundry.sh/): Installed via curl -L https://foundry.paradigm.xyz | bash
- [Node.js](https://nodejs.org/en) and [npm](https://www.npmjs.com/) installed
- Git installed
- An RSK-compatible wallet (like MetaMask) configured with the Rootstock Testnet
- A Rootstock Testnet RPC URL (e.g., https://public-node.testnet.rsk.co)
- Some testnet RBTC (can be obtained from a [faucet](https://faucet.rootstock.io/))
- A private key (for deployment) stored safely in .env

## ⚙️ Installation



```bash
  git clone https://github.com/sainath5001/MultiSig_Wallet.git
  cd multisig_wallet
```
```bash
  forge install
```    
```bash
  forge install OpenZeppelin/openzeppelin-contracts
```    
### 🗂️ Project Structure

```
multisig-wallet-rootstock/
├── src/             # Main contract (MultiSigWallet.sol)
├── test/            # Unit tests written with Foundry
├── script/          # Deployment scripts
├── .env.example     # Environment variables template
├── foundry.toml     # Foundry configuration
└── README.md        # Project overview and setup guide
```

## 🧪 Running Tests

Run the Foundry unit tests to verify that the contract logic is working as expected:


```bash
forge test
```

🔍 For more detailed logs, use:

```bash
forge test -vv
```

Briefly list which features you’ve written tests for:
- Transaction submission and event
- Multi-owner confirmation logic
- Threshold enforcement
- Execution success/failure
- Revoke confirmation


## 🚀 Deployment

To deploy the MultiSig Wallet contract on the Rootstock Testnet, follow these steps:
    
#### 1.Set up your .env file with your private key and RPC URL:
```bash
PRIVATE_KEY=your_private_key
ROOTSTOCK_RPC=https://public-node.testnet.rsk.co
```
#### 2.✅ Set the 3 owners:
```bash
export OWNER_1=0x1234567890123456789012345678901234567890
export OWNER_2=0xabcdefabcdefabcdefabcdefabcdefabcdefabcd
export OWNER_3=0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
```
#### 3..Run the deploy script:
```bash
forge script script/DeployMultiSigWallet.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --legacy 
```
#### 4.✅ After deployment, copy the contract address:
```bash
Deployed to: 0xYourDeployedContractAddress
```
🔗 View your contract on the [Rootstock Testnet Explorer](https://explorer.testnet.rootstock.io/)
## 🧠 Key Functions

- `submitTransaction()`: Allows an owner to propose a transaction.
- `confirmTransaction()`: Lets an owner approve a proposed transaction.
- `executeTransaction()`: Executes a transaction if enough confirmations exist.
- `revokeConfirmation()`: Enables an owner to revoke their approval before execution.

## 📜 License

This project is licensed under the MIT License.
[MIT](https://choosealicense.com/licenses/mit/)

