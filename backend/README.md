# Backend API

FastAPI backend for x402 AI Agent Trading Platform.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. Set up database:
```bash
# Create database
createdb x402_db

# Run migrations
alembic upgrade head
```

4. Run the server:
```bash
uvicorn src.main:app --reload
```

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

