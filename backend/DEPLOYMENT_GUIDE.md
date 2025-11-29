# 后端部署指南

## 本地开发环境设置

### 1. 创建虚拟环境

```bash
cd backend

# 使用 Python 3.11 或 3.12（推荐，避免 Python 3.14 兼容性问题）
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

**如果 psycopg2-binary 安装失败**，尝试：

```bash
# 方案 1: 安装 PostgreSQL 开发工具
brew install postgresql@15
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# 方案 2: 使用 psycopg3（如果方案 1 不行）
# 修改 requirements.txt，将 psycopg2-binary 改为：
# psycopg[binary]>=3.1.0
# 然后更新 DATABASE_URL 连接字符串格式

# 方案 3: 暂时使用 SQLite（仅用于开发测试）
# 在 .env 中设置: DATABASE_URL=sqlite:///./x402_db.db
```

### 3. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件
```

### 4. 初始化数据库

```bash
# 方法 1: 使用初始化脚本
python init_db.py

# 方法 2: 使用 Alembic
alembic upgrade head
```

### 5. 启动服务器

```bash
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

## 云部署

### 方案 1: Railway（推荐，最简单）

1. **注册 Railway**: https://railway.app

2. **创建新项目**:
   - 点击 "New Project"
   - 选择 "Deploy from GitHub repo"
   - 选择你的仓库

3. **添加 PostgreSQL 数据库**:
   - 在项目中点击 "New"
   - 选择 "Database" → "PostgreSQL"
   - Railway 会自动创建数据库

4. **配置环境变量**:
   - 在项目设置中添加环境变量：
     ```
     DATABASE_URL=<从 PostgreSQL 服务自动获取>
     X402_PAYMENT_CONTRACT=0x你的合约地址
     MARKET_CONTRACT_ADDRESS=0x你的合约地址
     MONAD_RPC_URL=https://testnet-rpc.monad.xyz
     MONAD_CHAIN_ID=10143
     SECRET_KEY=<生成一个随机字符串>
     ```

5. **部署**:
   - Railway 会自动检测 Python 项目
   - 使用 `railway.json` 配置（已创建）
   - 自动构建和部署

6. **获取部署 URL**:
   - 部署完成后，Railway 会提供一个 URL
   - 例如: `https://your-app.railway.app`

### 方案 2: Render

1. **注册 Render**: https://render.com

2. **创建 Web Service**:
   - 点击 "New" → "Web Service"
   - 连接 GitHub 仓库
   - 选择 `backend` 目录

3. **配置服务**:
   - **Environment**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn src.main:app --host 0.0.0.0 --port $PORT`

4. **添加 PostgreSQL 数据库**:
   - 创建新的 PostgreSQL 数据库
   - 复制数据库连接 URL

5. **配置环境变量**:
   - 在服务设置中添加环境变量（参考 `render.yaml`）

6. **部署**:
   - Render 会自动部署
   - 或使用 `render.yaml` 配置文件

### 方案 3: Fly.io

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

部署时需要配置以下环境变量：

### 必需配置

```bash
# 数据库（云平台会自动提供）
DATABASE_URL=postgresql://user:password@host:port/dbname

# 合约地址（部署后填入）
X402_PAYMENT_CONTRACT=0x你的X402PaymentHandler地址
MARKET_CONTRACT_ADDRESS=0x你的Market合约地址
```

### 可选配置

```bash
# Monad 配置（有默认值）
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
MONAD_EXPLORER_URL=https://testnet.monadexplorer.com

# 安全配置
SECRET_KEY=生成一个随机字符串（用于生产环境）
```

## 部署后步骤

1. **验证部署**:
   ```bash
   curl https://your-app-url.com/health
   ```

2. **初始化数据库**:
   - 通过 SSH 或控制台运行：
     ```bash
     python init_db.py
     ```
   - 或使用 Alembic:
     ```bash
     alembic upgrade head
     ```

3. **更新前端配置**:
   - 在 `frontend/.env` 中更新：
     ```bash
     VITE_API_BASE_URL=https://your-backend-url.com
     ```

## 故障排查

### 数据库连接失败

- 检查 `DATABASE_URL` 是否正确
- 确认数据库服务已启动
- 检查防火墙设置

### 依赖安装失败

- 检查 Python 版本（推荐 3.11 或 3.12）
- 查看构建日志
- 尝试更新 requirements.txt

### 服务无法启动

- 检查端口配置（云平台通常使用 `$PORT` 环境变量）
- 查看日志输出
- 验证环境变量配置

---

**推荐**: Railway 是最简单的部署方案，自动处理大部分配置。

