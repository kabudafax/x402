# Agent Contract Documentation

## Overview

The `Agent` contract is the core contract for AI agents in the x402 AI Agent Trading Platform. It manages agent funds, executes trades, and calls services via x402 payments.

## Features

### 1. Fund Management

- **Deposit**: Users can deposit native tokens (MON/ETH) or ERC20 tokens (USDC, etc.)
- **Withdraw**: Owner can withdraw funds (with minimum reserve for native tokens)
- **Balance Tracking**: Tracks balances for all tokens

### 2. Trading Functions

- **Buy Token**: Execute buy trades through DEX (simplified implementation)
- **Sell Token**: Execute sell trades through DEX
- **Risk Controls**:
  - Maximum trade amount per transaction
  - Daily trading limit
  - Maximum position ratio

### 3. Service Integration

- **Call Service**: Call services with x402 payment
- **Subscribe Service**: Subscribe/unsubscribe to services
- **Payment Tracking**: Track all x402 payments made

### 4. Configuration

- **Configurable Limits**: Owner can update trading limits
- **Active Status**: Owner can pause/resume agent
- **Daily Statistics**: Track daily trading activity

## Key Functions

### Deposit

```solidity
function deposit(address token, uint256 amount) external payable
```

Deposit tokens to the agent contract.

### Withdraw

```solidity
function withdraw(address token, uint256 amount, address recipient) external onlyOwner
```

Withdraw tokens from the agent (owner only).

### Buy Token

```solidity
function buyToken(
    address token,
    uint256 amountIn,
    uint256 minAmountOut,
    address dexRouter,
    address[] calldata path
) external onlyOwner onlyActive
```

Execute a buy trade (simplified - needs DEX integration).

### Call Service

```solidity
function callService(
    address serviceAddress,
    IX402Payment.PaymentRequest calldata paymentRequest,
    bytes calldata serviceData
) external onlyOwner onlyActive returns (bytes memory)
```

Call a service with x402 payment. This is the core function that integrates x402 payments.

**Flow**:
1. Check balance for payment
2. Process x402 payment
3. Record payment
4. Call service
5. Return service result

## x402 Payment Integration

The Agent contract integrates x402 payments through the `X402PaymentHandler` contract:

1. **Payment Request**: Service provides payment request with:
   - Amount
   - Recipient address
   - Token address
   - Payment ID
   - Expiration time

2. **Payment Processing**: Agent calls `x402Payment.processPayment()`:
   - For ERC20: Approve and transfer
   - For native: Send to handler

3. **Payment Verification**: Service verifies payment before executing

## Security Features

- **ReentrancyGuard**: Prevents reentrancy attacks
- **Ownable**: Only owner can withdraw and configure
- **SafeERC20**: Safe token transfers
- **Balance Checks**: All operations check balances
- **Limit Checks**: Trading limits enforced

## Configuration

Default configuration:
- Max trade amount: 1000 USDC
- Daily trading limit: 10000 USDC
- Max position ratio: 50%
- Active: true

Owner can update these via `updateConfig()`.

## Events

- `Deposited`: When tokens are deposited
- `Withdrawn`: When tokens are withdrawn
- `TradeExecuted`: When a trade is executed
- `ServiceCalled`: When a service is called
- `X402PaymentProcessed`: When x402 payment is processed
- `ServiceSubscribed`: When service subscription changes
- `ConfigUpdated`: When configuration is updated

## Testing

See `test/Agent.t.sol` for test cases covering:
- Deposit/withdraw
- Trading limits
- Service calls
- Configuration updates

## Deployment

1. Deploy `X402PaymentHandler` first
2. Deploy `Agent` with:
   - x402 payment handler address
   - Payment token address (USDC)
   - Owner address

## Future Improvements

- Full DEX integration (Uniswap, etc.)
- More sophisticated risk controls
- Multi-signature support
- Gas optimization
- Advanced trading strategies

