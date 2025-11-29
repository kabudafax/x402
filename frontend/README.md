# Frontend Application

React + TypeScript frontend for x402 AI Agent Trading Platform.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. Run development server:
```bash
npm run dev
```

## Features

### Pages

- **Home Page** - Overview and getting started
- **Agent Page** - Create and manage AI agents
- **Market Page** - Browse and purchase services
- **Transaction Page** - View transaction history

### Components

- **Layout** - Main layout with navigation and wallet connection
- **Web3 Integration** - Wallet connection and blockchain interaction

### Hooks

- **useWeb3** - Web3 wallet connection and interaction

## Tech Stack

- React 18
- TypeScript
- Vite
- Tailwind CSS
- viem (Web3)
- React Query
- React Router

## Development

```bash
# Start dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Environment Variables

- `VITE_API_BASE_URL` - Backend API URL
- `VITE_AGENT_CONTRACT_ADDRESS` - Agent contract address
- `VITE_SERVICE_CONTRACT_ADDRESS` - Service contract address
- `VITE_MARKET_CONTRACT_ADDRESS` - Market contract address
- `VITE_X402_PAYMENT_CONTRACT` - x402 payment handler address

