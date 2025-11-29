# Backend API

FastAPI backend for x402 AI Agent Trading Platform.

## 快速开始

### 1. 创建虚拟环境

```bash
# 推荐使用 Python 3.11 或 3.12（避免 Python 3.14 兼容性问题）
python3.11 -m venv venv
# 或
python3.12 -m venv venv

# 激活虚拟环境
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate   # Windows
```

### 2. 安装依赖

```bash
# 升级 pip
pip install --upgrade pip

# 安装依赖
pip install -r requirements.txt
```

**注意**: 如果 `psycopg2-binary` 安装失败（Python 3.14），项目已配置使用 `psycopg3`，会自动处理。

### 3. 配置环境变量

```bash
# 创建 .env 文件
cat > .env << EOF
# 数据库配置 - 选项 1: SQLite（最简单，用于快速测试）
DATABASE_URL=sqlite:///./x402_db.db

# 数据库配置 - 选项 2: PostgreSQL（推荐用于生产环境）
# DATABASE_URL=postgresql://postgres:password@localhost:5432/x402_db

# Monad 配置
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
MONAD_EXPLORER_URL=https://testnet.monadexplorer.com

# 合约地址（部署后填入）
X402_PAYMENT_CONTRACT=0x你的X402PaymentHandler合约地址
MARKET_CONTRACT_ADDRESS=0x你的Market合约地址

# 安全配置
SECRET_KEY=your-secret-key-change-this

# CORS
BACKEND_CORS_ORIGINS=http://localhost:3000,http://localhost:5173
EOF
```

**数据库选择**:
- **SQLite**（推荐用于快速测试）: 无需安装，直接使用 `DATABASE_URL=sqlite:///./x402_db.db`
- **PostgreSQL**（推荐用于生产）: 需要先安装并启动 PostgreSQL，详见 [DATABASE_SETUP.md](./DATABASE_SETUP.md)

### 4. 启动数据库（如果使用 PostgreSQL）

#### macOS 安装和启动 PostgreSQL:

```bash
# 使用 Homebrew 安装
brew install postgresql@15

# 启动 PostgreSQL 服务
brew services start postgresql@15

# 创建数据库
createdb x402_db
```

#### Linux 安装和启动 PostgreSQL:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# 启动服务
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 创建数据库
createdb x402_db
```

**如果使用 SQLite，可以跳过这一步！**

### 5. 初始化数据库

```bash
# 方法 1: 使用初始化脚本（简单，推荐）
python init_db.py

# 方法 2: 使用 Alembic（推荐生产环境）
# alembic upgrade head
```

### 6. 启动服务器

```bash
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

访问：
- API 文档: http://localhost:8000/docs
- 健康检查: http://localhost:8000/health

## 云部署

### Railway 部署（推荐，最简单）

**详细步骤请查看**: [RAILWAY_DEPLOYMENT_STEPS.md](./RAILWAY_DEPLOYMENT_STEPS.md)

**快速步骤**:

1. **访问 Railway**: https://railway.app，使用 GitHub 登录
2. **创建项目**: "New Project" → "Deploy from GitHub repo" → 选择仓库
3. **添加 PostgreSQL**: "+ New" → "Database" → "PostgreSQL"
4. **配置环境变量**（在 Web Service → Variables）:
   ```bash
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   X402_PAYMENT_CONTRACT=0x你的合约地址
   MARKET_CONTRACT_ADDRESS=0x你的合约地址
   MONAD_RPC_URL=https://testnet-rpc.monad.xyz
   MONAD_CHAIN_ID=10143
   SECRET_KEY=your-random-secret-key
   ```
5. **等待自动部署完成**
6. **初始化数据库**: 使用 Railway CLI 运行 `railway run python init_db.py`
7. **获取部署 URL**: Settings → Generate Domain

**其他平台**:
- [CLOUD_DEPLOYMENT.md](./CLOUD_DEPLOYMENT.md) - 详细云平台部署步骤（Render, Fly.io）
- [DATABASE_SETUP.md](./DATABASE_SETUP.md) - 数据库设置详细指南

## API Endpoints

### Users
- `POST /api/v1/users` - Create user
- `GET /api/v1/users/{wallet_address}` - Get user
- `GET /api/v1/users/{wallet_address}/agents` - Get user agents

### Agents
- `POST /api/v1/agents` - Create agent
- `GET /api/v1/agents/{agent_id}` - Get agent
- `GET /api/v1/agents/{agent_id}/transactions` - Get agent transactions
- `GET /api/v1/agents/{agent_id}/stats` - Get agent stats

### Services
- `POST /api/v1/services` - Create service
- `GET /api/v1/services` - Get services list
- `GET /api/v1/services/{service_id}` - Get service

### Market
- `GET /api/v1/market/services` - Get market services
- `GET /api/v1/market/services/{service_id}` - Get market service details

### Payments
- `GET /api/v1/payments` - Get payments list
- `GET /api/v1/payments/{payment_id}` - Get payment

## Database Models

- User
- Agent
- Service
- Transaction
- Payment

## Services

- BlockchainService - Interact with Monad blockchain
- X402PaymentService - Handle x402 payments

