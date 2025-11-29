# Smart Contracts

This directory contains the smart contracts for the x402 AI Agent Trading Platform.

## Project Structure

```
contracts/
├── src/
│   ├── Agent.sol          # AI Agent contract
│   ├── Service.sol        # Service contract
│   ├── Market.sol         # Market contract
│   └── x402/              # x402 protocol integration
├── test/
│   ├── Agent.t.sol        # Agent contract tests
│   ├── Service.t.sol      # Service contract tests
│   └── Market.t.sol       # Market contract tests
├── scripts/
│   └── Deploy.s.sol       # Deployment script
├── foundry.toml           # Foundry configuration
└── .env.example           # Environment variables example
```

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js 18+ (for some tooling)

## Installation

1. Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Install dependencies:
```bash
make install
# or
forge install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

## Development

### Build Contracts

```bash
make build
# or
forge build
```

### Run Tests

```bash
make test
# or
forge test
```

### Format Code

```bash
make fmt
# or
forge fmt
```

## Deployment

### Deploy to Monad Testnet

1. Ensure you have MON testnet tokens in your wallet
2. Configure your `.env` file with your private key
3. Deploy:

```bash
make deploy
# or
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url monad_testnet \
  --broadcast \
  --verify \
  -vvvv
```

### Verify Contracts

After deployment, verify contracts on Monad Explorer:

```bash
make verify CONTRACT_ADDRESS=<address> CONTRACT_NAME=<ContractName>
```

## Network Configuration

### Monad Testnet

- **Network Name**: Monad Testnet
- **RPC URL**: https://testnet-rpc.monad.xyz
- **Chain ID**: 10143
- **Currency Symbol**: MON
- **Block Explorer**: https://testnet.monadexplorer.com

## Contract Overview

### Agent Contract

Manages AI agent funds, executes trades, and calls services.

### Service Contract

Registers services, handles service calls, and processes x402 payments.

### Market Contract

Manages the service marketplace, service discovery, and ratings.

## Testing

Run all tests:
```bash
forge test
```

Run specific test file:
```bash
forge test --match-path test/Agent.t.sol
```

Run tests with verbose output:
```bash
forge test -vvv
```

## Security

- All contracts should be audited before mainnet deployment
- Use `forge test` to run comprehensive test suite
- Review gas optimizations
- Check for common vulnerabilities (reentrancy, overflow, etc.)

## License

MIT

