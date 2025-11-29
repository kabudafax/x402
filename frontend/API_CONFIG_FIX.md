# API 配置修复说明

## 问题

前端调用 API 时出现错误：
```
GET https://x402-7opt.onrender.comv1/users/0x60a969a…/agents net::ERR_CONNECTION_CLOSED
```

**原因**: API URL 拼接错误，缺少 `/api/` 前缀。

- 当前拼接: `baseUrl` + `apiVersion` = `https://x402-7opt.onrender.com` + `v1` = `https://x402-7opt.onrender.comv1/...`
- 正确应该是: `https://x402-7opt.onrender.com/api/v1/...`

## 修复

已修复 `frontend/src/config/constants.ts`：

```typescript
// 修复前
apiVersion: "v1",

// 修复后
apiVersion: "/api/v1", // Include /api/ prefix to match backend routes
```

## 配置前端环境变量

确保 `frontend/.env` 文件包含：

```bash
VITE_API_BASE_URL=https://x402-7opt.onrender.com
```

**注意**: `baseUrl` 不应该包含 `/api`，因为 `apiVersion` 已经包含了 `/api/v1`。

## 验证

修复后，API 调用应该是：
- ✅ `https://x402-7opt.onrender.com/api/v1/users/{address}/agents`
- ✅ `https://x402-7opt.onrender.com/api/v1/agents`
- ✅ `https://x402-7opt.onrender.com/api/v1/market/services`

## 重启前端

修改配置后，需要重启前端开发服务器：

```bash
cd frontend
npm run dev
```

## 测试

1. 打开浏览器开发者工具（F12）
2. 查看 Network 标签页
3. 检查 API 请求的 URL 是否正确
4. 确认返回状态码是 200 而不是连接错误

---

**如果还有问题**，检查：
1. Render 服务是否正常运行（访问 `https://x402-7opt.onrender.com/health`）
2. CORS 配置是否正确（后端 `BACKEND_CORS_ORIGINS` 是否包含前端域名）
3. 网络连接是否正常

