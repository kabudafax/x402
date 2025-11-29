# Service Contract Documentation

## Overview

The `Service` contract handles service registration, execution, and x402 payment verification for AI agent services in the x402 AI Agent Trading Platform.

## Features

### 1. Service Registration

- **Service Information**: Name, description, type, price
- **Service Types**:
  - `STRATEGY` - Strategy service (trading signals)
  - `RISK_CONTROL` - Risk control service
  - `DATA_SOURCE` - Data source service
  - `OTHER` - Other custom services
- **Pricing Models**:
  - `PAY_PER_USE` - Pay per service call
  - `SUBSCRIPTION` - Subscription model

### 2. Service Execution

- **Payment Verification**: Verifies x402 payment before execution
- **Service Logic**: Executes service-specific logic based on type
- **Call Tracking**: Tracks all service calls and payments

### 3. x402 Payment Integration

- **Payment Request Generation**: Generates payment requests for callers
- **Payment Verification**: Verifies payments via x402 handler
- **Revenue Tracking**: Tracks revenue from service calls

### 4. Provider Management

- **Update Service**: Provider can update service information
- **Update Status**: Provider can pause/resume service
- **Withdraw Revenue**: Provider can withdraw accumulated revenue

## Key Functions

### getPaymentRequest

```solidity
function getPaymentRequest(address caller) external view returns (IX402Payment.PaymentRequest memory)
```

Generates a payment request for a service call. The caller (Agent contract) uses this to create the x402 payment.

### executeService

```solidity
function executeService(bytes32 paymentId, bytes calldata input) external returns (bytes memory output)
```

Executes the service after verifying x402 payment. This is the core function that:
1. Verifies payment was processed
2. Validates payment details
3. Prevents duplicate calls
4. Executes service logic
5. Records call and revenue

**Flow**:
1. Verify payment via x402 handler
2. Validate payment details (amount, recipient, token)
3. Check if payment already used
4. Record call and update revenue
5. Execute service logic
6. Return result

### updateService

```solidity
function updateService(string memory _name, string memory _description, uint256 _price) external onlyProvider
```

Updates service information (provider only).

### withdrawRevenue

```solidity
function withdrawRevenue(uint256 amount, address recipient) external onlyProvider
```

Withdraws accumulated revenue to provider (provider only).

## x402 Payment Flow

1. **Agent calls `getPaymentRequest()`**
   - Service generates payment request with unique paymentId
   - Returns payment details (amount, recipient, token, expiresAt)

2. **Agent processes payment**
   - Agent calls x402 handler to process payment
   - Payment is transferred to service contract

3. **Agent calls `executeService()`**
   - Service verifies payment via x402 handler
   - Validates payment details
   - Executes service logic
   - Returns result

## Service Types and Logic

The `_executeServiceLogic()` function executes different logic based on service type:

- **STRATEGY**: Analyze market data, return trading signals
- **RISK_CONTROL**: Evaluate risk, return risk assessment
- **DATA_SOURCE**: Fetch and return market data
- **OTHER**: Custom service logic

Currently, this is a placeholder. In production, it would:
- Call external contracts
- Perform calculations
- Return structured data

## Security Features

- **ReentrancyGuard**: Prevents reentrancy attacks
- **Ownable**: Only provider can update and withdraw
- **Payment Verification**: Verifies all payments before execution
- **Duplicate Prevention**: Prevents using same payment twice
- **Status Check**: Only active services can be called

## Events

- `ServiceRegistered`: When service is registered
- `ServiceUpdated`: When service is updated
- `ServiceExecuted`: When service is executed
- `PaymentVerified`: When payment is verified
- `RevenueWithdrawn`: When revenue is withdrawn
- `PricingModelUpdated`: When pricing model is updated

## Testing

See `test/Service.t.sol` for test cases covering:
- Service registration
- Payment request generation
- Service execution
- Payment verification
- Revenue withdrawal
- Access control

## Deployment

1. Deploy `X402PaymentHandler` first
2. Deploy `Service` with:
   - x402 payment handler address
   - Service name and description
   - Service type
   - Service price
   - Payment token address
   - Pricing model
   - Provider address

## Integration with Agent

The Service contract is designed to work with the Agent contract:

1. Agent calls `service.getPaymentRequest(agentAddress)`
2. Agent processes payment via x402 handler
3. Agent calls `service.executeService(paymentId, inputData)`
4. Service verifies payment and executes
5. Service returns result to Agent

## Future Improvements

- More sophisticated service logic
- Service versioning
- Service analytics
- Multi-signature for provider actions
- Service reputation system
- Gas optimization

