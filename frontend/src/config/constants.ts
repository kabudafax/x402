/**
 * Application constants and configuration
 */

// Monad Testnet Configuration
export const MONAD_CONFIG = {
  chainId: 10143,
  name: "Monad Testnet",
  // rpcUrl: "https://testnet-rpc.monad.xyz",
  rpcUrl: "https://rpc.ankr.com/monad_testnet",
  currency: {
    name: "MON",
    symbol: "MON",
    decimals: 18,
  },
  blockExplorer: {
    name: "Monad Explorer",
    url: "https://testnet.monadexplorer.com",
  },
} as const;

// Contract Addresses (will be set after deployment)
export const CONTRACT_ADDRESSES = {
  AGENT: import.meta.env.VITE_AGENT_CONTRACT_ADDRESS || "",
  SERVICE: import.meta.env.VITE_SERVICE_CONTRACT_ADDRESS || "",
  MARKET: import.meta.env.VITE_MARKET_CONTRACT_ADDRESS || "",
  X402_PAYMENT: import.meta.env.VITE_X402_PAYMENT_CONTRACT || "",
} as const;

// API Configuration
export const API_CONFIG = {
  baseUrl: import.meta.env.VITE_API_BASE_URL || "http://localhost:8000",
  apiVersion: "/api/v1", // Include /api/ prefix to match backend routes
} as const;

// Service Types
export const SERVICE_TYPES = {
  STRATEGY: "strategy",
  RISK_CONTROL: "risk_control",
  DATA_SOURCE: "data_source",
  OTHER: "other",
} as const;

// Agent Status
export const AGENT_STATUS = {
  ACTIVE: "active",
  PAUSED: "paused",
  INSUFFICIENT_BALANCE: "insufficient_balance",
} as const;

// Transaction Status
export const TRANSACTION_STATUS = {
  PENDING: "pending",
  SUCCESS: "success",
  FAILED: "failed",
} as const;

// Payment Types
export const PAYMENT_TYPES = {
  SERVICE_CALL: "service_call",
  SUBSCRIPTION: "subscription",
} as const;

