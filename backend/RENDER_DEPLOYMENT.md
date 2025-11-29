# Render 部署详细步骤（完全免费）

## 🎯 为什么选择 Render？

- ✅ **完全免费** - 无需信用卡
- ✅ **自动部署** - 连接 GitHub 自动部署
- ✅ **PostgreSQL 数据库** - 免费提供
- ✅ **配置简单** - 5 分钟完成部署

## 📋 部署步骤

### 步骤 1: 注册 Render

1. 访问 https://render.com
2. 点击 **"Get Started for Free"**
3. 使用 **GitHub** 账号登录（推荐）
4. 授权 Render 访问你的 GitHub 仓库

### 步骤 2: 创建 PostgreSQL 数据库

1. 在 Dashboard 点击 **"New +"**
2. 选择 **"PostgreSQL"**
3. 配置数据库：
   ```
   Name: x402-db
   Database: x402_db
   User: x402_user
   Region: Singapore (或离你最近的)
   PostgreSQL Version: 15 (默认)
   Plan: Free
   ```
4. 点击 **"Create Database"**
5. **重要**: 等待数据库创建完成（约 1-2 分钟）
6. 点击数据库 → **"Connections"** → 复制 **"Internal Database URL"**
   - 格式类似: `postgresql://x402_user:password@dpg-xxxxx-a.singapore-postgres.render.com/x402_db`
   - 📖 **详细步骤**: 如果找不到，查看 [GET_DATABASE_URL.md](./GET_DATABASE_URL.md)

### 步骤 3: 创建 Web Service

1. 在 Dashboard 点击 **"New +"**
2. 选择 **"Web Service"**
3. 连接 GitHub 仓库：
   - 如果第一次，点击 **"Connect account"** 授权
   - 选择你的 `x402` 仓库
4. 配置服务：
   ```
   Name: x402-backend
   Region: Singapore (与数据库相同)
   Branch: main
   Root Directory: backend
   Environment: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: uvicorn src.main:app --host 0.0.0.0 --port $PORT
   Plan: Free
   ```

### 步骤 4: 配置环境变量

在创建服务时或创建后，在 **"Environment"** 标签页添加：

```bash
# 数据库 URL（从 PostgreSQL 服务复制）
DATABASE_URL=postgresql://x402_user:password@dpg-xxxxx-a.singapore-postgres.render.com/x402_db

# 合约地址（填入你部署的合约地址）
X402_PAYMENT_CONTRACT=0x你的X402PaymentHandler合约地址
MARKET_CONTRACT_ADDRESS=0x你的Market合约地址

# Monad 配置
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
MONAD_EXPLORER_URL=https://testnet.monadexplorer.com

# 安全配置（生成随机字符串）
SECRET_KEY=your-random-secret-key-change-this-to-something-random

# CORS（允许前端访问）
BACKEND_CORS_ORIGINS=https://your-frontend-domain.com,http://localhost:5173
```

**重要提示**:
- `DATABASE_URL` 必须使用 **Internal Database URL**（不是 Public URL）
- 如果使用 Public URL，连接会失败

### 步骤 5: 创建并部署

1. 点击 **"Create Web Service"**
2. Render 会自动开始部署
3. 查看 **"Events"** 标签页查看部署进度
4. 等待 5-10 分钟完成部署

### 步骤 6: 验证数据库初始化 ✅

**好消息！** 后端现在会在启动时**自动初始化数据库表**！

部署完成后：

1. **查看部署日志**
   - 在服务 → **"Logs"** 标签页
   - 查找：
     ```
     ✅ Database tables initialized successfully!
     ```

2. **如果自动初始化失败**
   - 如果看到 `relation "users" does not exist` 错误
   - 需要手动初始化（见下方）

### 手动初始化（仅在自动初始化失败时）

1. 点击服务 → **"Shell"** 标签页
2. 点击 **"Open Shell"**
3. 运行：
   ```bash
   python init_db.py
   ```

**详细说明**: 查看 [AUTO_DB_INIT.md](./AUTO_DB_INIT.md) 或 [DATABASE_INIT_FIX.md](./DATABASE_INIT_FIX.md)

### 步骤 7: 获取部署 URL

1. 部署完成后，Render 会自动生成一个 URL
2. 在服务页面顶部可以看到，例如：
   - `https://x402-backend.onrender.com`
3. **复制这个 URL**

### 步骤 8: 验证部署

1. **健康检查**:
   ```bash
   curl https://x402-backend.onrender.com/health
   ```
   应该返回: `{"status": "healthy"}`

2. **API 文档**:
   在浏览器打开: `https://x402-backend.onrender.com/docs`
   应该能看到 Swagger UI

3. **测试 API**:
   ```bash
   curl https://x402-backend.onrender.com/api/v1/users
   ```

### 步骤 9: 更新前端配置

在 `frontend/.env` 中更新：

```bash
VITE_API_BASE_URL=https://x402-backend.onrender.com
```

---

## ⚠️ 注意事项

### 免费服务限制

1. **休眠机制**: 
   - 免费服务在 15 分钟无活动后会休眠
   - 首次请求可能需要 30-60 秒唤醒
   - 这是正常的，不是错误

2. **性能**:
   - 免费服务资源有限
   - 适合开发和测试
   - 生产环境建议升级到付费计划

3. **数据库**:
   - 免费 PostgreSQL 有 90 天限制（之后需要升级）
   - 但足够用于开发和测试

### 常见问题

**Q: 部署失败？**

A: 
- 检查构建日志中的错误
- 确认 `requirements.txt` 中的依赖版本兼容
- 检查 Python 版本（Render 使用 3.11）

**Q: 数据库连接失败？**

A: 
- 确认使用 **Internal Database URL**（不是 Public URL）
- 检查数据库服务是否已创建完成
- 确认环境变量 `DATABASE_URL` 正确

**Q: 服务无法启动？**

A: 
- 检查 `Start Command` 是否正确
- 查看日志输出
- 确认端口使用 `$PORT` 环境变量

**Q: 首次访问很慢？**

A: 
- 这是正常的，免费服务需要唤醒
- 等待 30-60 秒即可

---

## 🔄 更新部署

每次推送代码到 GitHub，Render 会自动重新部署：

```bash
git add .
git commit -m "Update backend"
git push origin main
```

Render 会自动检测并开始新的部署。

---

## 📊 监控和日志

1. **查看日志**:
   - 服务 → **"Logs"** 标签页
   - 实时查看应用日志

2. **监控**:
   - 服务 → **"Metrics"** 标签页
   - 查看 CPU、内存使用情况

---

## ✅ 部署检查清单

- [ ] Render 账号已注册
- [ ] PostgreSQL 数据库已创建
- [ ] 数据库 Internal URL 已复制
- [ ] Web Service 已创建
- [ ] 环境变量已配置（数据库 URL、合约地址等）
- [ ] 部署已完成且成功
- [ ] 数据库已初始化
- [ ] 健康检查通过
- [ ] API 文档可访问
- [ ] 前端配置已更新

---

**完成！** 你的后端现在已免费部署到 Render！

**下一步**: 更新前端配置，连接部署的后端 API。


