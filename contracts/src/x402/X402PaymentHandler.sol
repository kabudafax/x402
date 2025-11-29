// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IX402Payment} from "./IX402Payment.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title X402PaymentHandler
 * @notice Implementation of x402 protocol payment handler
 * @dev Handles payments between AI agents and service providers
 */
contract X402PaymentHandler is IX402Payment, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Mapping from paymentId to payment status
    mapping(bytes32 => bool) private _processedPayments;

    // Mapping from paymentId to payment request
    mapping(bytes32 => PaymentRequest) private _paymentRequests;

    /**
     * @notice Process a payment according to x402 protocol
     * @param request Payment request details
     * @return success True if payment was successful
     */
    function processPayment(PaymentRequest calldata request)
        external
        override
        nonReentrant
        returns (bool success)
    {
        // Validate payment request
        require(request.amount > 0, "X402: Invalid amount");
        require(request.recipient != address(0), "X402: Invalid recipient");
        require(block.timestamp < request.expiresAt, "X402: Payment expired");
        require(!_processedPayments[request.paymentId], "X402: Payment already processed");

        // Mark payment as processed before transfer to prevent reentrancy
        _processedPayments[request.paymentId] = true;
        _paymentRequests[request.paymentId] = request;

        // Execute payment
        if (request.token == address(0)) {
            // Native token payment (ETH/MON)
            require(address(this).balance >= request.amount, "X402: Insufficient balance");
            (success,) = payable(request.recipient).call{value: request.amount}("");
            require(success, "X402: Transfer failed");
        } else {
            // ERC20 token payment (USDC, etc.)
            IERC20 token = IERC20(request.token);
            require(token.balanceOf(msg.sender) >= request.amount, "X402: Insufficient balance");
            token.safeTransferFrom(msg.sender, request.recipient, request.amount);
            success = true;
        }

        // Emit event
        emit PaymentProcessed(
            request.paymentId,
            msg.sender,
            request.recipient,
            request.amount,
            request.token
        );
    }

    /**
     * @notice Check if a payment has been processed
     * @param paymentId Unique payment identifier
     * @return processed True if payment has been processed
     */
    function isPaymentProcessed(bytes32 paymentId) external view override returns (bool processed) {
        return _processedPayments[paymentId];
    }

    /**
     * @notice Get payment details
     * @param paymentId Unique payment identifier
     * @return request Payment request details
     * @return processed True if payment has been processed
     */
    function getPayment(bytes32 paymentId)
        external
        view
        override
        returns (PaymentRequest memory request, bool processed)
    {
        request = _paymentRequests[paymentId];
        processed = _processedPayments[paymentId];
    }

    /**
     * @notice Receive native tokens
     */
    receive() external payable {}
}

