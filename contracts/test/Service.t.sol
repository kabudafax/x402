// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Service} from "../src/Service.sol";
import {IX402Payment} from "../src/x402/IX402Payment.sol";
import {X402PaymentHandler} from "../src/x402/X402PaymentHandler.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

contract ServiceTest is Test {
    Service public service;
    X402PaymentHandler public x402Handler;
    MockERC20 public usdc;
    address public provider;
    address public caller;

    function setUp() public {
        provider = address(this);
        caller = address(0x1);

        // Deploy mock USDC
        usdc = new MockERC20();
        usdc.mint(provider, 1000000 * 10**6);
        usdc.mint(caller, 1000000 * 10**6);

        // Deploy x402 payment handler
        x402Handler = new X402PaymentHandler();

        // Deploy service
        service = new Service(
            address(x402Handler),
            "Test Strategy Service",
            "A test strategy service",
            Service.ServiceType.STRATEGY,
            100 * 10**6, // 100 USDC
            address(usdc),
            Service.PricingModel.PAY_PER_USE,
            provider
        );
    }

    function testServiceRegistration() public {
        Service.ServiceInfo memory info = service.getServiceInfo();
        
        assertEq(info.name, "Test Strategy Service");
        assertEq(uint256(info.serviceType), uint256(Service.ServiceType.STRATEGY));
        assertEq(info.price, 100 * 10**6);
        assertEq(info.provider, provider);
        assertEq(uint256(info.status), uint256(Service.ServiceStatus.ACTIVE));
    }

    function testGetPaymentRequest() public {
        IX402Payment.PaymentRequest memory request = service.getPaymentRequest(caller);
        
        assertEq(request.amount, 100 * 10**6);
        assertEq(request.recipient, address(service));
        assertEq(request.token, address(usdc));
        assertGt(request.expiresAt, block.timestamp);
    }

    function testExecuteService() public {
        // Setup: caller needs to pay for service
        uint256 servicePrice = service.getPrice();
        
        // Get payment request
        IX402Payment.PaymentRequest memory paymentRequest = service.getPaymentRequest(caller);
        
        // Approve and process payment - payment goes to service contract
        vm.startPrank(caller);
        usdc.approve(address(x402Handler), servicePrice);
        x402Handler.processPayment(paymentRequest);
        vm.stopPrank();

        // Execute service
        bytes memory input = abi.encode("test input");
        vm.prank(caller);
        bytes memory output = service.executeService(paymentRequest.paymentId, input);

        // Verify service was called
        assertTrue(service.isPaymentUsed(caller, paymentRequest.paymentId));
        
        Service.ServiceInfo memory info = service.getServiceInfo();
        assertEq(info.callCount, 1);
        assertEq(info.totalRevenue, servicePrice);
    }

    function testExecuteServiceWithoutPayment() public {
        bytes32 fakePaymentId = keccak256("fake-payment");
        bytes memory input = abi.encode("test input");

        vm.expectRevert("Service: Payment not processed");
        service.executeService(fakePaymentId, input);
    }

    function testExecuteServiceTwice() public {
        uint256 servicePrice = service.getPrice();
        IX402Payment.PaymentRequest memory paymentRequest = service.getPaymentRequest(caller);

        // First payment and execution
        vm.startPrank(caller);
        usdc.approve(address(x402Handler), servicePrice);
        x402Handler.processPayment(paymentRequest);
        vm.stopPrank();

        service.executeService(paymentRequest.paymentId, "");

        // Try to execute again with same payment
        vm.expectRevert("Service: Already called with this payment");
        service.executeService(paymentRequest.paymentId, "");
    }

    function testUpdateService() public {
        string memory newName = "Updated Service";
        string memory newDescription = "Updated description";
        uint256 newPrice = 200 * 10**6;

        service.updateService(newName, newDescription, newPrice);

        Service.ServiceInfo memory info = service.getServiceInfo();
        assertEq(info.name, newName);
        assertEq(info.description, newDescription);
        assertEq(info.price, newPrice);
    }

    function testUpdateStatus() public {
        service.updateStatus(Service.ServiceStatus.PAUSED);
        
        Service.ServiceInfo memory info = service.getServiceInfo();
        assertEq(uint256(info.status), uint256(Service.ServiceStatus.PAUSED));

        // Try to execute service when paused
        bytes32 fakePaymentId = keccak256("fake");
        vm.expectRevert("Service: Not active");
        service.executeService(fakePaymentId, "");
    }

    function testWithdrawRevenue() public {
        uint256 servicePrice = service.getPrice();
        IX402Payment.PaymentRequest memory paymentRequest = service.getPaymentRequest(caller);

        // Execute service to generate revenue
        vm.startPrank(caller);
        usdc.approve(address(x402Handler), servicePrice);
        x402Handler.processPayment(paymentRequest);
        vm.stopPrank();

        service.executeService(paymentRequest.paymentId, "");

        // Withdraw revenue
        uint256 revenue = service.getAccumulatedRevenue();
        address recipient = address(0x999);
        
        service.withdrawRevenue(revenue, recipient);
        
        assertEq(service.getAccumulatedRevenue(), 0);
        // Note: In actual implementation, USDC would be transferred to recipient
        // This test structure shows the flow
    }

    function testOnlyProviderCanUpdate() public {
        vm.startPrank(caller);
        
        vm.expectRevert("Service: Not provider");
        service.updateService("New Name", "New Desc", 100 * 10**6);
        
        vm.expectRevert("Service: Not provider");
        service.updateStatus(Service.ServiceStatus.PAUSED);
        
        vm.stopPrank();
    }
}

