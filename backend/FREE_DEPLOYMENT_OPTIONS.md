# 免费部署选项（无需信用卡）

Railway 现在需要信用卡或只有 $5 试用额度。以下是**完全免费**的替代方案：

## 🆓 推荐方案（按简单程度排序）

### 1. Render（推荐，完全免费）⭐

**优点**:
- ✅ 完全免费（有免费层）
- ✅ 无需信用卡
- ✅ 自动部署
- ✅ 提供 PostgreSQL 数据库
- ✅ 配置简单

**限制**:
- 免费服务在 15 分钟无活动后会休眠
- 首次请求可能需要几秒唤醒

**部署步骤**:

#### 步骤 1: 注册 Render

1. 访问 https://render.com
2. 使用 GitHub 账号登录（推荐）
3. 无需信用卡

#### 步骤 2: 创建 PostgreSQL 数据库

1. 点击 **"New +"** → **"PostgreSQL"**
2. 配置：
   - **Name**: `x402-db`
   - **Database**: `x402_db`
   - **User**: `x402_user`
   - **Region**: 选择离你最近的（如 `Singapore`）
   - **Plan**: 选择 **Free**
3. 点击 **"Create Database"**
4. **重要**: 复制 **"Internal Database URL"**（稍后需要）

#### 步骤 3: 创建 Web Service

1. 点击 **"New +"** → **"Web Service"**
2. 连接 GitHub 仓库
3. 选择你的 `x402` 仓库
4. 配置：
   - **Name**: `x402-backend`
   - **Region**: 与数据库相同的区域
   - **Branch**: `main`
   - **Root Directory**: `backend`
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn src.main:app --host 0.0.0.0 --port $PORT`
   - **Plan**: 选择 **Free**

#### 步骤 4: 配置环境变量

在 Web Service 的 **"Environment"** 标签页添加：

```bash
# 数据库（从 PostgreSQL 服务复制 Internal Database URL）
DATABASE_URL=postgresql://x402_user:password@dpg-xxxxx-a.singapore-postgres.render.com/x402_db

# 合约地址
X402_PAYMENT_CONTRACT=0x你的X402PaymentHandler合约地址
MARKET_CONTRACT_ADDRESS=0x你的Market合约地址

# Monad 配置
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
MONAD_EXPLORER_URL=https://testnet.monadexplorer.com

# 安全配置
SECRET_KEY=your-random-secret-key-change-this

# CORS
BACKEND_CORS_ORIGINS=https://your-frontend.com,http://localhost:5173
```

#### 步骤 5: 部署

1. 点击 **"Create Web Service"**
2. Render 会自动开始部署
3. 等待 5-10 分钟完成部署

#### 步骤 6: 初始化数据库

1. 部署完成后，点击服务 → **"Shell"** 标签页
2. 运行：
   ```bash
   python init_db.py
   ```

#### 步骤 7: 获取 URL

部署完成后，Render 会提供一个 URL，例如：
- `https://x402-backend.onrender.com`

**注意**: 免费服务首次访问可能需要几秒唤醒。

---

### 2. Fly.io（月账单 < $5 免费）⭐

**优点**:
- ✅ 月账单低于 $5 完全免费
- ✅ 全球部署
- ✅ 性能好
- ✅ 无需信用卡（但需要验证手机号）

**部署步骤**:

#### 步骤 1: 安装 Fly CLI

```bash
curl -L https://fly.io/install.sh | sh
```

#### 步骤 2: 注册账号

```bash
fly auth signup
# 或
fly auth login
```

#### 步骤 3: 初始化项目

```bash
cd backend
fly launch
```

按提示配置：
- App name: `x402-backend`（或自动生成）
- Region: 选择离你最近的
- PostgreSQL: 选择 **Yes**（Fly 会自动创建）

#### 步骤 4: 配置环境变量

