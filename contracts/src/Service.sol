// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IX402Payment} from "./x402/IX402Payment.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Service
 * @notice Service contract for AI agent services (strategy, risk control, data source, etc.)
 * @dev Handles service registration, execution, and x402 payment verification
 */
contract Service is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    // ============ Enums ============

    /// @notice Service types
    enum ServiceType {
        STRATEGY,        // Strategy service
        RISK_CONTROL,    // Risk control service
        DATA_SOURCE,     // Data source service
        OTHER            // Other services
    }

    /// @notice Service status
    enum ServiceStatus {
        ACTIVE,          // Service is active
        PAUSED,          // Service is paused
        DELISTED         // Service is delisted
    }

    // ============ State Variables ============

    /// @notice x402 payment handler address
    IX402Payment public x402Payment;

    /// @notice Service information
    struct ServiceInfo {
        string name;                    // Service name
        string description;             // Service description
        ServiceType serviceType;        // Service type
        uint256 price;                  // Service price (in payment token)
        address paymentToken;           // Payment token address
        ServiceStatus status;           // Service status
        address provider;               // Service provider address
        uint256 callCount;              // Total call count
        uint256 totalRevenue;           // Total revenue
        uint256 createdAt;              // Creation timestamp
        uint256 updatedAt;              // Last update timestamp
    }

    ServiceInfo public serviceInfo;

    /// @notice Pricing model
    enum PricingModel {
        PAY_PER_USE,    // Pay per use
        SUBSCRIPTION    // Subscription model
    }

    PricingModel public pricingModel;

    /// @notice Service call history (caller => paymentId => timestamp)
    mapping(address => mapping(bytes32 => uint256)) public callHistory;

    /// @notice Accumulated revenue (can be withdrawn by provider)
    uint256 public accumulatedRevenue;

    /// @notice Payment token balance
    mapping(address => uint256) public tokenBalances;

    // ============ Events ============

    event ServiceRegistered(
        string name,
        ServiceType serviceType,
        uint256 price,
        address provider
    );
    event ServiceUpdated(
        string name,
        uint256 price,
        ServiceStatus status
    );
    event ServiceExecuted(
        address indexed caller,
        bytes32 indexed paymentId,
        bytes input,
        bytes output
    );
    event PaymentVerified(
        bytes32 indexed paymentId,
        address indexed payer,
        uint256 amount
    );
    event RevenueWithdrawn(
        address indexed provider,
        uint256 amount,
        address token
    );
    event PricingModelUpdated(PricingModel model);

    // ============ Modifiers ============

    modifier onlyActive() {
        require(
            serviceInfo.status == ServiceStatus.ACTIVE,
            "Service: Not active"
        );
        _;
    }

    modifier onlyProvider() {
        require(msg.sender == serviceInfo.provider, "Service: Not provider");
        _;
    }

    // ============ Constructor ============

    /**
     * @notice Initialize Service contract
     * @param _x402Payment x402 payment handler address
     * @param _name Service name
     * @param _description Service description
     * @param _serviceType Service type
     * @param _price Service price
     * @param _paymentToken Payment token address
     * @param _pricingModel Pricing model
     * @param _provider Service provider address
     */
    constructor(
        address _x402Payment,
        string memory _name,
        string memory _description,
        ServiceType _serviceType,
        uint256 _price,
        address _paymentToken,
        PricingModel _pricingModel,
        address _provider
    ) Ownable(_provider) {
        require(_x402Payment != address(0), "Service: Invalid x402 payment");
        require(_paymentToken != address(0), "Service: Invalid payment token");
        require(_provider != address(0), "Service: Invalid provider");
        require(_price > 0, "Service: Invalid price");

        x402Payment = IX402Payment(_x402Payment);
        pricingModel = _pricingModel;

        serviceInfo = ServiceInfo({
            name: _name,
            description: _description,
            serviceType: _serviceType,
            price: _price,
            paymentToken: _paymentToken,
            status: ServiceStatus.ACTIVE,
            provider: _provider,
            callCount: 0,
            totalRevenue: 0,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        emit ServiceRegistered(_name, _serviceType, _price, _provider);
    }

    // ============ Provider Functions ============

    /**
     * @notice Update service information
     * @param _name New service name
     * @param _description New service description
     * @param _price New service price
     */
    function updateService(
        string memory _name,
        string memory _description,
        uint256 _price
    ) external onlyProvider {
        require(_price > 0, "Service: Invalid price");
        
        serviceInfo.name = _name;
        serviceInfo.description = _description;
        serviceInfo.price = _price;
        serviceInfo.updatedAt = block.timestamp;

        emit ServiceUpdated(_name, _price, serviceInfo.status);
    }

    /**
     * @notice Update service status
     * @param _status New service status
     */
    function updateStatus(ServiceStatus _status) external onlyProvider {
        serviceInfo.status = _status;
        serviceInfo.updatedAt = block.timestamp;

        emit ServiceUpdated(serviceInfo.name, serviceInfo.price, _status);
    }

    /**
     * @notice Update pricing model
     * @param _pricingModel New pricing model
     */
    function updatePricingModel(PricingModel _pricingModel) external onlyProvider {
        pricingModel = _pricingModel;
        emit PricingModelUpdated(_pricingModel);
    }

    /**
     * @notice Withdraw accumulated revenue
     * @param amount Amount to withdraw
     * @param recipient Recipient address
     */
    function withdrawRevenue(
        uint256 amount,
        address recipient
    ) external onlyProvider nonReentrant {
        require(recipient != address(0), "Service: Invalid recipient");
        require(amount > 0, "Service: Invalid amount");
        require(
            accumulatedRevenue >= amount,
            "Service: Insufficient revenue"
        );

        accumulatedRevenue -= amount;

        address token = serviceInfo.paymentToken;
        if (token == address(0)) {
            // Native token
            (bool success,) = payable(recipient).call{value: amount}("");
            require(success, "Service: Transfer failed");
        } else {
            // ERC20 token
            IERC20(token).safeTransfer(recipient, amount);
        }

        emit RevenueWithdrawn(recipient, amount, token);
    }

    // ============ Service Execution ============

    /**
     * @notice Get payment request for service call
     * @param caller Caller address (Agent contract)
     * @return paymentRequest Payment request structure
     */
    function getPaymentRequest(
        address caller
    ) external view returns (IX402Payment.PaymentRequest memory paymentRequest) {
        require(caller != address(0), "Service: Invalid caller");

        bytes32 paymentId = keccak256(
            abi.encodePacked(
                caller,
                address(this),
                block.timestamp,
                serviceInfo.callCount
            )
        );

        paymentRequest = IX402Payment.PaymentRequest({
            amount: serviceInfo.price,
            recipient: address(this),
            token: serviceInfo.paymentToken,
            paymentId: paymentId,
            expiresAt: block.timestamp + 1 hours
        });
    }

    /**
     * @notice Execute service with x402 payment verification
     * @param paymentId Payment ID from x402 payment
     * @param input Service input data
     * @return output Service output data
     */
    function executeService(
        bytes32 paymentId,
        bytes calldata input
    ) external onlyActive nonReentrant returns (bytes memory output) {
        // Verify payment
        require(
            x402Payment.isPaymentProcessed(paymentId),
            "Service: Payment not processed"
        );

        // Get payment details
        (IX402Payment.PaymentRequest memory request, bool processed) = 
            x402Payment.getPayment(paymentId);
        
        require(processed, "Service: Payment not found");
        require(
            request.recipient == address(this),
            "Service: Invalid payment recipient"
        );
        require(
            request.amount == serviceInfo.price,
            "Service: Payment amount mismatch"
        );
        require(
            request.token == serviceInfo.paymentToken,
            "Service: Payment token mismatch"
        );

        // Check if already called with this payment
        require(
            callHistory[msg.sender][paymentId] == 0,
            "Service: Already called with this payment"
        );

        // Record call
        callHistory[msg.sender][paymentId] = block.timestamp;
        serviceInfo.callCount += 1;
        serviceInfo.totalRevenue += request.amount;
        accumulatedRevenue += request.amount;

        // Update token balance
        if (request.token == address(0)) {
            // Native token - should be received by contract
            tokenBalances[address(0)] += request.amount;
        } else {
            // ERC20 token - should be transferred to contract
            // Note: x402 handler transfers to recipient, so balance should be updated
            tokenBalances[request.token] += request.amount;
        }

        emit PaymentVerified(paymentId, msg.sender, request.amount);

        // Execute service logic based on service type
        output = _executeServiceLogic(serviceInfo.serviceType, input);

        emit ServiceExecuted(msg.sender, paymentId, input, output);
    }

    /**
     * @notice Internal function to execute service logic
     * @param serviceType Service type
     * @param input Service input data
     * @return output Service output data
     */
    function _executeServiceLogic(
        ServiceType serviceType,
        bytes calldata input
    ) internal virtual view returns (bytes memory output) {
        // This is a placeholder - actual service logic would be implemented here
        // For different service types:
        // - STRATEGY: Analyze market data and return trading signals
        // - RISK_CONTROL: Evaluate risk and return risk assessment
        // - DATA_SOURCE: Fetch and return market data
        // - OTHER: Custom service logic

        // For now, return a simple response
        // In production, this would call external contracts or perform calculations
        output = abi.encode(
            serviceType,
            block.timestamp,
            "Service executed successfully"
        );
    }

    // ============ View Functions ============

    /**
     * @notice Get service information
     * @return info Service information
     */
    function getServiceInfo() external view returns (ServiceInfo memory info) {
        return serviceInfo;
    }

    /**
     * @notice Get service price
     * @return price Service price
     */
    function getPrice() external view returns (uint256 price) {
        return serviceInfo.price;
    }

    /**
     * @notice Check if payment was used for service call
     * @param caller Caller address
     * @param paymentId Payment ID
     * @return used True if payment was used
     */
    function isPaymentUsed(
        address caller,
        bytes32 paymentId
    ) external view returns (bool used) {
        return callHistory[caller][paymentId] > 0;
    }

    /**
     * @notice Get accumulated revenue
     * @return revenue Accumulated revenue
     */
    function getAccumulatedRevenue() external view returns (uint256 revenue) {
        return accumulatedRevenue;
    }

    /**
     * @notice Get token balance
     * @param token Token address
     * @return balance Token balance
     */
    function getTokenBalance(address token) external view returns (uint256 balance) {
        return tokenBalances[token];
    }
}

