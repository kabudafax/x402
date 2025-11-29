# x402 协议研究文档

## 1. 协议概述

### 1.1 基本信息

- **协议名称**: x402 Protocol
- **发布方**: Coinbase 开发者平台
- **发布时间**: 2025年5月
- **协议类型**: 开源支付协议
- **核心标准**: 基于 HTTP 402 状态码（"Payment Required"）

### 1.2 设计目标

x402 协议旨在为互联网构建原生支付层，实现：
- **无摩擦支付**: 无需注册账户、登录或使用信用卡
- **AI 原生设计**: 支持 AI 代理自主发起支付
- **机器对机器（M2M）支付**: 适用于自动化微支付场景
- **即时结算**: 基于区块链的快速支付

### 1.3 核心特点

1. **无账户支付**
   - 无需用户注册
   - 无需 API 密钥
   - 仅需一行代码即可集成

2. **即时结算**
   - 基于区块链网络（Base、Solana、Polygon 等）
   - 结算时间约 200 毫秒
   - 燃料成本低于 0.0001 美元

3. **跨链兼容**
   - 支持多条区块链网络
   - 可适配不同链的特性

4. **微支付支持**
   - 支持小额、高频支付
   - 适合按次付费场景

## 2. 协议工作原理

### 2.1 工作流程

```
┌─────────────┐                    ┌─────────────┐
│  AI Agent   │                    │   Service   │
│  (Client)   │                    │  Provider  │
└──────┬──────┘                    └──────┬──────┘
       │                                  │
       │  1. Request Resource/Service   │
       │─────────────────────────────────>│
       │                                  │
       │  2. HTTP 402 Payment Required    │
       │<─────────────────────────────────│
       │  (Amount, Asset, Address, Expiry)│
       │                                  │
       │  3. Execute Payment              │
       │  (Blockchain Transaction)        │
       │─────────────────────────────────>│
       │                                  │
       │  4. Verify Payment               │
       │                                  │
       │  5. Provide Resource/Service     │
       │<─────────────────────────────────│
       │                                  │
```

### 2.2 详细步骤

#### 步骤 1: 请求资源
AI 代理向服务提供方发起请求，请求特定的资源或服务。

**请求示例**:
```http
GET /api/strategy-signal?symbol=ETH/USDC HTTP/1.1
Host: service.example.com
```

#### 步骤 2: 返回 HTTP 402
服务提供方检测到需要支付，返回 HTTP 402 状态码，包含支付信息。

**响应示例**:
```http
HTTP/1.1 402 Payment Required
Content-Type: application/json

{
  "payment": {
    "amount": "1.0",
    "currency": "USDC",
    "recipient": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    "chainId": 10143,
    "expiresAt": "2025-01-15T10:30:00Z",
    "paymentId": "payment_123456"
  },
  "x402": {
    "version": "1.0",
    "network": "monad"
  }
}
```

#### 步骤 3: 执行支付
AI 代理根据支付信息，在区块链上执行支付交易。

**支付交易**:
- 从 Agent 合约地址转账到 Service Provider 地址
- 金额：1.0 USDC
- 链：Monad Testnet (Chain ID: 10143)

#### 步骤 4: 验证支付
服务提供方验证链上支付是否成功。

**验证方式**:
- 监听链上交易事件
- 检查交易状态
- 验证支付金额和接收地址

#### 步骤 5: 提供服务
支付验证成功后，服务提供方返回请求的资源或服务。

