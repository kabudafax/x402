# CORS 跨域问题修复指南

## 问题

前端访问后端 API 时出现 CORS 错误：
```
Access to fetch at 'https://x402-7opt.onrender.com/api/v1/users/...' 
from origin 'http://localhost:5173' has been blocked by CORS policy: 
No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

## 原因

Render 上的后端服务没有配置 `BACKEND_CORS_ORIGINS` 环境变量，或者配置不正确。

## 解决方案

### 方法 1: 在 Render 上配置环境变量（推荐）

1. **登录 Render Dashboard**
   - 访问 https://render.com
   - 登录你的账号

2. **进入你的 Web Service**
   - 点击你的服务（例如：`x402-backend`）

3. **配置环境变量**
   - 点击 **"Environment"** 标签页
   - 找到或添加 `BACKEND_CORS_ORIGINS` 变量
   - 设置值为：
     ```
     http://localhost:5173,http://localhost:3000,https://your-frontend-domain.com
     ```
   - 点击 **"Save Changes"**

4. **重新部署**
   - Render 会自动重新部署
   - 等待部署完成（约 2-5 分钟）

### 方法 2: 临时允许所有来源（仅用于开发测试）

如果需要快速测试，可以临时允许所有来源：

在 Render 环境变量中设置：
```
BACKEND_CORS_ORIGINS=*
```

**注意**: 这仅用于开发测试，生产环境应该明确指定允许的域名。

### 方法 3: 修改后端代码允许所有来源（不推荐，仅用于开发）

如果需要，可以临时修改 `backend/src/main.py`：

```python
# 临时允许所有来源（仅用于开发）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 允许所有来源
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**不推荐在生产环境使用**，因为这会带来安全风险。

## 验证修复

1. **检查环境变量**
   - 在 Render Dashboard → 服务 → Environment
   - 确认 `BACKEND_CORS_ORIGINS` 包含 `http://localhost:5173`

2. **测试 API**
   - 打开浏览器开发者工具（F12）
   - 查看 Network 标签页
   - 发起 API 请求
   - 检查响应头中是否有 `Access-Control-Allow-Origin: http://localhost:5173`

3. **使用 curl 测试**
   ```bash
   curl -H "Origin: http://localhost:5173" \
        -H "Access-Control-Request-Method: GET" \
        -H "Access-Control-Request-Headers: X-Requested-With" \
        -X OPTIONS \
        https://x402-7opt.onrender.com/api/v1/users/test/agents \
        -v
   ```
   
   应该看到响应头：
   ```
   Access-Control-Allow-Origin: http://localhost:5173
   ```

## 500 内部服务器错误

如果还有 500 错误，可能是：

1. **数据库未初始化**
   - 在 Render Shell 中运行：`python init_db.py`

2. **数据库连接失败**
   - 检查 `DATABASE_URL` 环境变量是否正确
   - 确认使用 Internal Database URL

3. **查看后端日志**
   - 在 Render Dashboard → 服务 → Logs
   - 查看错误详情

## 完整的环境变量配置

在 Render 上应该配置以下环境变量：

```bash
# 数据库（从 PostgreSQL 服务复制 Internal Database URL）
DATABASE_URL=postgresql://x402_user:password@dpg-xxxxx-a.singapore-postgres.render.com/x402_db

# 合约地址
X402_PAYMENT_CONTRACT=0x你的地址
MARKET_CONTRACT_ADDRESS=0x你的地址

# Monad 配置
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
MONAD_EXPLORER_URL=https://testnet.monadexplorer.com

# CORS（重要！）
BACKEND_CORS_ORIGINS=http://localhost:5173,http://localhost:3000,https://your-frontend-domain.com

# 安全配置
SECRET_KEY=your-random-secret-key
```

## 常见问题

**Q: 修改环境变量后需要重启吗？**

A: Render 会自动重新部署，不需要手动重启。

**Q: 如何查看当前的环境变量？**

A: 在 Render Dashboard → 服务 → Environment 标签页查看。

**Q: 为什么还是报 CORS 错误？**

A: 
1. 确认环境变量已保存
2. 等待部署完成（查看 Events 标签页）
3. 清除浏览器缓存
4. 检查环境变量值是否正确（没有多余空格）

---

**完成修复后，前端应该可以正常访问后端 API 了！**

