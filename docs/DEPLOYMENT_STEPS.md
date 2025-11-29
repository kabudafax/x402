# 部署步骤指南

本文档提供在 Monad 测试网上部署 x402 AI Agent Trading Platform 的详细步骤。

## 前置要求

1. **安装 Foundry**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **获取测试代币**
   - 访问 Monad 测试网水龙头获取 MON 测试代币
   - 确保部署账户有足够的 MON 用于 gas 费用

3. **准备环境**
   - 确保已安装 Node.js 18+ 和 Python 3.10+
   - 确保已安装 PostgreSQL 和 Redis（用于后端）

## 步骤 1: 配置环境变量

### 1.1 合约部署配置

```bash
cd contracts
cp .env.example .env
```

编辑 `contracts/.env` 文件：
```bash
PRIVATE_KEY=0xyour_private_key_here  # 部署账户私钥（必须以 0x 开头！）
MOCK_USDC_ADDRESS=0x...             # 可选：Mock USDC 地址（如果部署示例服务）
MONAD_API_KEY=your_api_key          # 可选：用于合约验证（见下方说明）
```

**⚠️ 重要**: `PRIVATE_KEY` 必须以 `0x` 开头！例如：
```bash
PRIVATE_KEY=0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

**关于 MONAD_API_KEY**:
- **可选**: API Key 只用于自动验证合约源代码，不影响部署
- **获取方式**: 
  - 访问 https://testnet.monadexplorer.com 查找 API 选项
  - 或通过 Monad Discord/社区申请
  - 详见 `contracts/MONAD_API_KEY_GUIDE.md`
- **如果没有 API Key**: 可以跳过验证，稍后手动验证或直接部署使用

**⚠️ 警告**: 永远不要提交包含真实私钥的 `.env` 文件！

### 1.2 后端配置

```bash
cd backend
cp .env.example .env
```

编辑 `backend/.env` 文件，配置数据库和 Monad 连接。

### 1.3 前端配置

```bash
cd frontend
cp .env.example .env
```

编辑 `frontend/.env` 文件，配置 API 地址（部署后填入合约地址）。

## 步骤 2: 编译合约

```bash
cd contracts
forge build
```

确保编译成功，没有错误。

## 步骤 3: 部署合约到 Monad 测试网

```bash
cd contracts
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url monad_testnet \
  --broadcast \
  --verify \
  -vvvv
```

**如果遇到 RPC 连接错误**，可以直接指定 RPC URL：

```bash
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url https://testnet-rpc.monad.xyz \
  --broadcast \
  --verify \
  -vvvv
```

### 部署说明

部署脚本会按以下顺序部署：

1. **X402PaymentHandler** - x402 支付处理合约（必须先部署）
2. **Market** - 服务市场合约
3. **Service** - 示例服务合约（可选，如果提供了 MOCK_USDC_ADDRESS）

如果提供了 `MOCK_USDC_ADDRESS`，脚本会自动：
- 部署两个示例服务（Strategy Service 和 Risk Control Service）
- 自动将服务上架到市场

### 记录部署地址

部署完成后，记录以下合约地址：
- X402PaymentHandler 地址
- Market 地址
- Service 地址（如果有）

## 步骤 4: 更新配置文件

### 4.1 更新前端配置

编辑 `frontend/.env`：
```bash
VITE_X402_PAYMENT_CONTRACT=0x...  # X402PaymentHandler 地址
VITE_MARKET_CONTRACT_ADDRESS=0x...  # Market 地址
VITE_SERVICE_CONTRACT_ADDRESS=0x...  # Service 地址（如果有）
```

### 4.2 更新后端配置

编辑 `backend/.env`：
```bash
X402_PAYMENT_CONTRACT=0x...  # X402PaymentHandler 地址
MARKET_CONTRACT_ADDRESS=0x...  # Market 地址
SERVICE_CONTRACT_ADDRESS=0x...  # Service 地址（如果有）
```

## 步骤 5: 验证合约（可选）

在 Monad Explorer 上验证合约：

```bash
forge verify-contract <CONTRACT_ADDRESS> <CONTRACT_NAME> \
  --chain monad_testnet \
  --etherscan-api-key $MONAD_API_KEY
