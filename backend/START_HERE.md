# 🚀 快速开始指南

## 本地开发 - 3 步启动

### 步骤 1: 配置环境变量

```bash
cd backend

# 创建 .env 文件（使用 SQLite，最简单）
cat > .env << EOF
DATABASE_URL=sqlite:///./x402_db.db
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
X402_PAYMENT_CONTRACT=0x你的合约地址
MARKET_CONTRACT_ADDRESS=0x你的合约地址
SECRET_KEY=your-secret-key
BACKEND_CORS_ORIGINS=http://localhost:5173
EOF
```

### 步骤 2: 初始化数据库

```bash
# 激活虚拟环境（如果还没有）
source venv/bin/activate

# 初始化数据库
python init_db.py
```

### 步骤 3: 启动服务器

```bash
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

✅ **完成！** 访问 http://localhost:8000/docs 查看 API 文档

---

## Railway 部署 - 7 步完成

### 步骤 1: 准备代码

```bash
git add .
git commit -m "Ready for deployment"
git push origin main
```

### 步骤 2: 访问 Railway

1. 打开 https://railway.app
2. 使用 GitHub 登录
3. 点击 "New Project" → "Deploy from GitHub repo"
4. 选择你的仓库

### 步骤 3: 添加 PostgreSQL

1. 在项目中点击 "+ New"
2. 选择 "Database" → "PostgreSQL"
3. 等待数据库创建完成

### 步骤 4: 配置环境变量

在 Web Service → Variables 中添加：

```bash
DATABASE_URL=${{Postgres.DATABASE_URL}}
X402_PAYMENT_CONTRACT=0x你的合约地址
MARKET_CONTRACT_ADDRESS=0x你的合约地址
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
SECRET_KEY=your-random-secret-key
BACKEND_CORS_ORIGINS=https://your-frontend.com,http://localhost:5173
```

### 步骤 5: 等待部署

Railway 会自动部署，查看 "Deployments" 标签页

### 步骤 6: 初始化数据库

```bash
# 安装 Railway CLI
npm install -g @railway/cli

# 登录并链接项目
railway login
cd backend
railway link

# 初始化数据库
railway run python init_db.py
```

### 步骤 7: 获取 URL

1. Settings → Generate Domain
2. 复制 URL，例如: `https://x402-backend.railway.app`
3. 更新前端 `.env`: `VITE_API_BASE_URL=https://your-url.railway.app`

✅ **完成！** 后端已部署到 Railway

---

## 详细文档

- [DATABASE_SETUP.md](./DATABASE_SETUP.md) - 数据库设置详细指南
- [RAILWAY_DEPLOYMENT_STEPS.md](./RAILWAY_DEPLOYMENT_STEPS.md) - Railway 部署详细步骤
- [CLOUD_DEPLOYMENT.md](./CLOUD_DEPLOYMENT.md) - 其他云平台部署指南
- [README.md](./README.md) - 完整文档

---

## 常见问题

**Q: 如何启动 PostgreSQL？**

A: 
- macOS: `brew services start postgresql@15`
- Linux: `sudo systemctl start postgresql`
- 或使用 SQLite: `DATABASE_URL=sqlite:///./x402_db.db`

**Q: Railway 部署失败？**

A: 查看部署日志，检查环境变量是否正确配置

**Q: 数据库连接失败？**

A: 检查 `DATABASE_URL` 是否正确，确保数据库服务已启动

