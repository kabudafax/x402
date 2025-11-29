# 速率限制解决方案

## 问题

如果遇到以下错误：
```
HTTP error 429 with body: {"jsonrpc":"2.0","error":{"code":-32029,"message":"Too Many Requests, Please apply an OnFinality API key or contact us to receive a higher rate limit"},"id":4}
```

这表示你使用的 RPC 端点（如 OnFinality）有速率限制，你已经超过了免费层的请求限制。

## 解决方案

### 方案 1: 使用官方 RPC（推荐，无速率限制）

切换到 Monad 官方 RPC 端点，通常没有速率限制：

编辑 `contracts/foundry.toml`：

```toml
[rpc_endpoints]
monad_testnet = "https://testnet-rpc.monad.xyz"
```

然后运行部署：

```bash
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url monad_testnet \
  --broadcast \
  -vvvv
```

### 方案 2: 申请 OnFinality API Key

如果你想继续使用 OnFinality（通常更稳定），可以申请免费 API key：

1. **访问 OnFinality**:
   - 网址: https://onfinality.io
   - 注册账户（免费）

2. **申请 API Key**:
   - 登录后进入 Dashboard
   - 创建新的 API key
   - 复制 API key

3. **配置 API Key**:

   编辑 `contracts/foundry.toml`：

   ```toml
   [rpc_endpoints]
   monad_testnet = "https://monad-testnet.api.onfinality.io/public?apikey=YOUR_API_KEY"
   ```

   或者直接在命令行使用：

   ```bash
   forge script scripts/Deploy.s.sol:DeployScript \
     --rpc-url "https://monad-testnet.api.onfinality.io/public?apikey=YOUR_API_KEY" \
     --broadcast \
     -vvvv
   ```

### 方案 3: 等待后重试

速率限制通常是按时间窗口计算的（如每分钟 X 次请求）。你可以：

1. **等待几分钟**后重试
2. **使用 `--slow` 参数**降低请求频率：

   ```bash
   forge script scripts/Deploy.s.sol:DeployScript \
     --rpc-url monad_testnet \
     --broadcast \
     --slow \
     -vvvv
   ```

### 方案 4: 使用环境变量（避免在配置文件中暴露 API Key）

如果使用 OnFinality API key，可以通过环境变量传递：

1. **在 `.env` 文件中添加**：
   ```bash
   ONFINALITY_API_KEY=your_api_key_here
   ```

2. **在 `foundry.toml` 中使用**：
   ```toml
   monad_testnet = "https://monad-testnet.api.onfinality.io/public?apikey=${ONFINALITY_API_KEY}"
   ```

3. **确保 `.env` 在 `.gitignore` 中**，避免提交 API key

## 推荐配置

**对于测试和开发**，推荐使用官方 RPC：

```toml
[rpc_endpoints]
monad_testnet = "https://testnet-rpc.monad.xyz"
```

**对于生产环境或需要更高稳定性**，可以使用 OnFinality + API key：

```toml
[rpc_endpoints]
monad_testnet = "https://monad-testnet.api.onfinality.io/public?apikey=${ONFINALITY_API_KEY}"
```

## 快速修复

如果你想立即解决问题，切换到官方 RPC：

```bash
# 编辑 foundry.toml，将 monad_testnet 改为：
monad_testnet = "https://testnet-rpc.monad.xyz"

# 然后运行部署
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url monad_testnet \
  --broadcast \
  -vvvv
```

---

**最后更新**: 2025年

