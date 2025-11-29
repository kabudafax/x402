// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {X402PaymentHandler} from "../src/x402/X402PaymentHandler.sol";
import {IX402Payment} from "../src/x402/IX402Payment.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

/**
 * @title X402PaymentTest
 * @notice Tests for x402 payment handler
 */
contract X402PaymentTest is Test {
    X402PaymentHandler public x402Handler;
    MockERC20 public usdc;
    address public payer;
    address public recipient;

    function setUp() public {
        payer = address(0x1);
        recipient = address(0x2);

        x402Handler = new X402PaymentHandler();
        usdc = new MockERC20();
        usdc.mint(payer, 1000000 * 10**6);
    }

    function testProcessPayment_ERC20() public {
        uint256 amount = 100 * 10**6;
        bytes32 paymentId = keccak256("test-payment");

        IX402Payment.PaymentRequest memory request = IX402Payment.PaymentRequest({
            amount: amount,
            recipient: recipient,
            token: address(usdc),
            paymentId: paymentId,
            expiresAt: block.timestamp + 1 hours
        });

        vm.startPrank(payer);
        usdc.approve(address(x402Handler), amount);
        bool success = x402Handler.processPayment(request);
        vm.stopPrank();

        assertTrue(success);
        assertTrue(x402Handler.isPaymentProcessed(paymentId));
        assertEq(usdc.balanceOf(recipient), amount);
    }

    function testProcessPayment_NativeToken() public {
        uint256 amount = 1 ether;
        bytes32 paymentId = keccak256("native-payment");

        IX402Payment.PaymentRequest memory request = IX402Payment.PaymentRequest({
            amount: amount,
            recipient: recipient,
            token: address(0),
            paymentId: paymentId,
            expiresAt: block.timestamp + 1 hours
        });

        // Send native token to handler first
        vm.deal(address(x402Handler), amount);

        bool success = x402Handler.processPayment(request);
        assertTrue(success);
        assertTrue(x402Handler.isPaymentProcessed(paymentId));
        assertEq(recipient.balance, amount);
    }

    function testProcessPayment_Duplicate() public {
        uint256 amount = 100 * 10**6;
        bytes32 paymentId = keccak256("duplicate-payment");

        IX402Payment.PaymentRequest memory request = IX402Payment.PaymentRequest({
            amount: amount,
            recipient: recipient,
            token: address(usdc),
            paymentId: paymentId,
            expiresAt: block.timestamp + 1 hours
        });

        vm.startPrank(payer);
        usdc.approve(address(x402Handler), amount * 2);
        x402Handler.processPayment(request);

        // Try to process again
        vm.expectRevert("X402: Payment already processed");
        x402Handler.processPayment(request);
        vm.stopPrank();
    }

    function testProcessPayment_Expired() public {
        uint256 amount = 100 * 10**6;
        bytes32 paymentId = keccak256("expired-payment");

        IX402Payment.PaymentRequest memory request = IX402Payment.PaymentRequest({
            amount: amount,
            recipient: recipient,
            token: address(usdc),
            paymentId: paymentId,
            expiresAt: block.timestamp - 1 // Already expired
        });

        vm.startPrank(payer);
        usdc.approve(address(x402Handler), amount);
        vm.expectRevert("X402: Payment expired");
        x402Handler.processPayment(request);
        vm.stopPrank();
    }

    function testProcessPayment_InvalidAmount() public {
        bytes32 paymentId = keccak256("invalid-amount");

        IX402Payment.PaymentRequest memory request = IX402Payment.PaymentRequest({
            amount: 0,
            recipient: recipient,
            token: address(usdc),
            paymentId: paymentId,
            expiresAt: block.timestamp + 1 hours
        });

        vm.startPrank(payer);
        vm.expectRevert("X402: Invalid amount");
        x402Handler.processPayment(request);
        vm.stopPrank();
    }

    function testGetPayment() public {
        uint256 amount = 100 * 10**6;
        bytes32 paymentId = keccak256("get-payment");

        IX402Payment.PaymentRequest memory request = IX402Payment.PaymentRequest({
            amount: amount,
            recipient: recipient,
            token: address(usdc),
            paymentId: paymentId,
            expiresAt: block.timestamp + 1 hours
        });

        vm.startPrank(payer);
        usdc.approve(address(x402Handler), amount);
        x402Handler.processPayment(request);
        vm.stopPrank();

        (IX402Payment.PaymentRequest memory retrieved, bool processed) = 
            x402Handler.getPayment(paymentId);

        assertTrue(processed);
        assertEq(retrieved.amount, amount);
        assertEq(retrieved.recipient, recipient);
        assertEq(retrieved.token, address(usdc));
    }
}