```bash
fly secrets set X402_PAYMENT_CONTRACT=0x你的地址
fly secrets set MARKET_CONTRACT_ADDRESS=0x你的地址
fly secrets set MONAD_RPC_URL=https://testnet-rpc.monad.xyz
fly secrets set MONAD_CHAIN_ID=10143
fly secrets set SECRET_KEY=your-random-secret-key
```

#### 步骤 5: 部署

```bash
fly deploy
```

#### 步骤 6: 初始化数据库

```bash
fly ssh console
python init_db.py
```

#### 步骤 7: 获取 URL

```bash
fly open
```

---

### 3. 本地部署 + ngrok（完全免费，适合开发测试）

**优点**:
- ✅ 完全免费
- ✅ 无需云平台
- ✅ 适合开发和测试

**步骤**:

#### 步骤 1: 本地启动后端

```bash
cd backend
source venv/bin/activate

# 使用 SQLite（最简单）
cat > .env << EOF
DATABASE_URL=sqlite:///./x402_db.db
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
X402_PAYMENT_CONTRACT=0x你的地址
MARKET_CONTRACT_ADDRESS=0x你的地址
SECRET_KEY=your-secret-key
BACKEND_CORS_ORIGINS=http://localhost:5173
EOF

python init_db.py
uvicorn src.main:app --host 0.0.0.0 --port 8000
```

#### 步骤 2: 安装并启动 ngrok

```bash
# 安装 ngrok
brew install ngrok  # macOS
# 或下载: https://ngrok.com/download

# 启动隧道
ngrok http 8000
```

#### 步骤 3: 获取公网 URL

ngrok 会显示一个 URL，例如：
- `https://abc123.ngrok.io`

#### 步骤 4: 更新前端配置

在 `frontend/.env` 中：
```bash
VITE_API_BASE_URL=https://abc123.ngrok.io
```

**注意**: 
- ngrok 免费版 URL 每次启动都会变化
- 适合开发和测试，不适合生产环境

---

### 4. Vercel（仅限前端，后端需要 Serverless Functions）

**注意**: Vercel 主要适合前端，后端需要改造成 Serverless Functions。

---

## 📊 平台对比

| 平台 | 免费额度 | 需要信用卡 | 数据库 | 推荐度 |
|------|---------|-----------|--------|--------|
| **Render** | ✅ 完全免费 | ❌ 不需要 | ✅ PostgreSQL | ⭐⭐⭐⭐⭐ |
| **Fly.io** | ✅ < $5/月免费 | ❌ 不需要 | ✅ PostgreSQL | ⭐⭐⭐⭐ |
| **Railway** | ❌ 需要信用卡 | ✅ 需要 | ✅ PostgreSQL | ⭐⭐⭐ |
| **本地 + ngrok** | ✅ 完全免费 | ❌ 不需要 | SQLite/本地 | ⭐⭐⭐ |

---

## 🚀 快速开始（推荐 Render）

### 最简单的方式：

1. **访问**: https://render.com
2. **注册**: 使用 GitHub 登录
3. **创建 PostgreSQL**: "New +" → "PostgreSQL" → Free
4. **创建 Web Service**: "New +" → "Web Service" → 连接 GitHub
5. **配置环境变量**: 添加数据库 URL 和合约地址
6. **部署**: 自动完成
7. **初始化数据库**: Shell → `python init_db.py`

**完成！** 你的后端现在有免费的公共 URL 了。

---

## 💡 推荐方案

- **开发/测试**: 本地 + ngrok
- **生产环境**: Render（免费）或 Fly.io（如果流量小）

---

## 📝 详细文档

- [CLOUD_DEPLOYMENT.md](./CLOUD_DEPLOYMENT.md) - 包含 Render 详细步骤
- [render.yaml](./render.yaml) - Render 配置文件（可选）

---

**总结**: 如果 Railway 没有免费额度，**Render 是最佳选择**，完全免费且配置简单！

