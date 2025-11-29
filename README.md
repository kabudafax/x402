# x402 AI Agent Trading Platform

基于 x402 协议的 AI 代理交易市场平台，运行在 Monad 公链上。

## 项目概述

这是一个去中心化的 AI 代理交易平台，用户可以在 Monad 链上创建、配置和部署 AI 交易代理。代理可以自主购买链上其他代理的服务（策略生成、风险控制、数据源等），通过 x402 协议实现自动化的机器对机器（M2M）支付，形成完整的 AI 代理经济生态。

# 前端地址
https://x402-v572.vercel.app/

## 项目结构

```
x402/
├── frontend/              # React 前端应用
│   ├── src/
│   │   ├── components/   # UI 组件
│   │   ├── pages/        # 页面
│   │   ├── hooks/        # Web3 hooks
│   │   ├── utils/        # 工具函数
│   │   └── contracts/    # 合约 ABI
│   └── package.json
│
├── backend/               # Python FastAPI 后端
│   ├── src/
│   │   ├── routes/       # API 路由
│   │   ├── services/     # 业务逻辑
│   │   ├── models/       # 数据模型
│   │   └── utils/        # 工具函数
│   └── requirements.txt
│
├── contracts/             # Solidity 智能合约
│   ├── src/
│   │   ├── Agent.sol     # 代理合约
│   │   ├── Service.sol   # 服务合约
│   │   ├── Market.sol    # 市场合约
│   │   └── x402/         # x402 集成
│   ├── test/             # 测试文件
│   └── foundry.toml      # Foundry 配置
│
├── docs/                  # 文档
│   ├── PRD.md            # 产品需求文档
│   ├── API.md            # API 文档
│   └── DEPLOY.md         # 部署文档
│
└── README.md
```

## 技术栈

### 前端
- React 18 + TypeScript
- Vite
- Tailwind CSS + shadcn/ui
- viem (Web3)
- Zustand (状态管理)
- Recharts (图表)

### 后端
- Python + FastAPI
- PostgreSQL
- Redis
- Celery
- web3.py

### 区块链
- Monad 测试网
- Foundry (开发框架)
- Solidity 0.8.x
- x402 协议集成

## 快速开始

### 前置要求

- Node.js 18+
- Python 3.10+
- Foundry
- PostgreSQL
- Redis

### 安装依赖

#### 前端
```bash
cd frontend
npm install
```

#### 后端
```bash
cd backend
pip install -r requirements.txt
```

#### 合约
```bash
cd contracts
forge install
```

### 开发

#### 启动前端
```bash
cd frontend
npm run dev
```

#### 启动后端
```bash
cd backend
uvicorn src.main:app --reload
```

#### 编译合约
```bash
cd contracts
forge build
```

#### 测试合约
```bash
cd contracts
forge test
```

## 功能特性

- ✅ 用户创建和管理 AI 代理
- ✅ 代理服务市场（策略、风控、数据源）
- ✅ x402 协议自动支付
- ✅ 自主交易执行
- ✅ 技术指标分析
- ✅ 交易历史统计

## 文档

详细文档请查看 [docs](./docs/) 目录：

- [产品需求文档 (PRD)](./x402_prd.md)
- [API 文档](./docs/API.md) (待完成)
- [部署文档](./docs/DEPLOY.md) (待完成)

## 开发计划

- [x] PRD 文档
- [ ] 项目结构初始化
- [ ] Monad 测试网配置
- [ ] x402 协议集成研究
- [ ] 智能合约开发
- [ ] 后端 API 开发
- [ ] 前端 UI 开发
- [ ] 测试与部署

## 许可证

MIT License

## 联系方式

如有问题或建议，请提交 Issue 或 Pull Request。

