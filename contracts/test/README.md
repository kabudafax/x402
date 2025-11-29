# Test Suite Documentation

## Overview

This directory contains comprehensive tests for the x402 AI Agent Trading Platform smart contracts.

## Test Files

### Unit Tests

1. **Agent.t.sol** - Tests for Agent contract
   - Deposit/withdraw functionality
   - Trading functions
   - Service calling
   - Configuration updates
   - Access control

2. **Service.t.sol** - Tests for Service contract
   - Service registration
   - Payment request generation
   - Service execution
   - Payment verification
   - Revenue withdrawal
   - Access control

3. **Market.t.sol** - Tests for Market contract
   - Service listing/delisting
   - Service discovery
   - Service rating
   - Usage tracking
   - Access control

4. **X402Payment.t.sol** - Tests for x402 payment handler
   - ERC20 payment processing
   - Native token payment processing
   - Duplicate payment prevention
   - Payment expiration
   - Payment retrieval

### Integration Tests

5. **Integration.t.sol** - End-to-end integration tests
   - Full flow: Agent purchases service
   - Full flow: Agent rates service
   - Multiple services usage
   - Service provider revenue withdrawal
   - Service discovery
   - Service updates

## Running Tests

### Run all tests
```bash
forge test
```

### Run specific test file
```bash
forge test --match-path test/Agent.t.sol
```

### Run with verbose output
```bash
forge test -vvv
```

### Run with gas reporting
```bash
forge test --gas-report
```

### Run specific test function
```bash
forge test --match-test testDeposit
```

## Test Coverage

### Agent Contract
- ✅ Deposit (ERC20 and native)
- ✅ Withdraw
- ✅ Buy token
- ✅ Sell token
- ✅ Call service with x402 payment
- ✅ Subscribe service
- ✅ Configuration updates
- ✅ Daily limit enforcement
- ✅ Max trade amount enforcement

### Service Contract
- ✅ Service registration
- ✅ Payment request generation
- ✅ Service execution
- ✅ Payment verification
- ✅ Revenue withdrawal
- ✅ Service updates
- ✅ Status management

### Market Contract
- ✅ Service listing
- ✅ Service delisting
- ✅ Service discovery (by type, all)
- ✅ Service rating
- ✅ Usage tracking
- ✅ Rating validation

### x402 Payment Handler
- ✅ ERC20 payment processing
- ✅ Native token payment processing
- ✅ Duplicate prevention
- ✅ Expiration handling
- ✅ Payment retrieval

### Integration Tests
- ✅ Complete agent-service interaction
- ✅ Payment flow
- ✅ Rating flow
- ✅ Multiple services
- ✅ Revenue withdrawal
- ✅ Service discovery

## Test Utilities

### MockERC20
Located in `test/mocks/MockERC20.sol`, provides a mock ERC20 token for testing.

## Best Practices

1. **Isolation**: Each test is independent
2. **Setup**: Use `setUp()` for common initialization
3. **Cleanup**: Tests don't affect each other
4. **Assertions**: Use clear assertion messages
5. **Events**: Test events are emitted correctly
6. **Edge Cases**: Test boundary conditions
7. **Error Cases**: Test revert conditions

## Continuous Integration

Tests should be run:
- Before every commit
- In CI/CD pipeline
- Before deployment
- After contract changes

## Coverage Goals

- Unit test coverage: > 90%
- Integration test coverage: All critical paths
- Edge case coverage: All known edge cases

## Future Test Additions

- Fuzz testing for payment amounts
- Invariant testing
- Gas optimization tests
- Stress tests for multiple concurrent operations
- Time-based tests (expiration, daily limits)

