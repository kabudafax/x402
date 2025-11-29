# 数据库设置指南

## 本地开发 - 数据库选择

### 选项 1: SQLite（最简单，推荐用于快速测试）

**优点**:
- 无需安装额外软件
- 零配置
- 适合开发和测试

**步骤**:

1. **配置 `.env` 文件**:
   ```bash
   cd backend
   cp .env.example .env  # 如果还没有
   ```

2. **编辑 `.env`，设置 SQLite**:
   ```bash
   DATABASE_URL=sqlite:///./x402_db.db
   ```

3. **初始化数据库**:
   ```bash
   python init_db.py
   ```

4. **启动后端**:
   ```bash
   uvicorn src.main:app --reload
   ```

✅ **完成！** 数据库文件会创建在 `backend/x402_db.db`

---

### 选项 2: PostgreSQL（推荐用于生产环境）

#### macOS 安装 PostgreSQL

**方法 1: 使用 Homebrew（推荐）**

```bash
# 安装 PostgreSQL
brew install postgresql@15

# 启动 PostgreSQL 服务
brew services start postgresql@15

# 或手动启动（一次性）
pg_ctl -D /opt/homebrew/var/postgresql@15 start
```

**方法 2: 使用 Postgres.app**

1. 下载: https://postgresapp.com/
2. 安装并启动
3. 点击 "Initialize" 创建数据库

#### Linux 安装 PostgreSQL

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# 启动服务
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### Windows 安装 PostgreSQL

1. 下载: https://www.postgresql.org/download/windows/
2. 运行安装程序
3. 记住设置的密码
4. 服务会自动启动

#### 创建数据库

```bash
# 方法 1: 使用命令行
createdb x402_db

# 方法 2: 使用 psql
psql postgres
# 在 psql 中执行:
CREATE DATABASE x402_db;
\q
```

#### 配置 `.env` 文件

```bash
# 编辑 backend/.env
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/x402_db

# 或者如果使用默认用户（无密码）
DATABASE_URL=postgresql://postgres@localhost:5432/x402_db
```

#### 初始化数据库

```bash
cd backend
source venv/bin/activate
python init_db.py
```

#### 验证连接

```bash
# 测试连接
python -c "from src.database import engine; print('✅ Database connected')"
```

---

## Railway 部署 - 详细步骤

### 第一步：准备 GitHub 仓库

确保你的代码已推送到 GitHub：

```bash
git add .
git commit -m "Prepare for Railway deployment"
git push origin main
```

### 第二步：注册并登录 Railway

1. **访问**: https://railway.app
2. **点击**: "Start a New Project"
3. **登录**: 使用 GitHub 账号登录（推荐）

### 第三步：创建项目

1. **选择**: "Deploy from GitHub repo"
2. **授权**: 允许 Railway 访问你的 GitHub 仓库
3. **选择仓库**: 选择 `x402` 仓库
4. **选择目录**: 选择 `backend` 目录（或让 Railway 自动检测）

### 第四步：添加 PostgreSQL 数据库

1. **在项目中点击**: "+ New"
2. **选择**: "Database" → "PostgreSQL"
3. **等待**: Railway 会自动创建并配置数据库
4. **获取连接信息**: 
   - 点击 PostgreSQL 服务
   - 在 "Variables" 标签页可以看到 `DATABASE_URL`

### 第五步：配置环境变量

1. **点击你的服务**（不是数据库，是 Web Service）
2. **点击**: "Variables" 标签页
3. **添加以下环境变量**:

```bash
# 1. 数据库 URL（从 PostgreSQL 服务获取）
# 点击 PostgreSQL 服务 → Variables → 复制 DATABASE_URL
# 然后粘贴到 Web Service 的 Variables 中
DATABASE_URL=${{Postgres.DATABASE_URL}}

# 2. 合约地址（填入你部署的合约地址）
X402_PAYMENT_CONTRACT=0x你的X402PaymentHandler地址
MARKET_CONTRACT_ADDRESS=0x你的Market合约地址

# 3. Monad 配置
MONAD_RPC_URL=https://testnet-rpc.monad.xyz
MONAD_CHAIN_ID=10143
MONAD_EXPLORER_URL=https://testnet.monadexplorer.com

# 4. 安全配置（生成随机字符串）
SECRET_KEY=your-random-secret-key-here-change-this

# 5. CORS（如果需要，允许前端域名）
BACKEND_CORS_ORIGINS=https://your-frontend-domain.com,http://localhost:5173
```

