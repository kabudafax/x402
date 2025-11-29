# 私钥配置说明

## 问题

如果遇到以下错误：
```
vm.envUint: failed parsing $PRIVATE_KEY as type uint256: missing hex prefix ("0x")
```

这是因为私钥格式不正确。

## 解决方案

### 1. 创建 `.env` 文件

在 `contracts` 目录下创建 `.env` 文件：

```bash
cd contracts
cp .env.example .env
```

### 2. 配置私钥

编辑 `.env` 文件，**私钥必须以 `0x` 开头**：

```bash
PRIVATE_KEY=0x你的私钥
```

### 3. 私钥格式要求

- ✅ **正确格式**: `PRIVATE_KEY=0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef`
- ❌ **错误格式**: `PRIVATE_KEY=1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef`（缺少 0x）

### 4. 完整示例

`.env` 文件示例：

```bash
# 私钥（必须以 0x 开头，64个十六进制字符）
PRIVATE_KEY=0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef

# Mock USDC 地址（可选）
MOCK_USDC_ADDRESS=0x...

# Monad Explorer API Key（可选）
MONAD_API_KEY=your_api_key
```

## 如何获取私钥

### 从 MetaMask 导出私钥

1. 打开 MetaMask
2. 点击账户图标
3. 选择 "账户详情"
4. 点击 "导出私钥"
5. 输入密码确认
6. 复制私钥（会自动包含 0x 前缀）

### 注意事项

⚠️ **安全警告**:
- 永远不要提交包含真实私钥的 `.env` 文件到 Git
- 确保 `.env` 在 `.gitignore` 中
- 只使用测试账户的私钥，不要使用主网账户

## 验证配置

运行部署脚本测试：

```bash
forge script scripts/Deploy.s.sol:DeployScript --rpc-url monad_testnet
```

如果配置正确，应该能看到部署账户地址和余额信息。

---

**最后更新**: 2025年

