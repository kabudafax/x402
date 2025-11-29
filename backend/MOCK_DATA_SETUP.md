# Mock数据设置说明

## 问题
前端访问 `/api/v1/users/0x60a969a669db4837ffc9d96bb81668c87041f4a4/agents` 返回 404 错误，因为数据库中还没有用户和agents数据。

## 解决方案

### 方案1: 自动初始化（推荐）✅

**已更新代码**：`src/main.py` 现在会在服务器启动时自动检查并创建模拟数据。

**操作步骤**：
1. **如果部署在 Render/Railway 等云平台**：
   - 代码已更新，下次部署时会自动创建数据
   - 或者手动触发重新部署（在平台Dashboard点击"Redeploy"）
   - 部署完成后，查看日志应该看到：
     ```
     🌱 Mock data not found, seeding...
     ✅ Mock data seeded successfully!
     ```

2. **如果本地运行**：
   ```bash
   cd backend
   # 重启服务器
   uvicorn src.main:app --reload
   ```
   服务器启动时会自动创建数据。

### 方案2: 手动运行初始化脚本

如果自动初始化失败，可以手动运行：

```bash
cd backend
python init_db.py
```

或者如果使用虚拟环境：
```bash
cd backend
source venv/bin/activate
python init_db.py
```

## 创建的数据

初始化脚本会创建以下模拟数据：

- **1个用户**: `0x60a969a669db4837ffc9d96bb81668c87041f4a4`
- **5个Agents**:
  - Alpha Trader (活跃, 余额: 1000 USDC)
  - Beta Strategy (活跃, 余额: 500 USDC)
  - Gamma Risk Manager (暂停, 余额: 200 USDC)
  - Delta Analyzer (活跃, 余额: 1500 USDC)
  - Epsilon Bot (余额不足, 余额: 10 USDC)
- **12个Services** (每种类型3个):
  - Strategy: 3个
  - Risk Control: 3个
  - Data Source: 3个
  - Other: 3个
- **Transactions**: 每个agent 2-3笔交易记录
- **Payments**: 前3个agents的支付记录

## 验证数据

### 方法1: 检查API响应

访问以下端点应该返回数据而不是404：

```bash
# 检查用户
curl https://your-backend-url.com/api/v1/users/0x60a969a669db4837ffc9d96bb81668c87041f4a4

# 检查用户的agents
curl https://your-backend-url.com/api/v1/users/0x60a969a669db4837ffc9d96bb81668c87041f4a4/agents

# 检查市场服务
curl https://your-backend-url.com/api/v1/market/services
```

### 方法2: 使用检查脚本（仅本地）

```bash
cd backend
source venv/bin/activate
python check_data.py
```

## 常见问题

**Q: 为什么还是404？**

A: 
1. 确认服务器已重新启动/重新部署
2. 查看服务器日志，确认数据已创建
3. 检查数据库连接是否正常
4. 确认钱包地址正确：`0x60a969a669db4837ffc9d96bb81668c87041f4a4`

**Q: 数据会重复创建吗？**

A: 不会。代码会检查数据是否已存在，只在不存在时创建。

**Q: 如何清除数据重新创建？**

A: 
1. 删除数据库表（谨慎操作）
2. 或者手动删除用户记录，然后重启服务器

## 日志示例

成功创建数据后，日志应该显示：

```
Starting x402 AI Agent Trading Platform API...
Initializing database tables...
✅ Database tables initialized successfully!
   Tables: users, agents, services, transactions, payments
🌱 Mock data not found, seeding...
✅ Mock data seeded successfully!
```

如果数据已存在：

```
Starting x402 AI Agent Trading Platform API...
Initializing database tables...
✅ Database tables initialized successfully!
   Tables: users, agents, services, transactions, payments
ℹ️  Mock data already exists, skipping seed
```

