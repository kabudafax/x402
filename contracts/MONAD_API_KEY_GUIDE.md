# Monad Explorer API Key 获取指南

## 什么是 Monad Explorer API Key

Monad Explorer API Key 用于在部署合约后自动验证合约源代码。验证后的合约可以在区块浏览器上查看源代码，提高透明度和信任度。

**注意**: API Key 是**可选的**，如果没有 API Key，合约仍然可以正常部署和使用，只是无法自动验证源代码。

## 如何获取 API Key

### 方法 1: 访问 Monad Explorer 网站

1. **访问 Monad 测试网区块浏览器**:
   - 网址: https://testnet.monadexplorer.com

2. **查找 API 或开发者选项**:
   - 通常在网站底部或用户菜单中
   - 查找 "API"、"Developer"、"API Key" 等选项
   - 可能需要注册/登录账户

3. **申请 API Key**:
   - 填写申请表单
   - 等待审核（如果需要）

### 方法 2: 通过 Monad 社区

1. **加入 Monad Discord**:
   - Discord: https://discord.gg/monad
   - 在测试网或开发者频道询问

2. **联系 Monad 团队**:
   - 通过官方渠道申请 API Key
   - 说明你的使用目的

3. **查看官方文档**:
   - Monad 文档: https://docs.monad.xyz
   - 查找关于区块浏览器 API 的说明

### 方法 3: 检查是否需要 API Key

某些区块浏览器可能：
- **不需要 API Key** - 可以直接验证合约
- **使用不同的验证方式** - 如通过 GitHub 链接

可以先尝试不使用 API Key 进行验证：

```bash
forge verify-contract <CONTRACT_ADDRESS> <CONTRACT_NAME> \
  --chain monad_testnet
```

## 配置 API Key

### 1. 在环境变量中配置

编辑 `contracts/.env` 文件：

```bash
MONAD_API_KEY=your_api_key_here
```

### 2. 在 foundry.toml 中使用

`foundry.toml` 已经配置好了，会自动从环境变量读取：

```toml
[etherscan]
monad_testnet = { key = "${MONAD_API_KEY}", url = "https://testnet.monadexplorer.com/api" }
```

### 3. 验证合约

部署时使用 `--verify` 参数：

```bash
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url monad_testnet \
  --broadcast \
  --verify \
  -vvvv
```

或者手动验证：

```bash
forge verify-contract <CONTRACT_ADDRESS> <CONTRACT_NAME> \
  --chain monad_testnet \
  --etherscan-api-key $MONAD_API_KEY
```

## 如果没有 API Key

**不用担心！** 没有 API Key 也可以：

1. **正常部署合约** - API Key 只用于验证，不影响部署
2. **手动验证** - 稍后可以在区块浏览器上手动上传源代码验证
3. **跳过验证** - 部署时不使用 `--verify` 参数

### 部署时不验证

```bash
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url monad_testnet \
  --broadcast \
  -vvvv
```

### 稍后手动验证

1. 访问 https://testnet.monadexplorer.com
2. 找到你的合约地址
3. 点击 "Verify Contract" 或 "验证合约"
4. 按照提示上传源代码和编译设置

## 常见问题

### Q: API Key 是必需的吗？

**A**: 不是必需的。API Key 只用于自动验证合约源代码，不影响合约的部署和使用。

### Q: 如何知道是否需要 API Key？

**A**: 
- 尝试不使用 API Key 部署和验证
- 如果验证失败并提示需要 API Key，则说明需要
- 查看 Monad Explorer 的文档或联系社区

### Q: API Key 有使用限制吗？

**A**: 通常有速率限制，但对于个人开发使用通常足够。

### Q: 在哪里查看我的 API Key？

**A**: 
- 登录 Monad Explorer 账户
- 查看账户设置或开发者页面
- 如果忘记了，可以重新申请

## 相关资源

- **Monad Explorer**: https://testnet.monadexplorer.com
- **Monad 文档**: https://docs.monad.xyz
- **Monad Discord**: https://discord.gg/monad
- **Monad Twitter**: https://twitter.com/monad_xyz

## 快速检查清单

- [ ] 访问 Monad Explorer 网站
- [ ] 查找 API/开发者选项
- [ ] 注册/登录账户（如果需要）
- [ ] 申请 API Key
- [ ] 将 API Key 添加到 `contracts/.env`
- [ ] 测试验证功能

---

**提示**: 如果找不到获取 API Key 的方式，可以先不使用 API Key 进行部署，合约功能不受影响。稍后可以手动验证或联系 Monad 社区获取帮助。

**最后更新**: 2025年

