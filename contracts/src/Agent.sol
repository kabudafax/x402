// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IX402Payment} from "./x402/IX402Payment.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Agent
 * @notice AI Agent contract for autonomous trading and service purchasing
 * @dev Manages agent funds, executes trades, and calls services via x402 payments
 */
contract Agent is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    // ============ Constants ============

    /// @notice Minimum reserve balance to keep in contract
    uint256 public constant MIN_RESERVE_BALANCE = 0.01 ether;

    // ============ State Variables ============

    /// @notice x402 payment handler address
    IX402Payment public x402Payment;

    /// @notice Default payment token (USDC)
    address public paymentToken;

    /// @notice Agent configuration
    struct AgentConfig {
        uint256 maxTradeAmount;      // Maximum amount per trade
        uint256 dailyTradeLimit;     // Daily trading limit
        uint256 maxPositionRatio;    // Maximum position ratio (basis points, 10000 = 100%)
        bool isActive;               // Agent active status
    }

    AgentConfig public config;

    /// @notice Daily trading statistics
    struct DailyStats {
        uint256 date;                // Date (YYYYMMDD format)
        uint256 totalTraded;        // Total traded amount today
        uint256 tradeCount;          // Number of trades today
    }

    mapping(uint256 => DailyStats) public dailyStats;

    /// @notice Token balances (token address => balance)
    mapping(address => uint256) public tokenBalances;

    /// @notice Service subscriptions (service address => subscribed)
    mapping(address => bool) public subscribedServices;

    /// @notice Payment history (paymentId => timestamp)
    mapping(bytes32 => uint256) public paymentHistory;

    // ============ Events ============

    event Deposited(address indexed token, uint256 amount, address indexed depositor);
    event Withdrawn(address indexed token, uint256 amount, address indexed recipient);
    event TradeExecuted(
        address indexed token,
        uint256 amount,
        bool isBuy,
        uint256 price,
        bytes32 indexed txHash
    );
    event ServiceCalled(
        address indexed serviceAddress,
        bytes32 indexed paymentId,
        bytes result
    );
    event ServiceSubscribed(address indexed serviceAddress, bool subscribed);
    event ConfigUpdated(
        uint256 maxTradeAmount,
        uint256 dailyTradeLimit,
        uint256 maxPositionRatio
    );
    event X402PaymentProcessed(
        bytes32 indexed paymentId,
        address indexed recipient,
        uint256 amount
    );

    // ============ Modifiers ============

    modifier onlyActive() {
        require(config.isActive, "Agent: Not active");
        _;
    }

    modifier checkDailyLimit(uint256 amount) {
        uint256 today = getToday();
        DailyStats storage stats = dailyStats[today];
        require(
            stats.totalTraded + amount <= config.dailyTradeLimit,
            "Agent: Daily limit exceeded"
        );
        _;
    }

    // ============ Constructor ============

    /**
     * @notice Initialize Agent contract
     * @param _x402Payment x402 payment handler address
     * @param _paymentToken Default payment token address
     * @param _owner Owner address (can withdraw funds)
     */
    constructor(
        address _x402Payment,
        address _paymentToken,
        address _owner
    ) Ownable(_owner) {
        require(_x402Payment != address(0), "Agent: Invalid x402 payment address");
        require(_paymentToken != address(0), "Agent: Invalid payment token");

        x402Payment = IX402Payment(_x402Payment);
        paymentToken = _paymentToken;

        // Default configuration
        config = AgentConfig({
            maxTradeAmount: 1000 * 10**6,      // 1000 USDC (6 decimals)
            dailyTradeLimit: 10000 * 10**6,    // 10000 USDC
            maxPositionRatio: 5000,            // 50% of balance
            isActive: true
        });
    }

    // ============ Receive ============

    receive() external payable {
        // Allow receiving native tokens
    }

    // ============ Owner Functions ============

    /**
     * @notice Update agent configuration
     * @param _maxTradeAmount Maximum amount per trade
     * @param _dailyTradeLimit Daily trading limit
     * @param _maxPositionRatio Maximum position ratio (basis points)
     */
    function updateConfig(
        uint256 _maxTradeAmount,
        uint256 _dailyTradeLimit,
        uint256 _maxPositionRatio
    ) external onlyOwner {
        require(_maxPositionRatio <= 10000, "Agent: Invalid position ratio");
        
        config.maxTradeAmount = _maxTradeAmount;
        config.dailyTradeLimit = _dailyTradeLimit;
        config.maxPositionRatio = _maxPositionRatio;

        emit ConfigUpdated(_maxTradeAmount, _dailyTradeLimit, _maxPositionRatio);
    }

    /**
     * @notice Set agent active status
     * @param _isActive Active status
     */
    function setActive(bool _isActive) external onlyOwner {
        config.isActive = _isActive;
    }

    // ============ Deposit/Withdraw ============

    /**
     * @notice Deposit tokens to agent
     * @param token Token address (address(0) for native token)
     * @param amount Amount to deposit
     */
    function deposit(address token, uint256 amount) external payable {
        if (token == address(0)) {
            // Native token deposit
            require(msg.value == amount, "Agent: Amount mismatch");
            tokenBalances[address(0)] += amount;
            emit Deposited(address(0), amount, msg.sender);
        } else {
            // ERC20 token deposit
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
            tokenBalances[token] += amount;
            emit Deposited(token, amount, msg.sender);
        }
    }

    /**
     * @notice Withdraw tokens from agent
     * @param token Token address (address(0) for native token)
     * @param amount Amount to withdraw
     * @param recipient Recipient address
     */
    function withdraw(
        address token,
        uint256 amount,
        address recipient
    ) external onlyOwner nonReentrant {
        require(recipient != address(0), "Agent: Invalid recipient");
        
        uint256 balance = tokenBalances[token];
        require(balance >= amount, "Agent: Insufficient balance");

        // Check minimum reserve (for native token only)
        if (token == address(0)) {
            require(
                balance - amount >= MIN_RESERVE_BALANCE,
                "Agent: Below minimum reserve"
            );
        }

        tokenBalances[token] -= amount;

        if (token == address(0)) {
            (bool success,) = payable(recipient).call{value: amount}("");
            require(success, "Agent: Transfer failed");
        } else {
            IERC20(token).safeTransfer(recipient, amount);
        }

        emit Withdrawn(token, amount, recipient);
    }

    // ============ Trading Functions ============

    /**
     * @notice Execute a buy trade (simplified - assumes DEX integration)
     * @param token Token to buy
     * @param amountIn Input amount (in payment token)
     * @param minAmountOut Minimum output amount (slippage protection)
     * @param dexRouter DEX router address (e.g., Uniswap router)
     * @param path Swap path
     */
    function buyToken(
        address token,
        uint256 amountIn,
        uint256 minAmountOut,
        address dexRouter,
        address[] calldata path
    ) external onlyOwner onlyActive checkDailyLimit(amountIn) nonReentrant {
        require(token != address(0), "Agent: Invalid token");
        require(amountIn > 0, "Agent: Invalid amount");
        require(amountIn <= config.maxTradeAmount, "Agent: Exceeds max trade amount");
        require(
            tokenBalances[paymentToken] >= amountIn,
            "Agent: Insufficient balance"
        );

        // Check position ratio
        uint256 totalBalance = getTotalBalance();
        require(
            (amountIn * 10000) / totalBalance <= config.maxPositionRatio,
            "Agent: Exceeds max position ratio"
        );

        // Update balance
        tokenBalances[paymentToken] -= amountIn;

        // Approve DEX router
        IERC20(paymentToken).approve(dexRouter, amountIn);

        // Execute swap (simplified - actual implementation depends on DEX)
        // This is a placeholder - actual DEX integration would be more complex
        // For now, we'll just update the balance to simulate the trade
        uint256 amountOut = minAmountOut; // Simplified
        tokenBalances[token] += amountOut;

        // Update daily stats
        uint256 today = getToday();
        dailyStats[today].totalTraded += amountIn;
        dailyStats[today].tradeCount += 1;

        uint256 price = amountIn / amountOut;
        emit TradeExecuted(token, amountOut, true, price, bytes32(0));
    }

    /**
     * @notice Execute a sell trade
     * @param token Token to sell
     * @param amountIn Input amount (in token)
     * @param minAmountOut Minimum output amount (in payment token)
     * @param dexRouter DEX router address
     * @param path Swap path
     */
    function sellToken(
        address token,
        uint256 amountIn,
        uint256 minAmountOut,
        address dexRouter,
        address[] calldata path
    ) external onlyOwner onlyActive nonReentrant {
        require(token != address(0), "Agent: Invalid token");
        require(amountIn > 0, "Agent: Invalid amount");
        require(
            tokenBalances[token] >= amountIn,
            "Agent: Insufficient token balance"
        );

        // Update balance
        tokenBalances[token] -= amountIn;

        // Approve DEX router
        IERC20(token).approve(dexRouter, amountIn);

        // Execute swap (simplified)
        uint256 amountOut = minAmountOut; // Simplified
        tokenBalances[paymentToken] += amountOut;

        // Update daily stats
        uint256 today = getToday();
        dailyStats[today].totalTraded += amountOut;
        dailyStats[today].tradeCount += 1;

        uint256 sellPrice = amountOut / amountIn;
        emit TradeExecuted(token, amountIn, false, sellPrice, bytes32(0));
    }

    // ============ Service Functions ============

    /**
     * @notice Call a service with x402 payment
     * @param serviceAddress Service contract address
     * @param paymentRequest x402 payment request
     * @param serviceData Service call data
     */
    function callService(
        address serviceAddress,
        IX402Payment.PaymentRequest calldata paymentRequest,
        bytes calldata serviceData
    ) external onlyOwner onlyActive nonReentrant returns (bytes memory) {
        require(serviceAddress != address(0), "Agent: Invalid service address");
        require(
            paymentRequest.recipient == serviceAddress,
            "Agent: Payment recipient mismatch"
        );

        // Check balance
        if (paymentRequest.token == address(0)) {
            require(
                address(this).balance >= paymentRequest.amount,
                "Agent: Insufficient native balance"
            );
        } else {
            require(
                tokenBalances[paymentRequest.token] >= paymentRequest.amount,
                "Agent: Insufficient token balance"
            );
        }

        // Process x402 payment
        // x402 handler will transfer from this contract (msg.sender) to recipient
        if (paymentRequest.token == address(0)) {
            // For native token, x402 handler needs balance
            // Send native token to x402 handler first
            (bool sent,) = payable(address(x402Payment)).call{value: paymentRequest.amount}("");
            require(sent, "Agent: Failed to send native token");
            require(
                x402Payment.processPayment(paymentRequest),
                "Agent: Payment failed"
            );
        } else {
            // For ERC20, approve x402 handler first
            IERC20 token = IERC20(paymentRequest.token);
            // Check actual balance (not just internal tracking)
            require(
                token.balanceOf(address(this)) >= paymentRequest.amount,
                "Agent: Insufficient actual balance"
            );
            // OpenZeppelin v5: use forceApprove or approve
            // First reset allowance if needed, then approve
            uint256 currentAllowance = token.allowance(address(this), address(x402Payment));
            if (currentAllowance > 0) {
                token.approve(address(x402Payment), 0);
            }
            token.approve(address(x402Payment), paymentRequest.amount);
            require(
                x402Payment.processPayment(paymentRequest),
                "Agent: Payment failed"
            );
            tokenBalances[paymentRequest.token] -= paymentRequest.amount;
        }

        // Record payment
        paymentHistory[paymentRequest.paymentId] = block.timestamp;

        emit X402PaymentProcessed(
            paymentRequest.paymentId,
            paymentRequest.recipient,
            paymentRequest.amount
        );

        // Call service
        (bool success, bytes memory result) = serviceAddress.call(serviceData);
        require(success, "Agent: Service call failed");

        emit ServiceCalled(serviceAddress, paymentRequest.paymentId, result);

        return result;
    }

    /**
     * @notice Subscribe to a service
     * @param serviceAddress Service contract address
     * @param subscribed Subscription status
     */
    function subscribeService(address serviceAddress, bool subscribed) external onlyOwner {
        require(serviceAddress != address(0), "Agent: Invalid service address");
        subscribedServices[serviceAddress] = subscribed;
        emit ServiceSubscribed(serviceAddress, subscribed);
    }

    // ============ View Functions ============

    /**
     * @notice Get agent balance for a token
     * @param token Token address
     * @return balance Token balance
     */
    function getBalance(address token) external view returns (uint256 balance) {
        return tokenBalances[token];
    }

    /**
     * @notice Get total balance (native + all tokens)
     * @return total Total balance in payment token equivalent
     */
    function getTotalBalance() public view returns (uint256 total) {
        // Simplified - just return payment token balance
        // In production, would convert all tokens to payment token equivalent
        return tokenBalances[paymentToken];
    }

    /**
     * @notice Get today's date in YYYYMMDD format
     * @return date Today's date
     */
    function getToday() public view returns (uint256 date) {
        // Simplified date calculation
        // In production, use proper date library
        return block.timestamp / 86400; // Days since epoch
    }

    /**
     * @notice Get daily statistics
     * @param date Date in YYYYMMDD format
     * @return stats Daily statistics
     */
    function getDailyStats(uint256 date) external view returns (DailyStats memory stats) {
        return dailyStats[date];
    }

    /**
     * @notice Check if payment was made
     * @param paymentId Payment ID
     * @return paid True if payment was made
     */
    function isPaymentMade(bytes32 paymentId) external view returns (bool paid) {
        return paymentHistory[paymentId] > 0;
    }
}
