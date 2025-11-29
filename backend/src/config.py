"""
Configuration settings for the backend application.
"""
import os
from typing import Optional
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings."""
    
    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://user:password@localhost:5432/x402_db"
    )
    
    # Redis
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    
    # Monad Testnet Configuration
    MONAD_RPC_URL: str = os.getenv(
        "MONAD_RPC_URL",
        "https://testnet-rpc.monad.xyz"
    )
    MONAD_CHAIN_ID: int = int(os.getenv("MONAD_CHAIN_ID", "10143"))
    MONAD_EXPLORER_URL: str = os.getenv(
        "MONAD_EXPLORER_URL",
        "https://testnet.monadexplorer.com"
    )
    
    # Contract Addresses (will be set after deployment)
    AGENT_CONTRACT_ADDRESS: Optional[str] = os.getenv("AGENT_CONTRACT_ADDRESS")
    SERVICE_CONTRACT_ADDRESS: Optional[str] = os.getenv("SERVICE_CONTRACT_ADDRESS")
    MARKET_CONTRACT_ADDRESS: Optional[str] = os.getenv("MARKET_CONTRACT_ADDRESS")
    
    # x402 Configuration
    X402_PAYMENT_CONTRACT: Optional[str] = os.getenv("X402_PAYMENT_CONTRACT")
    
    # API Settings
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "x402 AI Agent Trading Platform"
    VERSION: str = "0.1.0"
    
    # CORS
    BACKEND_CORS_ORIGINS: str = os.getenv(
        "BACKEND_CORS_ORIGINS",
        "http://localhost:3000,http://localhost:5173"
    )
    
    @property
    def cors_origins_list(self) -> list[str]:
        """Parse CORS origins from comma-separated string"""
        origins = [origin.strip() for origin in self.BACKEND_CORS_ORIGINS.split(",")]
        # Handle empty string or "*" for development
        if not origins or origins == [""]:
            return ["*"]  # Default to allow all in development
        return origins
    
    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()

