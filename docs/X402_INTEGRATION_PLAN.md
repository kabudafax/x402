# x402 协议集成方案

## 1. 集成架构

### 1.1 整体架构

```
┌─────────────────┐
│   Agent Contract│
│                 │
│  ┌───────────┐  │
│  │ X402      │  │
│  │ Payment   │  │
│  └─────┬─────┘  │
└────────┼────────┘
         │
         │ processPayment()
         │
┌────────▼─────────────────┐
│  X402PaymentHandler      │
│  (Shared Payment Handler)│
└────────┬─────────────────┘
         │
         │ Transfer
         │
┌────────▼────────┐
│ Service Contract│
│                 │
│  ┌───────────┐  │
│  │ Verify    │  │
│  │ Payment   │  │
│  └───────────┘  │
└─────────────────┘
```

### 1.2 组件说明

1. **X402PaymentHandler**: 共享的支付处理合约
   - 处理所有 x402 支付
   - 防止重复支付
   - 记录支付历史

2. **Agent Contract**: 集成支付功能
   - 调用 X402PaymentHandler 处理支付
   - 在调用服务前执行支付

3. **Service Contract**: 验证支付
   - 检查支付状态
   - 验证支付后执行服务

## 2. 实现步骤

### 步骤 1: 部署 X402PaymentHandler

```solidity
// Deploy X402PaymentHandler first
X402PaymentHandler x402Handler = new X402PaymentHandler();
```

### 步骤 2: 在 Agent 合约中集成

```solidity
contract Agent {
    IX402Payment public x402Payment;
    
    constructor(address _x402Payment) {
        x402Payment = IX402Payment(_x402Payment);
    }
    
    function callService(
        address serviceAddress,
        PaymentRequest memory paymentRequest,
        bytes calldata serviceData
    ) external {
        // Process payment
        require(
            x402Payment.processPayment(paymentRequest),
            "Payment failed"
        );
        
        // Call service
        (bool success, bytes memory result) = serviceAddress.call(serviceData);
        require(success, "Service call failed");
    }
}
```

### 步骤 3: 在 Service 合约中集成

```solidity
contract Service {
    IX402Payment public x402Payment;
    
    constructor(address _x402Payment) {
        x402Payment = IX402Payment(_x402Payment);
    }
    
    function executeService(
        bytes32 paymentId,
        bytes calldata input
    ) external returns (bytes memory) {
        // Verify payment
        require(
            x402Payment.isPaymentProcessed(paymentId),
            "Payment not processed"
        );
        
        // Execute service logic
        return _executeServiceLogic(input);
    }
}
```

## 3. 支付流程详细设计

### 3.1 支付请求生成

**在 Service 合约中**:

```solidity
function getPaymentRequest(
    uint256 amount,
    address token
) external view returns (PaymentRequest memory) {
    return PaymentRequest({
        amount: amount,
        recipient: address(this),
        token: token,
        paymentId: keccak256(abi.encodePacked(msg.sender, block.timestamp, amount)),
        expiresAt: block.timestamp + 1 hours
    });
}
```

### 3.2 支付执行

**在 Agent 合约中**:

```solidity
function purchaseService(
    address serviceAddress,
    uint256 serviceId
) external {
    // Get payment request from service
    IService service = IService(serviceAddress);
    PaymentRequest memory paymentRequest = service.getPaymentRequest(serviceId);
    
    // Process payment
    require(
        x402Payment.processPayment(paymentRequest),
        "Payment failed"
    );
    
    // Call service
    service.executeService(paymentRequest.paymentId, "");
}
```

### 3.3 支付验证

**在 Service 合约中**:

```solidity
modifier requiresPayment(bytes32 paymentId) {
    require(
        x402Payment.isPaymentProcessed(paymentId),
        "Payment required"
    );
    _;
}

function executeService(
    bytes32 paymentId,
    bytes calldata input
) external requiresPayment(paymentId) returns (bytes memory) {
    // Service logic here
}
```

