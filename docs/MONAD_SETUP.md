# Monad Testnet 配置指南

本文档说明如何配置 Monad 测试网开发环境。

## 网络信息

- **网络名称**: Monad Testnet
- **RPC URL**: https://testnet-rpc.monad.xyz
- **Chain ID**: 10143
- **货币符号**: MON
- **区块浏览器**: https://testnet.monadexplorer.com

## 1. 钱包配置

### MetaMask 配置

1. 打开 MetaMask
2. 点击网络选择器，选择 "Add Network" 或 "添加网络"
3. 填写以下信息：
   - **网络名称**: Monad Testnet
   - **RPC URL**: https://testnet-rpc.monad.xyz
   - **Chain ID**: 10143
   - **货币符号**: MON
   - **区块浏览器 URL**: https://testnet.monadexplorer.com

### 其他钱包

Monad 测试网兼容所有 EVM 兼容钱包，包括：
- Phantom
- OKX Wallet
- Uniswap Wallet
- 其他支持自定义网络的 EVM 钱包

## 2. 获取测试代币

### 方法 1: Monad 官方水龙头

1. 访问 Monad 官方水龙头（如果可用）
2. 连接你的钱包
3. 按照提示领取测试代币

**注意**: 官方水龙头可能有以下要求：
- 钱包需要在以太坊主网持有一定数量的 ETH
- 需要完成一定数量的主网交易

### 方法 2: OKX 水龙头

如果官方水龙头不可用，可以尝试 OKX 的水龙头。

### 方法 3: Discord 社区

加入 Monad Discord 社区，在测试网频道申请测试代币。

## 3. 开发环境配置

### Foundry 配置

项目已配置好 Foundry，配置文件位于 `contracts/foundry.toml`。

主要配置：
- Solidity 版本: 0.8.20
- 优化器: 启用
- RPC 端点: 已配置 Monad 测试网

### 环境变量

1. 复制环境变量示例文件：
```bash
cd contracts
cp .env.example .env
```

2. 编辑 `.env` 文件，填入你的配置：
```bash
PRIVATE_KEY=your_private_key_here
MONAD_API_KEY=your_api_key_if_needed
```

**⚠️ 警告**: 永远不要提交包含真实私钥的 `.env` 文件！

### 后端配置

1. 复制环境变量示例文件：
```bash
cd backend
cp .env.example .env
```

2. 编辑 `.env` 文件，配置数据库和 Monad 连接：
```bash
DATABASE_URL=postgresql://user:password@localhost:5432/x402_db
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
```

### 前端配置

1. 复制环境变量示例文件：
```bash
cd frontend
cp .env.example .env
```

2. 编辑 `.env` 文件，配置 API 和合约地址：
```bash
VITE_API_BASE_URL=http://localhost:8000
VITE_MONAD_RPC_URL=https://testnet-rpc.monad.xyz
VITE_MONAD_CHAIN_ID=10143
```

## 4. 部署合约

### 使用 Foundry 部署

```bash
cd contracts
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url monad_testnet \
  --broadcast \
  --verify \
  -vvvv
```

### 使用 Makefile

```bash
cd contracts
make deploy
```

## 5. 验证合约

部署后，在 Monad Explorer 上验证合约：

```bash
forge verify-contract <CONTRACT_ADDRESS> <CONTRACT_NAME> \
  --chain monad_testnet \
  --etherscan-api-key $MONAD_API_KEY
```

## 6. 测试连接

### 测试 RPC 连接

```bash
curl -X POST https://testnet-rpc.monad.xyz \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

### 测试钱包连接

1. 在 MetaMask 中切换到 Monad Testnet
2. 确认能看到你的地址和余额
3. 尝试发送一笔测试交易

## 7. 常见问题

### 问题 1: RPC 连接失败

**解决方案**:
- 检查网络连接
- 确认 RPC URL 正确
- 尝试使用备用 RPC（如果有）

### 问题 2: 交易失败（Gas 不足）

**解决方案**:
- 确保钱包中有足够的 MON 测试代币
- 检查 Gas 价格设置

### 问题 3: 合约部署失败

**解决方案**:
- 检查私钥和地址配置
- 确认账户有足够的 MON 代币
- 检查合约代码是否有错误
- 查看 Foundry 输出的详细错误信息

## 8. 资源链接

- [Monad 官网](https://monad.xyz)
- [Monad 文档](https://docs.monad.xyz)
- [Monad Discord](https://discord.gg/monad)
- [Monad Twitter](https://twitter.com/monad_xyz)
- [区块浏览器](https://testnet.monadexplorer.com)

## 9. 下一步

配置完成后，你可以：
1. 开始开发智能合约
2. 集成 x402 协议
3. 开发后端 API
4. 开发前端界面

参考 [PRD 文档](../x402_prd.md) 了解完整的项目规划。

