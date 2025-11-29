// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {X402PaymentHandler} from "../src/x402/X402PaymentHandler.sol";
import {Agent} from "../src/Agent.sol";
import {Service} from "../src/Service.sol";
import {Market} from "../src/Market.sol";

/**
 * @title DeployScript
 * @notice Deployment script for x402 AI Agent Trading Platform
 */
contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying contracts with account:", deployer);
        console.log("Account balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy X402PaymentHandler first (required by all other contracts)
        console.log("\n=== Deploying X402PaymentHandler ===");
        X402PaymentHandler x402Handler = new X402PaymentHandler();
        console.log("X402PaymentHandler deployed at:", address(x402Handler));
        
        // 2. Deploy Market contract
        console.log("\n=== Deploying Market ===");
        Market market = new Market(deployer);
        console.log("Market deployed at:", address(market));
        
        // 3. Deploy example services (optional - for testing)
        console.log("\n=== Deploying Example Services ===");
        
        // Example: Strategy Service
        address mockUSDC = vm.envAddress("MOCK_USDC_ADDRESS"); // Set in .env
        Service strategyService = new Service(
            address(x402Handler),
            "Example Strategy Service",
            "Provides trading signals based on technical indicators",
            Service.ServiceType.STRATEGY,
            100 * 10**6, // 100 USDC
            mockUSDC,
            Service.PricingModel.PAY_PER_USE,
            deployer
        );
        console.log("Strategy Service deployed at:", address(strategyService));
        
        // Example: Risk Control Service
        Service riskService = new Service(
            address(x402Handler),
            "Example Risk Control Service",
            "Provides risk assessment for trades",
            Service.ServiceType.RISK_CONTROL,
            50 * 10**6, // 50 USDC
            mockUSDC,
            Service.PricingModel.PAY_PER_USE,
            deployer
        );
        console.log("Risk Control Service deployed at:", address(riskService));
        
        vm.stopBroadcast();
        
        console.log("\n=== Deployment Summary ===");
        console.log("X402PaymentHandler:", address(x402Handler));
        console.log("Market:", address(market));
        console.log("Strategy Service:", address(strategyService));
        console.log("Risk Control Service:", address(riskService));
        console.log("\n=== Next Steps ===");
        console.log("1. List services on market:");
        console.log("   market.listService(address(strategyService))");
        console.log("   market.listService(address(riskService))");
        console.log("2. Users can now deploy Agent contracts with:");
        console.log("   new Agent(address(x402Handler), mockUSDC, userAddress)");
    }
}
