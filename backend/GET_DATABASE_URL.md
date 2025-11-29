# 如何获取数据库连接 URL（Render）

## 📍 在 Render 中获取数据库 URL

### 步骤 1: 登录 Render Dashboard

1. 访问 https://render.com
2. 登录你的账号

### 步骤 2: 找到你的 PostgreSQL 数据库

1. 在 Dashboard 中，找到你创建的 **PostgreSQL** 服务
2. 点击数据库名称（例如：`x402-db`）

### 步骤 3: 获取 Internal Database URL

1. 在数据库详情页面，点击 **"Connections"** 标签页
2. 找到 **"Internal Database URL"** 部分
3. 点击 **"Copy"** 按钮复制 URL

**URL 格式示例**:
```
postgresql://x402_user:password@dpg-xxxxx-a.singapore-postgres.render.com/x402_db
```

### 步骤 4: 使用 Internal Database URL

⚠️ **重要**: 必须使用 **Internal Database URL**，不要使用 Public URL！

**原因**:
- Internal URL 用于 Render 内部服务之间的连接（免费且稳定）
- Public URL 用于外部访问（需要配置防火墙，可能收费）

---

## 📋 完整步骤（图文说明）

### 1. 进入数据库服务页面

```
Dashboard → 点击你的 PostgreSQL 服务（例如：x402-db）
```

### 2. 打开 Connections 标签页

在数据库详情页面，你会看到多个标签页：
- **Info** - 基本信息
- **Connections** - 连接信息 ⭐ **点击这里**
- **Settings** - 设置
- **Logs** - 日志

### 3. 复制 Internal Database URL

在 **Connections** 标签页中，你会看到：

```
Internal Database URL
postgresql://x402_user:password@dpg-xxxxx-a.singapore-postgres.render.com/x402_db
[Copy] 按钮
```

点击 **"Copy"** 按钮复制完整的 URL。

### 4. 在 Web Service 中使用

1. 进入你的 **Web Service**（例如：`x402-backend`）
2. 点击 **"Environment"** 标签页
3. 添加环境变量：
   ```
   Key: DATABASE_URL
   Value: postgresql://x402_user:password@dpg-xxxxx-a.singapore-postgres.render.com/x402_db
   ```
   （粘贴刚才复制的 URL）

---

## 🔍 如果找不到 Internal Database URL？

### 方法 1: 检查数据库状态

确保数据库服务状态是 **"Available"**（可用），而不是 "Paused" 或 "Stopped"。

### 方法 2: 查看 Info 标签页

在数据库的 **Info** 标签页，有时也会显示连接信息。

### 方法 3: 手动构建 URL

如果找不到，你可以手动构建 URL：

```
postgresql://[USER]:[PASSWORD]@[HOST]:[PORT]/[DATABASE]
```

从数据库的 **Info** 标签页获取：
- **User**: 数据库用户名（例如：`x402_user`）
- **Password**: 在创建数据库时设置的密码（如果忘记了，可以在 Settings 中重置）
- **Host**: 内部主机名（格式：`dpg-xxxxx-a.singapore-postgres.render.com`）
- **Port**: 通常是 `5432`（PostgreSQL 默认端口）
- **Database**: 数据库名称（例如：`x402_db`）

---

## 🔐 如果忘记了密码？

1. 进入数据库服务 → **"Settings"** 标签页
2. 找到 **"Reset Password"** 选项
3. 重置密码后，更新 Web Service 中的 `DATABASE_URL` 环境变量

---

## ✅ 验证数据库连接

### 在 Render Shell 中测试

1. 进入你的 Web Service → **"Shell"** 标签页
2. 运行：
   ```bash
   python -c "from src.config import settings; print(settings.DATABASE_URL)"
   ```
   应该显示你的数据库 URL（密码会被隐藏）

3. 测试连接：
   ```bash
   python -c "from src.database import engine; print('✅ Database connected')"
   ```

---

## 📝 完整示例

假设你的数据库信息是：
- **User**: `x402_user`
- **Password**: `abc123xyz`
- **Host**: `dpg-xxxxx-a.singapore-postgres.render.com`
- **Database**: `x402_db`

那么你的 `DATABASE_URL` 应该是：

```bash
DATABASE_URL=postgresql://x402_user:abc123xyz@dpg-xxxxx-a.singapore-postgres.render.com/x402_db
```

在 Web Service 的环境变量中设置：

```
Key: DATABASE_URL
Value: postgresql://x402_user:abc123xyz@dpg-xxxxx-a.singapore-postgres.render.com/x402_db
```

---

## ⚠️ 安全提示

1. **不要分享数据库 URL** - 包含密码，非常敏感
2. **只在环境变量中使用** - 不要硬编码在代码中
3. **定期更换密码** - 在 Settings 中重置密码
4. **使用 Internal URL** - 只在 Render 内部使用，不要暴露给外部

---

## 🆘 常见问题

**Q: Internal Database URL 和 Public Database URL 有什么区别？**

A:
- **Internal URL**: 用于 Render 内部服务之间连接，免费且稳定
- **Public URL**: 用于外部访问（如本地开发），可能需要配置防火墙

**Q: 可以在本地使用 Internal URL 吗？**

A: 不可以。Internal URL 只能在 Render 内部使用。如果要在本地连接，需要使用 Public URL 或配置 VPN。

**Q: 数据库连接失败怎么办？**

A:
1. 检查 URL 格式是否正确
2. 确认使用 Internal URL（不是 Public URL）
3. 检查数据库服务是否运行
4. 验证用户名和密码是否正确

---

**需要帮助？** 查看 Render 官方文档或检查数据库服务的 Logs 标签页。

