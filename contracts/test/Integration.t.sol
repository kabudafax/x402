// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Agent} from "../src/Agent.sol";
import {Service} from "../src/Service.sol";
import {Market} from "../src/Market.sol";
import {X402PaymentHandler} from "../src/x402/X402PaymentHandler.sol";
import {IX402Payment} from "../src/x402/IX402Payment.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

/**
 * @title IntegrationTest
 * @notice End-to-end integration tests for the x402 AI Agent Trading Platform
 */
contract IntegrationTest is Test {
    X402PaymentHandler public x402Handler;
    Market public market;
    Agent public agent;
    Service public strategyService;
    Service public riskControlService;
    MockERC20 public usdc;
    
    address public agentOwner;
    address public serviceProvider1;
    address public serviceProvider2;
    address public user;

    function setUp() public {
        agentOwner = address(0x1);
        serviceProvider1 = address(0x2);
        serviceProvider2 = address(0x3);
        user = address(0x4);

        // Deploy mock USDC
        usdc = new MockERC20();
        usdc.mint(agentOwner, 1000000 * 10**6);
        usdc.mint(serviceProvider1, 1000000 * 10**6);
        usdc.mint(serviceProvider2, 1000000 * 10**6);

        // Deploy x402 payment handler
        x402Handler = new X402PaymentHandler();

        // Deploy market
        market = new Market(address(this));

        // Deploy services
        vm.startPrank(serviceProvider1);
        strategyService = new Service(
            address(x402Handler),
            "Strategy Service",
            "Provides trading signals",
            Service.ServiceType.STRATEGY,
            100 * 10**6, // 100 USDC
            address(usdc),
            Service.PricingModel.PAY_PER_USE,
            serviceProvider1
        );
        vm.stopPrank();

        vm.startPrank(serviceProvider2);
        riskControlService = new Service(
            address(x402Handler),
            "Risk Control Service",
            "Provides risk assessment",
            Service.ServiceType.RISK_CONTROL,
            50 * 10**6, // 50 USDC
            address(usdc),
            Service.PricingModel.PAY_PER_USE,
            serviceProvider2
        );
        vm.stopPrank();

        // Deploy agent
        vm.startPrank(agentOwner);
        agent = new Agent(
            address(x402Handler),
            address(usdc),
            agentOwner
        );
        vm.stopPrank();

        // List services on market
        vm.startPrank(serviceProvider1);
        market.listService(address(strategyService));
        vm.stopPrank();

        vm.startPrank(serviceProvider2);
        market.listService(address(riskControlService));
        vm.stopPrank();
    }

    function testFullFlow_AgentPurchasesService() public {
        // 1. Agent owner deposits funds
        uint256 depositAmount = 10000 * 10**6; // 10000 USDC
        vm.startPrank(agentOwner);
        usdc.approve(address(agent), depositAmount);
        agent.deposit(address(usdc), depositAmount);
        vm.stopPrank();

        assertEq(agent.getBalance(address(usdc)), depositAmount);

        // 2. Get payment request from service
        IX402Payment.PaymentRequest memory paymentRequest = 
            strategyService.getPaymentRequest(address(agent));

        assertEq(paymentRequest.amount, 100 * 10**6);
        assertEq(paymentRequest.recipient, address(strategyService));

        // 3. Agent processes payment (this happens inside agent.callService)
        // Payment will be processed when agent calls the service

        // 4. Agent calls service (from agent owner, but service will be called by agent contract)
        bytes memory inputData = abi.encode("ETH/USDC", block.timestamp);
        vm.startPrank(agentOwner);
        // First, agent needs to approve x402 handler
        usdc.approve(address(x402Handler), paymentRequest.amount);
        bytes memory result = agent.callService(
            address(strategyService),
            paymentRequest,
            abi.encodeWithSignature("executeService(bytes32,bytes)", paymentRequest.paymentId, inputData)
        );
        vm.stopPrank();

        // 5. Record service usage
        market.recordServiceUsage(address(strategyService), address(agent));

        // 6. Verify service was called
        assertTrue(strategyService.isPaymentUsed(address(agent), paymentRequest.paymentId));
        
        Service.ServiceInfo memory serviceInfo = strategyService.getServiceInfo();
        assertEq(serviceInfo.callCount, 1);
        assertEq(serviceInfo.totalRevenue, 100 * 10**6);
    }

    function testFullFlow_AgentRatesService() public {
        // Setup: Agent uses service first
        uint256 depositAmount = 10000 * 10**6;
        vm.startPrank(agentOwner);
        usdc.approve(address(agent), depositAmount);
        agent.deposit(address(usdc), depositAmount);

        // Get payment request and process payment
        IX402Payment.PaymentRequest memory paymentRequest = 
            strategyService.getPaymentRequest(address(agent));
        usdc.approve(address(x402Handler), paymentRequest.amount);
        x402Handler.processPayment(paymentRequest);

        // Call service
        agent.callService(
            address(strategyService),
            paymentRequest,
            abi.encodeWithSignature("executeService(bytes32,bytes)", paymentRequest.paymentId, "")
        );
        vm.stopPrank();

        // Record usage
        market.recordServiceUsage(address(strategyService), address(agent));

        // Agent owner rates service
        vm.startPrank(agentOwner);
        market.rateService(address(strategyService), 5, "Excellent service!");
        vm.stopPrank();

        // Verify rating
        (uint256 avgRating, uint256 ratingCount) = market.getServiceRating(address(strategyService));
        assertEq(ratingCount, 1);
        assertEq(avgRating, 5 * 100); // Scaled by 100
    }

    function testFullFlow_MultipleServices() public {
        // Setup: Deposit funds
        uint256 depositAmount = 10000 * 10**6;
        vm.startPrank(agentOwner);
        usdc.approve(address(agent), depositAmount);
        agent.deposit(address(usdc), depositAmount);

        // Use strategy service
        IX402Payment.PaymentRequest memory strategyPayment = 
            strategyService.getPaymentRequest(address(agent));
        usdc.approve(address(x402Handler), strategyPayment.amount);
        x402Handler.processPayment(strategyPayment);
        agent.callService(
            address(strategyService),
            strategyPayment,
            abi.encodeWithSignature("executeService(bytes32,bytes)", strategyPayment.paymentId, "")
        );

        // Use risk control service
        IX402Payment.PaymentRequest memory riskPayment = 
            riskControlService.getPaymentRequest(address(agent));
        usdc.approve(address(x402Handler), riskPayment.amount);
        x402Handler.processPayment(riskPayment);
        agent.callService(
            address(riskControlService),
            riskPayment,
            abi.encodeWithSignature("executeService(bytes32,bytes)", riskPayment.paymentId, "")
        );
        vm.stopPrank();

        // Record usage
        market.recordServiceUsage(address(strategyService), address(agent));
        market.recordServiceUsage(address(riskControlService), address(agent));

        // Verify both services were called
        assertTrue(strategyService.isPaymentUsed(address(agent), strategyPayment.paymentId));
        assertTrue(riskControlService.isPaymentUsed(address(agent), riskPayment.paymentId));

        // Verify agent balance decreased
        uint256 expectedBalance = depositAmount - strategyPayment.amount - riskPayment.amount;
        assertEq(agent.getBalance(address(usdc)), expectedBalance);
    }

    function testFullFlow_ServiceProviderWithdrawsRevenue() public {
        // Setup: Agent uses service
        uint256 depositAmount = 10000 * 10**6;
        vm.startPrank(agentOwner);
        usdc.approve(address(agent), depositAmount);
        agent.deposit(address(usdc), depositAmount);

        IX402Payment.PaymentRequest memory paymentRequest = 
            strategyService.getPaymentRequest(address(agent));
        usdc.approve(address(x402Handler), paymentRequest.amount);
        x402Handler.processPayment(paymentRequest);
        agent.callService(
            address(strategyService),
            paymentRequest,
            abi.encodeWithSignature("executeService(bytes32,bytes)", paymentRequest.paymentId, "")
        );
        vm.stopPrank();

        // Service provider withdraws revenue
        uint256 revenue = strategyService.getAccumulatedRevenue();
        assertEq(revenue, 100 * 10**6);

        vm.startPrank(serviceProvider1);
        strategyService.withdrawRevenue(revenue, serviceProvider1);
        vm.stopPrank();

        assertEq(strategyService.getAccumulatedRevenue(), 0);
    }

    function testFullFlow_ServiceDiscovery() public {
        // Query services by type
        (address[] memory strategyServices, uint256 total) = market.getServicesByType(
            Service.ServiceType.STRATEGY,
            0,
            10
        );

        assertEq(total, 1);
        assertEq(strategyServices.length, 1);
        assertEq(strategyServices[0], address(strategyService));

        // Query all services
        (address[] memory allServices, uint256 allTotal) = market.getAllServices(0, 10);
        assertEq(allTotal, 2);
        assertEq(allServices.length, 2);
    }

    function testFullFlow_ServiceUpdate() public {
        // Service provider updates service
        vm.startPrank(serviceProvider1);
        strategyService.updateService("Updated Strategy", "Updated description", 150 * 10**6);
        market.updateListing(address(strategyService));
        vm.stopPrank();

        // Verify update
        Market.ServiceListing memory listing = market.getServiceListing(address(strategyService));
        assertEq(listing.name, "Updated Strategy");
        assertEq(listing.price, 150 * 10**6);
    }
}

