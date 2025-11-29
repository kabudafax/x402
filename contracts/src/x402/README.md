# x402 Protocol Integration

This directory contains the x402 protocol integration for the AI Agent Trading Platform.

## Files

- `IX402Payment.sol` - Interface for x402 payment functionality
- `X402PaymentHandler.sol` - Implementation of x402 payment handler

## Usage

### In Agent Contract

```solidity
import {IX402Payment} from "./x402/IX402Payment.sol";

contract Agent {
    IX402Payment public x402Payment;
    
    function callService(address serviceAddress, bytes calldata data) external {
        // Get payment request from service
        IX402Payment.PaymentRequest memory paymentRequest = ...;
        
        // Process payment
        x402Payment.processPayment(paymentRequest);
        
        // Call service
        // ...
    }
}
```

### In Service Contract

```solidity
import {IX402Payment} from "./x402/IX402Payment.sol";

contract Service {
    IX402Payment public x402Payment;
    
    function executeService(bytes calldata input) external returns (bytes memory) {
        // Verify payment
        bytes32 paymentId = ...;
        require(x402Payment.isPaymentProcessed(paymentId), "Payment not processed");
        
        // Execute service logic
        // ...
        
        return result;
    }
}
```

## Payment Flow

1. **Service generates payment request**
   - Amount, recipient, token, paymentId, expiresAt

2. **Agent processes payment**
   - Calls `x402Payment.processPayment(request)`
   - Payment is transferred to service provider

3. **Service verifies payment**
   - Checks `x402Payment.isPaymentProcessed(paymentId)`
   - Executes service if payment is valid

## Security Considerations

- Payment expiration is enforced
- Duplicate payments are prevented via paymentId
- Reentrancy protection is implemented
- SafeERC20 is used for token transfers

