# 云部署指南

本指南详细说明如何将后端部署到云平台。

## 推荐平台

### ⚠️ Railway 更新

Railway 现在需要信用卡或只有 $5 试用额度。如果没有免费额度，推荐使用 **Render**（完全免费，无需信用卡）。

### 1. Render（推荐，完全免费）⭐

**优点**:
- ✅ 完全免费（无需信用卡）
- ✅ 自动部署
- ✅ 提供 PostgreSQL 数据库
- ✅ 配置简单

**限制**:
- 免费服务在 15 分钟无活动后会休眠
- 首次请求可能需要几秒唤醒

**详细步骤见**: [FREE_DEPLOYMENT_OPTIONS.md](./FREE_DEPLOYMENT_OPTIONS.md)

### 2. Railway（需要信用卡或试用额度）

**优点**:
- 自动检测 Python 项目
- 自动配置 PostgreSQL
- 部署简单

**步骤**:

1. **注册 Railway**
   - 访问 https://railway.app
   - 使用 GitHub 账号登录

2. **创建项目**
   - 点击 "New Project"
   - 选择 "Deploy from GitHub repo"
   - 选择你的仓库

3. **添加 PostgreSQL**
   - 在项目中点击 "+ New"
   - 选择 "Database" → "PostgreSQL"
   - Railway 会自动创建并配置数据库

4. **配置环境变量**
   - 点击项目 → "Variables"
   - 添加以下环境变量：

   ```bash
   # 数据库（Railway 会自动提供，但需要手动添加）
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   
   # 合约地址（填入你部署的合约地址）
   X402_PAYMENT_CONTRACT=0x你的X402PaymentHandler地址
   MARKET_CONTRACT_ADDRESS=0x你的Market合约地址
   
   # Monad 配置
   MONAD_RPC_URL=https://testnet-rpc.monad.xyz
   MONAD_CHAIN_ID=10143
   MONAD_EXPLORER_URL=https://testnet.monadexplorer.com
   
   # 安全配置（生成随机字符串）
   SECRET_KEY=your-random-secret-key-here
   ```

5. **部署**
   - Railway 会自动检测并部署
   - 查看 "Deployments" 标签页
   - 等待部署完成

6. **获取 URL**
   - 部署完成后，Railway 会提供一个 URL
   - 例如: `https://x402-backend.railway.app`

7. **初始化数据库**
   - 点击项目 → "Connect" → "PostgreSQL"
   - 或使用 Railway CLI:
     ```bash
     railway connect postgres
     python init_db.py
     ```

### 3. Fly.io（月账单 < $5 免费）

**步骤**:

1. **安装 flyctl**:
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **登录**:
   ```bash
   fly auth login
   ```

3. **初始化**:
   ```bash
   cd backend
   fly launch
   ```

4. **配置环境变量**:
   ```bash
   fly secrets set DATABASE_URL=your_database_url
   fly secrets set X402_PAYMENT_CONTRACT=0x...
   fly secrets set MARKET_CONTRACT_ADDRESS=0x...
   ```

5. **部署**:
   ```bash
   fly deploy
   ```

## 环境变量配置清单

### 必需配置

```bash
# 数据库（云平台会自动提供）
DATABASE_URL=postgresql://user:password@host:port/dbname

# 合约地址（部署后填入）
X402_PAYMENT_CONTRACT=0x你的X402PaymentHandler地址
MARKET_CONTRACT_ADDRESS=0x你的Market合约地址
```

### 推荐配置

```bash
# Monad 配置
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
MONAD_EXPLORER_URL=https://testnet.monadexplorer.com

# 安全配置
SECRET_KEY=生成一个随机字符串（用于生产环境）
```

### 可选配置

```bash
# Service 合约地址（如果部署了）
SERVICE_CONTRACT_ADDRESS=0x...

# Redis（如果需要）
REDIS_URL=redis://...

# CORS（如果需要允许特定域名）
BACKEND_CORS_ORIGINS=https://your-frontend-domain.com
```

## 部署后验证

### 1. 检查健康状态

```bash
curl https://your-backend-url.com/health
```

应该返回：
```json
{"status": "healthy"}
```

### 2. 检查 API 文档

访问：
```
https://your-backend-url.com/docs
```

应该能看到 Swagger UI 文档。

### 3. 初始化数据库

通过 SSH 或控制台运行：

```bash
python init_db.py
```

或使用 Alembic：

```bash
alembic upgrade head
```

## 更新前端配置

部署完成后，更新 `frontend/.env`:

```bash
VITE_API_BASE_URL=https://your-backend-url.com
```

## 故障排查

### 数据库连接失败

- 检查 `DATABASE_URL` 是否正确
- 确认数据库服务已启动
- 检查防火墙/网络设置

### 依赖安装失败

- 检查 Python 版本（云平台通常使用 3.11）
- 查看构建日志
- 确保 `requirements.txt` 使用兼容版本

### 服务无法启动

- 检查端口配置（使用 `$PORT` 环境变量）
- 查看日志输出
- 验证环境变量配置

### psycopg 连接错误

如果使用 psycopg3，确保连接字符串格式正确：
- psycopg3: `postgresql+psycopg://...`
- psycopg2: `postgresql://...`

## 快速部署检查清单

- [ ] 注册云平台账号
- [ ] 连接 GitHub 仓库
- [ ] 创建 PostgreSQL 数据库
- [ ] 配置环境变量（合约地址、数据库 URL 等）
- [ ] 部署服务
- [ ] 验证健康检查端点
- [ ] 初始化数据库
- [ ] 更新前端 API URL
- [ ] 测试 API 功能

---

**推荐**: 
- **Render** - 完全免费，无需信用卡（推荐）
- **Fly.io** - 月账单 < $5 免费
- **Railway** - 需要信用卡或试用额度

**详细免费部署指南**: [FREE_DEPLOYMENT_OPTIONS.md](./FREE_DEPLOYMENT_OPTIONS.md)

