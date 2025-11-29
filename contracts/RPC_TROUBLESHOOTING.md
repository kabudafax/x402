# RPC 连接故障排查

## 问题

如果遇到以下错误：
```
Error: error sending request for url (https://testnet-rpc.monad.xyz/)
Context:
- Error #0: client error (Connect)
- Error #1: tls handshake eof
```

这表示无法连接到 Monad 测试网 RPC 端点。

## 解决方案

### 方法 1: 直接使用 RPC URL（推荐）

如果 `foundry.toml` 中配置的 RPC 端点不可用，可以直接在命令行中指定 RPC URL：

```bash
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url https://testnet-rpc.monad.xyz \
  --broadcast \
  --verify \
  -vvvv
```

### 方法 2: 使用备用 RPC 端点

如果主 RPC 端点不可用，可以尝试：

1. **检查 Monad 官方文档**获取最新的 RPC 端点
2. **使用公共 RPC 服务**（如果有）
3. **联系 Monad 社区**获取备用端点

### 方法 3: 测试 RPC 连接

在部署前，先测试 RPC 连接：

```bash
# 测试 RPC 连接
curl -X POST https://testnet-rpc.monad.xyz \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

如果返回错误，说明 RPC 端点确实不可用。

### 方法 4: 使用本地节点（如果有）

如果你运行了本地 Monad 测试网节点：

```bash
forge script scripts/Deploy.s.sol:DeployScript \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast \
  -vvvv
```

### 方法 5: 检查网络连接

1. **检查网络连接**：
   ```bash
   ping testnet-rpc.monad.xyz
   ```

2. **检查防火墙/代理设置**：
   - 确保防火墙允许 HTTPS 连接
   - 如果使用代理，配置 Foundry 使用代理

3. **尝试使用 VPN**：
   - 某些地区可能无法直接访问 RPC 端点

## 更新 foundry.toml

如果需要更换 RPC 端点，编辑 `contracts/foundry.toml`：

```toml
[rpc_endpoints]
monad_testnet = "https://your-new-rpc-endpoint.com"
```

## 获取最新的 RPC 端点

1. **Monad 官方文档**: https://docs.monad.xyz
2. **Monad Discord**: 在测试网频道询问
3. **Monad Twitter**: 关注官方账号获取更新

## 临时解决方案

如果 RPC 端点暂时不可用，可以：

1. **等待一段时间**后重试
2. **使用不同的网络**（如果可用）
3. **联系 Monad 团队**报告问题

## 常见错误

### HTTP 429 - Too Many Requests (速率限制)

**错误信息**: 
```
HTTP error 429 with body: {"jsonrpc":"2.0","error":{"code":-32029,"message":"Too Many Requests, Please apply an OnFinality API key or contact us to receive a higher rate limit"},"id":4}
```

**原因**: 
- 使用了 OnFinality 等公共 RPC 服务
- 超过了免费层的请求速率限制

**解决方案**:

1. **申请 OnFinality API Key**（推荐）:
   - 访问 https://onfinality.io
   - 注册账户并申请 API key
   - 在 RPC URL 中添加 API key：
     ```toml
     monad_testnet = "https://monad-testnet.api.onfinality.io/public?apikey=YOUR_API_KEY"
     ```

2. **使用其他 RPC 端点**:
   - 切换回官方 RPC：
     ```toml
     monad_testnet = "https://testnet-rpc.monad.xyz"
     ```
   - 或使用其他公共 RPC 服务

3. **等待后重试**:
   - 速率限制通常是按时间窗口计算的
   - 等待几分钟后重试

4. **减少请求频率**:
   - 使用 `--slow` 参数降低请求频率
   - 避免在短时间内多次运行部署脚本

### TLS Handshake EOF

这通常表示：
- RPC 服务器暂时不可用
- 网络连接问题
- SSL/TLS 证书问题

**解决方案**: 尝试使用备用 RPC 端点或等待后重试

### Connection Timeout

这表示无法建立连接。

**解决方案**: 
- 检查网络连接
- 检查防火墙设置
- 尝试使用 VPN

---

**最后更新**: 2025年

