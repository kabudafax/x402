// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IX402Payment
 * @notice Interface for x402 protocol payment functionality
 * @dev This interface defines the standard for x402 payments in the AI Agent Trading Platform
 */
interface IX402Payment {
    /**
     * @notice Payment request structure
     * @param amount Payment amount in token's smallest unit
     * @param recipient Address to receive the payment
     * @param token Token address (address(0) for native token)
     * @param paymentId Unique payment identifier
     * @param expiresAt Payment expiration timestamp
     */
    struct PaymentRequest {
        uint256 amount;
        address recipient;
        address token;
        bytes32 paymentId;
        uint256 expiresAt;
    }

    /**
     * @notice Emitted when a payment is processed
     * @param paymentId Unique payment identifier
     * @param payer Address making the payment
     * @param recipient Address receiving the payment
     * @param amount Payment amount
     * @param token Token address
     */
    event PaymentProcessed(
        bytes32 indexed paymentId,
        address indexed payer,
        address indexed recipient,
        uint256 amount,
        address token
    );

    /**
     * @notice Process a payment according to x402 protocol
     * @param request Payment request details
     * @return success True if payment was successful
     */
    function processPayment(PaymentRequest calldata request) external returns (bool success);

    /**
     * @notice Check if a payment has been processed
     * @param paymentId Unique payment identifier
     * @return processed True if payment has been processed
     */
    function isPaymentProcessed(bytes32 paymentId) external view returns (bool processed);

    /**
     * @notice Get payment details
     * @param paymentId Unique payment identifier
     * @return request Payment request details
     * @return processed True if payment has been processed
     */
    function getPayment(bytes32 paymentId)
        external
        view
        returns (PaymentRequest memory request, bool processed);
}

