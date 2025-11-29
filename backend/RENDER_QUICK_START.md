# Render 部署快速指南（7 步完成）

## 🎯 前提条件

- GitHub 仓库已准备好代码
- 已部署的合约地址（X402PaymentHandler 和 Market）

---

## 📝 详细步骤

### 步骤 1: 注册 Render

1. 访问 **https://render.com**
2. 点击 **"Get Started for Free"**
3. 使用 **GitHub** 账号登录（推荐）
4. 授权 Render 访问你的 GitHub 仓库

---

### 步骤 2: 创建 PostgreSQL 数据库

1. 登录后，在 Dashboard 点击 **"New +"** 按钮（右上角）
2. 选择 **"PostgreSQL"**
3. 填写配置：
   ```
   Name: x402-db
   Database: x402_db
   User: x402_user
   Region: Singapore（或选择离你最近的区域）
   PostgreSQL Version: 15（默认即可）
   Plan: Free
   ```
4. 点击 **"Create Database"**
5. **等待 1-2 分钟**，数据库创建完成
6. 点击数据库名称进入详情页
7. 在 **"Connections"** 标签页，找到 **"Internal Database URL"**
8. **复制这个 URL**（格式类似：`postgresql://x402_user:password@dpg-xxxxx-a.singapore-postgres.render.com/x402_db`）

   ⚠️ **重要**: 必须使用 **Internal Database URL**，不要用 Public URL！

---

### 步骤 3: 创建 Web Service

1. 在 Dashboard 点击 **"New +"** 按钮
2. 选择 **"Web Service"**
3. 连接 GitHub 仓库：
   - 如果第一次使用，点击 **"Connect account"** 授权 GitHub
   - 搜索并选择你的 `x402` 仓库
   - 点击 **"Connect"**
4. 配置服务信息：
   ```
   Name: x402-backend
   Region: Singapore（与数据库相同的区域）
   Branch: main
   Root Directory: backend
   Environment: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: uvicorn src.main:app --host 0.0.0.0 --port $PORT
   Plan: Free
   ```
5. 点击 **"Advanced"**（可选，用于配置环境变量）
6. 在 **"Environment Variables"** 部分，点击 **"Add Environment Variable"**，添加以下变量：

   ```bash
   # 数据库 URL（从步骤 2 复制的 Internal Database URL）
   DATABASE_URL = postgresql://x402_user:password@dpg-xxxxx-a.singapore-postgres.render.com/x402_db
   
   # 合约地址（填入你部署的合约地址）
   X402_PAYMENT_CONTRACT = 0x你的X402PaymentHandler合约地址
   MARKET_CONTRACT_ADDRESS = 0x你的Market合约地址
   
   # Monad 配置
   MONAD_RPC_URL = https://testnet-rpc.monad.xyz
   MONAD_CHAIN_ID = 10143
   MONAD_EXPLORER_URL = https://testnet.monadexplorer.com
   
   # 安全配置（生成一个随机字符串）
   SECRET_KEY = your-random-secret-key-change-this-to-something-random
   
   # CORS（允许前端访问，用逗号分隔）
   BACKEND_CORS_ORIGINS = https://your-frontend-domain.com,http://localhost:5173
   ```

   **提示**: 也可以创建服务后再添加环境变量（在服务的 "Environment" 标签页）

7. 点击 **"Create Web Service"**

---

### 步骤 4: 等待部署完成

1. Render 会自动开始部署
2. 点击服务名称，进入服务详情页
3. 查看 **"Events"** 标签页，可以看到部署进度
4. 等待 **5-10 分钟**完成部署
5. 部署成功后，状态会显示 **"Live"**

---

### 步骤 5: 初始化数据库

1. 在服务详情页，点击 **"Shell"** 标签页
2. 点击 **"Open Shell"** 按钮
3. 在打开的 Shell 中运行：
   ```bash
   python init_db.py
   ```
4. 应该看到输出：
   ```
   Initializing database...
   Database URL: ...
   Creating tables...
   ✅ Database initialized successfully!
   
   Tables created:
     - users
     - agents
     - services
     - transactions
     - payments
   ```

---

### 步骤 6: 获取部署 URL 并验证

1. 在服务详情页顶部，可以看到你的服务 URL，例如：
   ```
   https://x402-backend.onrender.com
   ```
2. **复制这个 URL**

3. **验证部署**:
   ```bash
   # 健康检查
   curl https://x402-backend.onrender.com/health
   ```
   应该返回: `{"status": "healthy"}`

4. **查看 API 文档**:
   在浏览器打开: `https://x402-backend.onrender.com/docs`
   应该能看到 Swagger UI 文档

---

### 步骤 7: 更新前端配置

1. 编辑 `frontend/.env` 文件：
   ```bash
   VITE_API_BASE_URL=https://x402-backend.onrender.com
   ```

2. 重启前端开发服务器（如果正在运行）

---

## ✅ 完成！

你的后端现在已成功部署到 Render！

---

## ⚠️ 重要提示

### 免费服务限制

1. **休眠机制**: 
   - 免费服务在 **15 分钟无活动后会自动休眠**
   - 首次访问可能需要 **30-60 秒** 唤醒
   - 这是正常的，不是错误！

2. **数据库限制**:
   - 免费 PostgreSQL 有 **90 天限制**（之后需要升级）
   - 但足够用于开发和测试

### 常见问题

**Q: 部署失败？**

A: 
- 查看 **"Events"** 或 **"Logs"** 标签页的错误信息
- 检查环境变量是否正确配置
- 确认 `requirements.txt` 中的依赖版本兼容

**Q: 数据库连接失败？**

A: 
- 确认使用 **Internal Database URL**（不是 Public URL）
- 检查数据库服务是否已创建完成
- 确认环境变量 `DATABASE_URL` 正确

**Q: 首次访问很慢？**

A: 
- 这是正常的，免费服务需要唤醒
- 等待 30-60 秒即可

**Q: 如何更新代码？**

A: 
- 推送代码到 GitHub: `git push origin main`
- Render 会自动检测并重新部署

---

## 📊 查看日志和监控

- **日志**: 服务 → **"Logs"** 标签页
- **监控**: 服务 → **"Metrics"** 标签页（CPU、内存使用）

---

## 🔗 相关文档

- [RENDER_DEPLOYMENT.md](./RENDER_DEPLOYMENT.md) - 更详细的部署文档
- [FREE_DEPLOYMENT_OPTIONS.md](./FREE_DEPLOYMENT_OPTIONS.md) - 所有免费部署选项对比

---

**需要帮助？** 查看详细文档或检查 Render 的部署日志。

