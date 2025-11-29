# 快速启动指南

## 修复的问题

✅ **psycopg2-binary 安装问题** - 已更新为使用 `psycopg3`（更好的 Python 3.14 兼容性）
✅ **依赖版本更新** - 升级到最新版本以支持 Python 3.14
✅ **配置错误修复** - 修复了 CORS 配置解析问题
✅ **SQLAlchemy 保留字冲突** - 修复了 `metadata` 字段名冲突

## 快速启动步骤

### 1. 激活虚拟环境并安装依赖

```bash
cd backend
source venv/bin/activate  # 如果还没有激活

# 安装/更新依赖
pip install --upgrade pip
pip install -r requirements.txt
```

### 2. 配置环境变量

```bash
# 如果没有 .env 文件，创建它
cp .env.example .env

# 编辑 .env，至少配置：
# - DATABASE_URL（如果使用 PostgreSQL）
# - 或使用 SQLite: DATABASE_URL=sqlite:///./x402_db.db
```

### 3. 初始化数据库

```bash
# 使用初始化脚本（简单）
python init_db.py
```

### 4. 启动服务器

```bash
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

### 5. 验证

访问 http://localhost:8000/docs 查看 API 文档

## 云部署（Railway - 推荐）

### 最简单的方式

1. **访问 Railway**: https://railway.app
2. **登录**（使用 GitHub）
3. **创建项目** → "Deploy from GitHub repo"
4. **添加 PostgreSQL** → "New" → "Database" → "PostgreSQL"
5. **配置环境变量**:
   - `DATABASE_URL` = `${{Postgres.DATABASE_URL}}`（从 PostgreSQL 服务获取）
   - `X402_PAYMENT_CONTRACT` = 你的合约地址
   - `MARKET_CONTRACT_ADDRESS` = 你的合约地址
   - `SECRET_KEY` = 随机字符串
6. **自动部署** - Railway 会自动检测并部署

详细步骤见 [CLOUD_DEPLOYMENT.md](./CLOUD_DEPLOYMENT.md)

## 常见问题

### Q: psycopg 安装失败？

**A**: 项目已配置使用 `psycopg3`，应该可以正常安装。如果还有问题：
- 确保使用最新版本的 pip: `pip install --upgrade pip`
- 或暂时使用 SQLite: `DATABASE_URL=sqlite:///./x402_db.db`

### Q: 后端启动失败？

**A**: 
- 检查 `.env` 文件是否存在
- 检查数据库连接配置
- 查看错误日志

### Q: 如何部署到云？

**A**: 推荐使用 Railway，最简单。详见 [CLOUD_DEPLOYMENT.md](./CLOUD_DEPLOYMENT.md)

---

**现在依赖已修复，可以正常安装和运行了！**

