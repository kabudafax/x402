# 数据库初始化修复指南

## ✅ 好消息！

**后端现在会在启动时自动初始化数据库表！** 无需手动运行 `init_db.py`。

如果仍然遇到错误，请查看下方解决方案。

## 错误信息

```
sqlalchemy.exc.ProgrammingError: (psycopg.errors.UndefinedTable) relation "users" does not exist
```

## 原因

数据库表还没有创建。通常后端启动时会自动创建，但如果遇到错误，可能需要手动初始化。

## 解决方案

### 步骤 1: 进入 Render Shell

1. **登录 Render Dashboard**
   - 访问 https://render.com
   - 登录你的账号

2. **进入你的 Web Service**
   - 点击你的服务（例如：`x402-backend`）

3. **打开 Shell**
   - 点击 **"Shell"** 标签页
   - 点击 **"Open Shell"** 按钮
   - 等待 Shell 连接（可能需要几秒钟）

### 步骤 2: 初始化数据库

在打开的 Shell 中运行：

```bash
python init_db.py
```

**预期输出**：
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

### 步骤 3: 验证

1. **检查表是否创建成功**
   - 如果看到 "✅ Database initialized successfully!"，说明成功

2. **测试 API**
   - 刷新前端页面
   - 应该不再有 500 错误

## 如果 init_db.py 找不到

如果提示 `python init_db.py` 找不到文件，尝试：

```bash
# 查看当前目录
pwd

# 查看文件列表
ls -la

# 如果 init_db.py 在 backend 目录
cd backend
python init_db.py

# 或者使用完整路径
python /opt/render/project/src/backend/init_db.py
```

## 如果还有问题

### 检查数据库连接

在 Shell 中运行：

```bash
python -c "from src.config import settings; print('Database URL:', settings.DATABASE_URL.split('@')[-1] if '@' in settings.DATABASE_URL else 'local')"
```

应该显示数据库连接信息。

### 手动创建表（如果 init_db.py 不工作）

在 Shell 中运行：

```bash
python -c "
from src.database import Base, engine
from src.models import User, Agent, Service, Transaction, Payment
print('Creating tables...')
Base.metadata.create_all(bind=engine)
print('✅ Tables created!')
"
```

## 完整步骤总结

1. ✅ Render Dashboard → 你的服务 → Shell
2. ✅ 点击 "Open Shell"
3. ✅ 运行 `python init_db.py`
4. ✅ 等待完成
5. ✅ 刷新前端页面测试

---

**完成！** 数据库表创建后，API 应该可以正常工作了。