**响应示例**:
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "signal": "BUY",
  "confidence": 0.85,
  "targetPrice": 2500.0,
  "stopLoss": 2400.0
}
```

## 3. 技术规范

### 3.1 HTTP 402 响应格式

x402 协议使用标准的 HTTP 402 状态码，响应体包含支付信息：

```json
{
  "payment": {
    "amount": "string",        // 支付金额（字符串格式，支持小数）
    "currency": "string",       // 货币类型（如 "USDC"）
    "recipient": "string",      // 收款地址（区块链地址）
    "chainId": "number",        // 链 ID
    "expiresAt": "string",      // 支付过期时间（ISO 8601）
    "paymentId": "string"      // 支付 ID（唯一标识）
  },
  "x402": {
    "version": "string",       // x402 协议版本
    "network": "string"        // 网络名称（如 "monad", "base"）
  }
}
```

### 3.2 支付交易格式

支付交易需要在区块链上执行，包含以下信息：

- **from**: Agent 合约地址
- **to**: Service Provider 地址
- **value**: 支付金额（Wei 或最小单位）
- **data**: 可选的附加数据（如 paymentId）

### 3.3 支付验证

服务提供方需要验证支付：

1. **监听链上事件**: 监听支付相关的链上事件
2. **检查交易状态**: 确认交易已成功确认
3. **验证支付信息**: 
   - 验证支付金额
   - 验证收款地址
   - 验证支付时间（未过期）
   - 验证 paymentId（防止重复支付）

## 4. 在 Monad 链上的集成

### 4.1 Monad 链特性

- **EVM 兼容**: Monad 完全兼容 EVM，可以使用标准的 Solidity 代码
- **高性能**: Monad 提供高吞吐量和低延迟
- **测试网**: 当前使用 Monad Testnet (Chain ID: 10143)

### 4.2 集成方案

#### 方案 A: 智能合约直接集成（推荐）

在智能合约中直接实现 x402 支付逻辑：

```solidity
// 伪代码示例
contract X402Payment {
    struct PaymentRequest {
        uint256 amount;
        address recipient;
        uint256 expiresAt;
        bytes32 paymentId;
    }
    
    function processPayment(PaymentRequest memory request) external {
        // 验证支付请求
        require(block.timestamp < request.expiresAt, "Payment expired");
        require(!isPaymentProcessed(request.paymentId), "Payment already processed");
        
        // 执行支付
        IERC20(usdc).transferFrom(msg.sender, request.recipient, request.amount);
        
        // 记录支付
        markPaymentProcessed(request.paymentId);
    }
}
```

#### 方案 B: 链下验证 + 链上支付

- 链下：服务提供方返回 HTTP 402 响应
- 链上：Agent 合约执行支付
- 链下：服务提供方验证支付后提供服务

### 4.3 实现要点

1. **支付接口标准化**
   - 定义统一的支付接口
   - 支持多种代币（USDC、USDT 等）

2. **支付验证机制**
   - 实现链上支付验证
   - 防止重复支付
   - 处理支付过期

3. **事件记录**
   - 记录所有支付事件
   - 便于查询和审计

## 5. 在项目中的应用场景

### 5.1 Agent 购买策略服务

**场景**: Agent 需要从策略服务 Agent 获取交易信号

**流程**:
1. Agent 合约调用策略服务
2. 策略服务返回 HTTP 402（链下）或支付请求（链上）
3. Agent 合约执行 x402 支付
4. 策略服务验证支付后返回交易信号

### 5.2 Agent 购买风控服务

**场景**: Agent 在执行交易前需要风控检查

**流程**:
1. Agent 合约准备执行交易
2. 调用风控服务进行风险评估
3. 风控服务返回支付请求
4. Agent 合约支付后获得风控建议

### 5.3 Agent 购买数据服务

**场景**: Agent 需要获取实时市场数据

**流程**:
1. Agent 合约需要市场数据
2. 调用数据服务
3. 数据服务返回支付请求
4. Agent 合约支付后获得数据

## 6. 实现建议

### 6.1 智能合约层面

1. **创建 X402Payment 接口**
   ```solidity
   interface IX402Payment {
       function pay(
           address recipient,
           uint256 amount,
           address token,
           bytes32 paymentId
       ) external returns (bool);
   }
   ```

2. **在 Agent 合约中集成**
   - Agent 合约实现支付功能
   - 支持自动支付服务费用

3. **在 Service 合约中集成**
   - Service 合约接收支付
   - 验证支付后执行服务

### 6.2 后端层面

1. **支付请求生成**
   - 服务提供方生成支付请求
   - 返回 HTTP 402 响应（如果使用链下方式）

2. **支付验证服务**
   - 监听链上支付事件
   - 验证支付状态
   - 更新服务状态

### 6.3 前端层面

1. **支付状态展示**
   - 显示支付请求
   - 显示支付状态
   - 显示支付历史

## 7. 安全考虑

### 7.1 支付安全

- **防止重复支付**: 使用 paymentId 防止重复支付
- **支付过期**: 设置合理的过期时间
- **金额验证**: 验证支付金额是否正确

### 7.2 签名安全

- **谨慎授权**: 用户需要谨慎授权签名
- **金额限制**: 设置单笔支付限额
- **频率限制**: 限制支付频率

### 7.3 合约安全

- **重入攻击防护**: 使用 ReentrancyGuard
- **溢出检查**: 使用 SafeMath 或 Solidity 0.8+
- **权限控制**: 实现适当的权限控制

## 8. 测试策略

### 8.1 单元测试

- 测试支付功能
- 测试支付验证
- 测试支付过期处理

### 8.2 集成测试

- 测试完整的支付流程
- 测试多 Agent 并发支付
- 测试支付失败场景

### 8.3 端到端测试

- 测试 Agent 购买服务的完整流程
- 测试支付验证和服务提供
- 测试异常情况处理

## 9. 参考资料

- [x402 Protocol Official Documentation](https://x402.io) (如果可用)
- [Coinbase Developer Platform](https://developers.coinbase.com)
- [HTTP 402 Status Code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/402)
- [Monad Documentation](https://docs.monad.xyz)

## 10. 下一步行动

1. **实现 X402Payment 接口**
   - 在 contracts/src/x402/ 目录下创建接口和实现

2. **集成到 Agent 合约**
   - 在 Agent 合约中添加支付功能

3. **集成到 Service 合约**
   - 在 Service 合约中添加支付接收和验证

4. **实现支付验证服务**
   - 在后端实现支付验证逻辑

5. **编写测试**
   - 编写完整的测试套件

---

**文档版本**: v1.0  
**最后更新**: 2025年  
**作者**: 开发团队

