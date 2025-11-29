# Deployment Scripts

This directory contains deployment scripts for the x402 AI Agent Trading Platform contracts.

## Setup

1. Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

2. Fill in your private key and other configuration in `.env`:
```bash
PRIVATE_KEY=your_private_key_here
```

**⚠️ WARNING: Never commit your `.env` file with real private keys!**

## Deploy to Monad Testnet

```bash
# Deploy all contracts
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url monad_testnet \
  --broadcast \
  --verify \
  -vvvv
```

## Verify Contracts

After deployment, verify contracts on Monad Explorer:

```bash
forge verify-contract <CONTRACT_ADDRESS> <CONTRACT_NAME> \
  --chain monad_testnet \
  --etherscan-api-key $MONAD_API_KEY
```

## Get Testnet Tokens

1. Visit Monad official faucet
2. Or use OKX faucet if available
3. Ensure your wallet has MON tokens for gas fees

## Network Information

- **Network Name**: Monad Testnet
- **RPC URL**: https://testnet-rpc.monad.xyz
- **Chain ID**: 10143
- **Currency Symbol**: MON
- **Block Explorer**: https://testnet.monadexplorer.com

