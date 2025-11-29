.PHONY: install build test clean deploy verify

# Install dependencies
install:
	forge install

# Build contracts
build:
	forge build

# Run tests
test:
	forge test -vvv

# Clean build artifacts
clean:
	forge clean

# Deploy to Monad testnet
deploy:
	@echo "Deploying contracts to Monad testnet..."
	forge script scripts/Deploy.s.sol:DeployScript \
		--rpc-url monad_testnet \
		--broadcast \
		--verify \
		-vvvv

# Verify contracts
verify:
	@echo "Verifying contracts on Monad Explorer..."
	@if [ -z "$(CONTRACT_ADDRESS)" ] || [ -z "$(CONTRACT_NAME)" ]; then \
		echo "Usage: make verify CONTRACT_ADDRESS=<address> CONTRACT_NAME=<name>"; \
		exit 1; \
	fi
	forge verify-contract $(CONTRACT_ADDRESS) $(CONTRACT_NAME) \
		--chain monad_testnet \
		--etherscan-api-key $$MONAD_API_KEY

# Run tests with coverage
coverage:
	forge coverage

# Format code
fmt:
	forge fmt

# Lint code
lint:
	forge fmt --check

# Start local node (if available)
node:
	anvil

