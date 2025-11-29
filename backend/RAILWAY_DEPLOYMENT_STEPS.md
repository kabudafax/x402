# Railway 部署步骤（图文版）

## 🚀 快速部署指南

### 步骤 1: 准备代码

```bash
# 确保代码已提交并推送到 GitHub
cd /Users/niezhicheng/Documents/competetion/x402
git add .
git commit -m "Ready for Railway deployment"
git push origin main
```

### 步骤 2: 访问 Railway

1. 打开浏览器，访问: **https://railway.app**
2. 点击 **"Start a New Project"** 或 **"Login"**
3. 使用 **GitHub** 账号登录

### 步骤 3: 创建新项目

1. 点击 **"+ New Project"**
2. 选择 **"Deploy from GitHub repo"**
3. 如果第一次使用，需要授权 Railway 访问 GitHub
4. 选择你的仓库: `x402`（或你的仓库名）
5. Railway 会自动检测项目类型

### 步骤 4: 添加 PostgreSQL 数据库

1. 在项目页面，点击 **"+ New"** 按钮
2. 选择 **"Database"** → **"PostgreSQL"**
3. Railway 会自动创建 PostgreSQL 数据库
4. 等待几秒钟，数据库创建完成

### 步骤 5: 配置环境变量

1. **点击你的 Web Service**（不是数据库）
2. 点击 **"Variables"** 标签页
3. 点击 **"+ New Variable"** 添加以下变量:

#### 必需的环境变量:

```bash
# 1. 数据库 URL（使用 Railway 的引用语法）
变量名: DATABASE_URL
值: ${{Postgres.DATABASE_URL}}
```

**注意**: `${{Postgres.DATABASE_URL}}` 是 Railway 的特殊语法，会自动引用 PostgreSQL 服务的连接 URL。

如果这个语法不工作，可以：
- 点击 PostgreSQL 服务
- 在 "Variables" 中复制 `DATABASE_URL` 的值
- 粘贴到 Web Service 的 `DATABASE_URL` 变量中

```bash
# 2. 合约地址（填入你部署的合约地址）
变量名: X402_PAYMENT_CONTRACT
值: 0x你的X402PaymentHandler合约地址

变量名: MARKET_CONTRACT_ADDRESS
值: 0x你的Market合约地址
```

```bash
# 3. Monad 配置
变量名: MONAD_RPC_URL
值: https://testnet-rpc.monad.xyz

变量名: MONAD_CHAIN_ID
值: 10143

变量名: MONAD_EXPLORER_URL
值: https://testnet.monadexplorer.com
```

```bash
# 4. 安全配置（生成一个随机字符串）
变量名: SECRET_KEY
值: your-random-secret-key-change-this-to-something-random
```

```bash
# 5. CORS 配置（允许前端访问）
变量名: BACKEND_CORS_ORIGINS
值: https://your-frontend-domain.com,http://localhost:5173
```

### 步骤 6: 配置服务设置

1. 点击服务 → **"Settings"** 标签页
2. 检查以下设置:

   - **Root Directory**: 如果项目在根目录，设置为 `backend`
   - **Build Command**: Railway 会自动检测，应该是 `pip install -r requirements.txt`
   - **Start Command**: `uvicorn src.main:app --host 0.0.0.0 --port $PORT`

### 步骤 7: 等待部署

1. Railway 会自动开始部署
2. 点击 **"Deployments"** 标签页查看进度
3. 等待部署完成（通常 2-5 分钟）
4. 查看日志，确保没有错误

### 步骤 8: 获取部署 URL

1. 部署完成后，点击 **"Settings"**
2. 找到 **"Generate Domain"** 或 **"Custom Domain"**
3. Railway 会自动生成一个 URL，例如:
   - `https://x402-backend-production.up.railway.app`
4. **复制这个 URL**，稍后会用到

### 步骤 9: 初始化数据库

#### 方法 A: 使用 Railway CLI（推荐）

```bash
# 1. 安装 Railway CLI
npm install -g @railway/cli

# 2. 登录
railway login

# 3. 在项目目录中链接 Railway 项目
cd /Users/niezhicheng/Documents/competetion/x402/backend
railway link

# 4. 运行数据库初始化
railway run python init_db.py
```

#### 方法 B: 使用 Railway 控制台

1. 点击服务 → **"Connect"** → **"PostgreSQL"**
2. Railway 会打开一个数据库连接界面
3. 如果支持，可以运行 SQL 命令或使用初始化脚本

#### 方法 C: 创建临时初始化端点（如果上述方法都不行）

可以临时添加一个初始化端点，部署后访问一次即可。

### 步骤 10: 验证部署

1. **健康检查**:
   ```bash
   curl https://your-railway-url.railway.app/health
   ```
   应该返回: `{"status": "healthy"}`

2. **API 文档**:
   在浏览器中打开: `https://your-railway-url.railway.app/docs`
   应该能看到 Swagger UI 文档

3. **测试 API**:
   ```bash
   curl https://your-railway-url.railway.app/api/v1/users
   ```

### 步骤 11: 更新前端配置

1. 编辑 `frontend/.env` 文件:
   ```bash
   VITE_API_BASE_URL=https://your-railway-url.railway.app
   ```

2. 重启前端开发服务器

---

## 📋 完整环境变量清单

在 Railway 的 Web Service → Variables 中添加:

```bash
DATABASE_URL=${{Postgres.DATABASE_URL}}
X402_PAYMENT_CONTRACT=0x你的地址
MARKET_CONTRACT_ADDRESS=0x你的地址
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
MONAD_EXPLORER_URL=https://testnet.monadexplorer.com
SECRET_KEY=your-random-secret-key
BACKEND_CORS_ORIGINS=https://your-frontend.com,http://localhost:5173
```

---

## 🔍 故障排查

### 问题 1: 部署失败

**检查**:
- 查看部署日志中的错误信息
- 确认 `requirements.txt` 中的依赖版本兼容
- 检查 Python 版本（Railway 通常使用 3.11）

### 问题 2: 数据库连接失败

**解决**:
- 确认 PostgreSQL 服务已创建
- 检查 `DATABASE_URL` 是否正确
- 尝试手动复制 PostgreSQL 的 `DATABASE_URL` 值

### 问题 3: 服务无法启动

**检查**:
- 查看日志输出
- 确认 `Start Command` 正确
- 检查端口配置（使用 `$PORT`）

### 问题 4: 找不到模块

**解决**:
- 确认 `Root Directory` 设置为 `backend`
- 检查 `requirements.txt` 是否包含所有依赖

---

## ✅ 部署成功检查清单

- [ ] Railway 项目已创建
- [ ] PostgreSQL 数据库已添加
- [ ] 所有环境变量已配置
- [ ] 服务设置已配置
- [ ] 部署已完成且成功
- [ ] 部署 URL 已获取
- [ ] 健康检查通过
- [ ] API 文档可访问
- [ ] 数据库已初始化
- [ ] 前端配置已更新

---

**完成！** 你的后端现在应该已经部署到 Railway 并可以访问了。