**重要提示**:
- `DATABASE_URL=${{Postgres.DATABASE_URL}}` 是 Railway 的特殊语法，会自动引用 PostgreSQL 服务的 URL
- 如果 `${{Postgres.DATABASE_URL}}` 不工作，可以手动复制 PostgreSQL 服务的 `DATABASE_URL` 值

### 第六步：配置服务设置

1. **点击服务** → **Settings**
2. **Root Directory**: 设置为 `backend`（如果项目在根目录）
3. **Build Command**: Railway 会自动检测，通常是 `pip install -r requirements.txt`
4. **Start Command**: `uvicorn src.main:app --host 0.0.0.0 --port $PORT`

### 第七步：部署

1. **Railway 会自动开始部署**
2. **查看**: "Deployments" 标签页查看部署进度
3. **等待**: 通常需要 2-5 分钟

### 第八步：获取部署 URL

1. **部署完成后**，Railway 会提供一个 URL
2. **点击**: "Settings" → "Generate Domain"
3. **复制 URL**: 例如 `https://x402-backend-production.up.railway.app`

### 第九步：初始化数据库

**方法 1: 使用 Railway CLI（推荐）**

```bash
# 安装 Railway CLI
npm i -g @railway/cli

# 登录
railway login

# 链接项目
railway link

# 运行初始化脚本
railway run python init_db.py
```

**方法 2: 使用 Railway 控制台**

1. **点击服务** → **Connect** → **PostgreSQL**
2. **或使用**: Railway 提供的数据库连接工具
3. **运行**: `python init_db.py`（如果 Railway 支持）

**方法 3: 手动初始化（通过 API）**

如果上述方法都不行，可以创建一个临时的初始化端点，或使用数据库迁移工具。

### 第十步：验证部署

1. **健康检查**:
   ```bash
   curl https://your-railway-url.railway.app/health
   ```
   应该返回: `{"status": "healthy"}`

2. **API 文档**:
   访问: `https://your-railway-url.railway.app/docs`

3. **测试 API**:
   ```bash
   curl https://your-railway-url.railway.app/api/v1/users
   ```

### 第十一步：更新前端配置

在 `frontend/.env` 中更新:

```bash
VITE_API_BASE_URL=https://your-railway-url.railway.app
```

---

## Railway 部署检查清单

- [ ] GitHub 仓库已推送最新代码
- [ ] Railway 账号已注册并登录
- [ ] 项目已创建并连接到 GitHub 仓库
- [ ] PostgreSQL 数据库已添加
- [ ] 环境变量已配置（数据库 URL、合约地址等）
- [ ] 服务设置已配置（Root Directory、Start Command）
- [ ] 部署已完成且成功
- [ ] 部署 URL 已获取
- [ ] 数据库已初始化
- [ ] 健康检查通过
- [ ] API 文档可访问
- [ ] 前端配置已更新

---

## 常见问题

### Q: Railway 找不到 `backend` 目录？

**A**: 在服务设置中设置 **Root Directory** 为 `backend`

### Q: 如何查看部署日志？

**A**: 在 Railway 控制台 → "Deployments" → 点击部署 → 查看日志

### Q: 数据库连接失败？

**A**: 
- 检查 `DATABASE_URL` 是否正确
- 确保 PostgreSQL 服务已创建
- 尝试使用 `${{Postgres.DATABASE_URL}}` 语法

### Q: 如何重新部署？

**A**: 
- 推送新代码到 GitHub，Railway 会自动重新部署
- 或点击 "Redeploy" 按钮

### Q: 如何查看环境变量？

**A**: 服务 → "Variables" 标签页

### Q: 如何停止服务？

**A**: 服务 → "Settings" → "Delete Service"（或暂停服务）

---

**推荐流程**: 
1. 本地先用 SQLite 测试
2. 确认一切正常后，部署到 Railway
3. Railway 会自动处理 PostgreSQL 配置