## 4. 后端集成

### 4.1 支付请求生成（链下）

如果使用链下方式生成支付请求：

```python
from datetime import datetime, timedelta
import hashlib

def generate_payment_request(amount: float, recipient: str, token: str):
    payment_id = hashlib.sha256(
        f"{recipient}{datetime.now()}{amount}".encode()
    ).hexdigest()
    
    expires_at = datetime.now() + timedelta(hours=1)
    
    return {
        "payment": {
            "amount": str(amount),
            "currency": token,
            "recipient": recipient,
            "chainId": 10143,
            "expiresAt": expires_at.isoformat(),
            "paymentId": payment_id
        },
        "x402": {
            "version": "1.0",
            "network": "monad"
        }
    }
```

### 4.2 支付验证服务

```python
from web3 import Web3

def verify_payment(payment_id: str, rpc_url: str):
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    
    # Get X402PaymentHandler contract
    contract = w3.eth.contract(
        address=X402_PAYMENT_HANDLER_ADDRESS,
        abi=X402_PAYMENT_HANDLER_ABI
    )
    
    # Check if payment is processed
    is_processed = contract.functions.isPaymentProcessed(
        Web3.to_bytes(hexstr=payment_id)
    ).call()
    
    return is_processed
```

## 5. 测试策略

### 5.1 单元测试

```solidity
function testProcessPayment() public {
    PaymentRequest memory request = PaymentRequest({
        amount: 1 ether,
        recipient: address(service),
        token: address(0),
        paymentId: keccak256("test"),
        expiresAt: block.timestamp + 1 hours
    });
    
    x402Payment.processPayment(request);
    
    assertTrue(x402Payment.isPaymentProcessed(request.paymentId));
}
```

### 5.2 集成测试

```solidity
function testAgentPurchasesService() public {
    // 1. Agent calls service
    // 2. Service returns payment request
    // 3. Agent processes payment
    // 4. Service verifies payment
    // 5. Service executes
}
```

## 6. 部署顺序

1. **部署 X402PaymentHandler**
   - 这是基础支付处理合约
   - 所有其他合约都依赖它

2. **部署 Service 合约**
   - 设置 X402PaymentHandler 地址
   - 注册服务到市场

3. **部署 Market 合约**
   - 设置 X402PaymentHandler 地址

4. **部署 Agent 合约**
   - 设置 X402PaymentHandler 地址
   - 用户可以创建 Agent

## 7. 配置

### 7.1 环境变量

```bash
# X402 Payment Handler Address (set after deployment)
X402_PAYMENT_HANDLER_ADDRESS=

# Supported tokens
USDC_ADDRESS=
USDT_ADDRESS=
```

### 7.2 合约配置

```solidity
// In Agent contract
address public constant X402_PAYMENT_HANDLER = 0x...;
address public constant USDC = 0x...;
```

## 8. 监控和日志

### 8.1 事件监听

```javascript
// Listen for payment events
x402Payment.on("PaymentProcessed", (paymentId, payer, recipient, amount, token) => {
    console.log("Payment processed:", {
        paymentId,
        payer,
        recipient,
        amount: amount.toString(),
        token
    });
});
```

### 8.2 支付统计

- 总支付次数
- 总支付金额
- 平均支付金额
- 支付成功率

## 9. 安全最佳实践

1. **支付过期检查**: 始终检查支付是否过期
2. **重复支付防护**: 使用 paymentId 防止重复支付
3. **金额验证**: 验证支付金额是否正确
4. **重入保护**: 使用 ReentrancyGuard
5. **权限控制**: 限制谁可以调用支付函数

## 10. 故障处理

### 10.1 支付失败

- 检查余额是否足够
- 检查支付是否过期
- 检查 paymentId 是否已使用

### 10.2 服务调用失败

- 验证支付状态
- 检查服务是否可用
- 处理异常情况

---

**文档版本**: v1.0  
**最后更新**: 2025年

