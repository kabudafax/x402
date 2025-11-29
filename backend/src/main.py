"""
x402 AI Agent Trading Platform - Backend API
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from src.config import settings
from src.routes import users, agents, services, market, payments


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan events for startup and shutdown"""
    # Startup
    print("Starting x402 AI Agent Trading Platform API...")
    yield
    # Shutdown
    print("Shutting down API...")


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(users.router, prefix=settings.API_V1_STR, tags=["users"])
app.include_router(agents.router, prefix=settings.API_V1_STR, tags=["agents"])
app.include_router(services.router, prefix=settings.API_V1_STR, tags=["services"])
app.include_router(market.router, prefix=settings.API_V1_STR, tags=["market"])
app.include_router(payments.router, prefix=settings.API_V1_STR, tags=["payments"])


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "status": "running"
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy"}

