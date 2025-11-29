# 部署指南

## 部署到 Monad 测试网

### 前置要求

1. **安装 Foundry**
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. **配置环境变量**
```bash
cd contracts
cp .env.example .env
# 编辑 .env 文件
```

`.env` 文件内容：
```bash
PRIVATE_KEY=your_private_key_here
MOCK_USDC_ADDRESS=0x... # Mock USDC 地址（如果使用）
MONAD_API_KEY=your_api_key # 用于合约验证（可选）
```

3. **获取测试代币**
- 访问 Monad 测试网水龙头
- 确保钱包有足够的 MON 代币用于 gas 费用

### 部署步骤

#### 1. 编译合约

```bash
cd contracts
forge build
```

#### 2. 部署合约

```bash
# 部署所有合约
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url monad_testnet \
  --broadcast \
  --verify \
  -vvvv
```

#### 3. 验证部署

部署完成后，记录合约地址：
- X402PaymentHandler 地址
- Market 地址
- Service 地址（如果有）

#### 4. 初始化市场

```bash
# 使用 cast 或前端调用
# 将服务上架到市场
cast send $MARKET_ADDRESS "listService(address)" $SERVICE_ADDRESS \
  --rpc-url monad_testnet \
  --private-key $PRIVATE_KEY
```

### 部署顺序

1. **X402PaymentHandler** - 必须先部署
2. **Market** - 服务市场
3. **Service** - 服务合约（可选，用于测试）
4. **Agent** - 由用户部署（每个用户一个）

### 合约地址配置

部署后，更新配置文件：

**后端** (`backend/.env`):
```bash
X402_PAYMENT_HANDLER_ADDRESS=0x...
MARKET_CONTRACT_ADDRESS=0x...
```

**前端** (`frontend/.env`):
```bash
VITE_X402_PAYMENT_CONTRACT=0x...
VITE_MARKET_CONTRACT_ADDRESS=0x...
```

## 端到端测试

### 1. 测试流程

1. **创建用户和代理**
   - 前端连接钱包
   - 创建 Agent 合约
   - 向 Agent 充值

2. **浏览服务市场**
   - 查看可用服务
   - 选择服务

3. **购买服务**
   - Agent 调用服务
   - x402 支付处理
   - 服务执行

4. **执行交易**
   - Agent 根据服务信号执行交易
   - 查看交易历史

### 2. 测试检查清单

- [ ] 钱包连接正常
- [ ] Agent 创建成功
- [ ] 充值功能正常
- [ ] 服务市场显示正常
- [ ] 服务购买流程正常
- [ ] x402 支付成功
- [ ] 服务执行返回结果
- [ ] 交易执行成功
- [ ] 交易历史显示正常

## 故障排查

### 常见问题

1. **部署失败 - Gas 不足**
   - 确保钱包有足够的 MON 代币
   - 检查 gas price 设置

2. **合约验证失败**
   - 检查 MONAD_API_KEY 是否正确
   - 确认合约已成功部署

3. **服务调用失败**
   - 检查 Agent 余额
   - 验证 x402 支付是否成功
   - 确认服务状态为 ACTIVE

4. **前端连接失败**
   - 检查 RPC URL 配置
   - 确认 Chain ID 正确
   - 验证钱包网络设置

## 监控

部署后，建议监控：
- 合约调用次数
- Gas 消耗
- 错误率
- 服务使用情况
- 支付成功率

---

**部署完成后，项目即可在 Monad 测试网上运行！**