```

**注意**: 
- 如果没有 API Key，可以跳过此步骤
- 合约仍然可以正常使用，只是无法自动验证源代码
- 稍后可以在区块浏览器上手动验证
- 详见 `contracts/MONAD_API_KEY_GUIDE.md` 了解如何获取 API Key

## 步骤 6: 初始化后端数据库

```bash
cd backend
# 创建数据库迁移（如果还没有）
alembic revision --autogenerate -m "Initial migration"

# 运行迁移
alembic upgrade head
```

## 步骤 7: 启动服务

### 7.1 启动后端

```bash
cd backend
uvicorn src.main:app --reload
```

### 7.2 启动前端

```bash
cd frontend
pnpm install  # 或 npm install
pnpm dev      # 或 npm run dev
```

## 步骤 8: 测试部署

1. **连接钱包**
   - 在浏览器中打开前端应用
   - 连接 MetaMask 钱包
   - 切换到 Monad Testnet 网络

2. **创建 Agent**
   - 导航到 Agent 页面
   - 点击 "Create Agent"
   - 填写信息并输入 Payment Token 地址
   - 部署 Agent 合约

3. **验证功能**
   - 检查 Agent 是否成功创建
   - 验证合约地址是否正确
   - 测试其他功能

## 故障排查

### 部署失败 - 私钥格式错误

**错误信息**: `vm.envUint: failed parsing $PRIVATE_KEY as type uint256: missing hex prefix ("0x")`

**解决方案**:
- 确保 `PRIVATE_KEY` 在 `.env` 文件中以 `0x` 开头
- 格式：`PRIVATE_KEY=0x你的私钥`（64个十六进制字符，总共66个字符包括0x）

### 部署失败 - Gas 不足

**解决方案**:
- 确保钱包有足够的 MON 测试代币
- 检查 gas price 设置

### 合约验证失败

**解决方案**:
- 检查 MONAD_API_KEY 是否正确
- 确认合约已成功部署
- 等待几个区块确认后再验证

### 前端连接失败

**解决方案**:
- 检查 RPC URL 配置
- 确认 Chain ID 正确（10143）
- 验证钱包网络设置

### 服务调用失败

**解决方案**:
- 检查 Agent 余额
- 验证 x402 支付是否成功
- 确认服务状态为 ACTIVE

### RPC 连接失败

**错误信息**: `error sending request for url (https://testnet-rpc.monad.xyz/)` 或 `tls handshake eof`

**解决方案**:
- 直接使用 RPC URL 而不是别名：
  ```bash
  --rpc-url https://testnet-rpc.monad.xyz
  ```
- 测试 RPC 连接：
  ```bash
  curl -X POST https://testnet-rpc.monad.xyz \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
  ```
- 检查网络连接和防火墙设置
- 查看 `contracts/RPC_TROUBLESHOOTING.md` 获取详细故障排查指南

### HTTP 429 - 速率限制错误

**错误信息**: `HTTP error 429` 或 `Too Many Requests, Please apply an OnFinality API key`

**原因**: 使用了 OnFinality 等公共 RPC 服务，超过了免费层的请求速率限制

**解决方案**:
1. **切换到官方 RPC**（推荐）：
   ```toml
   # 在 foundry.toml 中
   monad_testnet = "https://testnet-rpc.monad.xyz"
   ```

2. **申请 OnFinality API Key**：
   - 访问 https://onfinality.io 注册并申请 API key
   - 在 RPC URL 中添加 API key：
     ```toml
     monad_testnet = "https://monad-testnet.api.onfinality.io/public?apikey=YOUR_API_KEY"
     ```

3. **等待后重试**：速率限制通常是按时间窗口计算的，等待几分钟后重试

4. **查看详细指南**：`contracts/RATE_LIMIT_SOLUTION.md`

## 网络信息

- **网络名称**: Monad Testnet
- **RPC URL**: https://testnet-rpc.monad.xyz
- **Chain ID**: 10143
- **货币符号**: MON
- **区块浏览器**: https://testnet.monadexplorer.com

## 下一步

部署完成后，你可以：
1. 创建更多的 Agent 合约
2. 部署更多的服务到市场
3. 测试完整的交易流程
4. 集成实际的 DEX（如果需要）

---

**最后更新**: 2025年

