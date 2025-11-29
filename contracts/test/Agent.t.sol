// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Agent} from "../src/Agent.sol";
import {IX402Payment} from "../src/x402/IX402Payment.sol";
import {X402PaymentHandler} from "../src/x402/X402PaymentHandler.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Mock ERC20 token for testing
contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint8 public decimals = 6;
    string public name = "Mock USDC";
    string public symbol = "USDC";

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }
}

contract AgentTest is Test {
    Agent public agent;
    X402PaymentHandler public x402Handler;
    MockERC20 public usdc;
    address public owner;
    address public user;

    event Deposited(address indexed token, uint256 amount, address indexed depositor);
    event Withdrawn(address indexed token, uint256 amount, address indexed recipient);
    event X402PaymentProcessed(
        bytes32 indexed paymentId,
        address indexed recipient,
        uint256 amount
    );

    function setUp() public {
        owner = address(this);
        user = address(0x1);

        // Deploy mock USDC
        usdc = new MockERC20();
        usdc.mint(owner, 1000000 * 10**6); // 1M USDC

        // Deploy x402 payment handler
        x402Handler = new X402PaymentHandler();

        // Deploy agent
        agent = new Agent(
            address(x402Handler),
            address(usdc),
            owner
        );
    }

    function testDeposit() public {
        uint256 amount = 1000 * 10**6; // 1000 USDC
        
        usdc.approve(address(agent), amount);
        agent.deposit(address(usdc), amount);

        assertEq(agent.getBalance(address(usdc)), amount);
    }

    function testDepositNative() public {
        uint256 amount = 1 ether;
        
        agent.deposit{value: amount}(address(0), amount);

        assertEq(agent.getBalance(address(0)), amount);
    }

    function testWithdraw() public {
        uint256 depositAmount = 1000 * 10**6;
        uint256 withdrawAmount = 500 * 10**6;

        // Deposit first
        usdc.approve(address(agent), depositAmount);
        agent.deposit(address(usdc), depositAmount);

        // Withdraw
        agent.withdraw(address(usdc), withdrawAmount, user);

        assertEq(agent.getBalance(address(usdc)), depositAmount - withdrawAmount);
        assertEq(usdc.balanceOf(user), withdrawAmount);
    }

    function testCallService() public {
        // Setup: deposit funds
        uint256 depositAmount = 10000 * 10**6;
        usdc.approve(address(agent), depositAmount);
        agent.deposit(address(usdc), depositAmount);

        // Create payment request
        bytes32 paymentId = keccak256("test-payment");
        IX402Payment.PaymentRequest memory paymentRequest = IX402Payment.PaymentRequest({
            amount: 100 * 10**6, // 100 USDC
            recipient: address(0x123), // Mock service address
            token: address(usdc),
            paymentId: paymentId,
            expiresAt: block.timestamp + 1 hours
        });

        // Approve x402 handler to spend USDC
        usdc.approve(address(x402Handler), paymentRequest.amount);

        // Mock service contract (just returns data)
        bytes memory serviceData = abi.encodeWithSignature("execute()");

        // Note: This test is simplified - actual service call would require a real service contract
        // For now, we'll test the payment part
        usdc.approve(address(agent), paymentRequest.amount);
        
        // The actual service call would fail without a real service, but payment should work
        // This is a placeholder test structure
    }

    function testDailyLimit() public {
        uint256 depositAmount = 10000 * 10**6;
        usdc.approve(address(agent), depositAmount);
        agent.deposit(address(usdc), depositAmount);

        // Try to trade more than daily limit
        (uint256 maxTradeAmount, uint256 dailyTradeLimit, uint256 maxPositionRatio, bool isActive) = agent.config();
        uint256 excessAmount = dailyTradeLimit + 1;

        // This should fail
        vm.expectRevert("Agent: Daily limit exceeded");
        // Note: buyToken would need proper DEX integration for full test
    }

    function testMaxTradeAmount() public {
        uint256 depositAmount = 10000 * 10**6;
        usdc.approve(address(agent), depositAmount);
        agent.deposit(address(usdc), depositAmount);

        (uint256 maxAmount, , , ) = agent.config();
        uint256 excessAmount = maxAmount + 1;

        // This should fail
        vm.expectRevert("Agent: Exceeds max trade amount");
        // Note: buyToken would need proper DEX integration for full test
    }

    function testUpdateConfig() public {
        uint256 newMaxTrade = 2000 * 10**6;
        uint256 newDailyLimit = 20000 * 10**6;
        uint256 newPositionRatio = 6000;

        agent.updateConfig(newMaxTrade, newDailyLimit, newPositionRatio);

        (uint256 maxTradeAmount, uint256 dailyTradeLimit, uint256 maxPositionRatio, ) = agent.config();
        assertEq(maxTradeAmount, newMaxTrade);
        assertEq(dailyTradeLimit, newDailyLimit);
        assertEq(maxPositionRatio, newPositionRatio);
    }

    function testSetActive() public {
        agent.setActive(false);
        (,,, bool isActive1) = agent.config();
        assertEq(isActive1, false);

        agent.setActive(true);
        (,,, bool isActive2) = agent.config();
        assertEq(isActive2, true);
    }

    function testSubscribeService() public {
        address serviceAddress = address(0x456);
        
        agent.subscribeService(serviceAddress, true);
        assertTrue(agent.subscribedServices(serviceAddress));

        agent.subscribeService(serviceAddress, false);
        assertFalse(agent.subscribedServices(serviceAddress));
    }
}

