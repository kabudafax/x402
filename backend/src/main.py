"""
x402 AI Agent Trading Platform - Backend API
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from decimal import Decimal
from src.config import settings
from src.routes import users, agents, services, market, payments
from src.database import Base, engine, SessionLocal
from src.models import User, Agent, Service, Transaction, Payment


def generate_mock_address(index: int) -> str:
    """Generate a mock Ethereum address"""
    hex_part = hex(index)[2:].zfill(40)
    return f"0x{hex_part}"


def check_and_seed_mock_data():
    """Check if mock data exists, if not, seed it"""
    try:
        db = SessionLocal()
        target_wallet = "0x60a969a669db4837ffc9d96bb81668c87041f4a4"
        user = db.query(User).filter(User.wallet_address == target_wallet).first()
        
        if not user:
            print("🌱 Mock data not found, seeding...")
            _seed_mock_data(db)
            print("✅ Mock data seeded successfully!")
        else:
            print("ℹ️  Mock data already exists, skipping seed")
        db.close()
    except Exception as e:
        print(f"⚠️  Warning: Could not check/seed mock data: {e}")
        import traceback
        traceback.print_exc()
        print("   You may need to run 'python init_db.py' manually")


def _seed_mock_data(db):
    """Seed database with mock data (internal function)"""
    target_wallet = "0x60a969a669db4837ffc9d96bb81668c87041f4a4"
    
    # 1. Create or get User
    user = db.query(User).filter(User.wallet_address == target_wallet).first()
    if not user:
        user = User(wallet_address=target_wallet)
        db.add(user)
        db.commit()
        db.refresh(user)
    
    # 2. Create Agents
    agents_data = [
        {"name": "Alpha Trader", "description": "High-frequency trading agent specializing in momentum strategies",
         "contract_address": generate_mock_address(1), "balance": Decimal("1000.0"), "status": "active"},
        {"name": "Beta Strategy", "description": "Multi-strategy agent with risk-adjusted portfolio management",
         "contract_address": generate_mock_address(2), "balance": Decimal("500.0"), "status": "active"},
        {"name": "Gamma Risk Manager", "description": "Advanced risk control agent with dynamic position sizing",
         "contract_address": generate_mock_address(3), "balance": Decimal("200.0"), "status": "paused"},
        {"name": "Delta Analyzer", "description": "AI-powered market analysis agent with sentiment detection",
         "contract_address": generate_mock_address(4), "balance": Decimal("1500.0"), "status": "active"},
        {"name": "Epsilon Bot", "description": "Automated trading bot with low capital requirements",
         "contract_address": generate_mock_address(5), "balance": Decimal("10.0"), "status": "insufficient_balance"}
    ]
    
    created_agents = []
    for agent_data in agents_data:
        existing_agent = db.query(Agent).filter(Agent.contract_address == agent_data["contract_address"]).first()
        if not existing_agent:
            agent = Agent(user_id=user.id, **agent_data)
            db.add(agent)
            created_agents.append(agent)
        else:
            created_agents.append(existing_agent)
    db.commit()
    for agent in created_agents:
        db.refresh(agent)
    
    # 3. Create Services (simplified - just key ones)
    services_data = [
        {"name": "Momentum Strategy", "description": "Advanced momentum-based trading strategy with ML optimization",
         "service_type": "strategy", "contract_address": generate_mock_address(10),
         "provider_address": generate_mock_address(100), "price": Decimal("50.0"), "pricing_model": "pay_per_use",
         "rating": Decimal("4.5"), "call_count": 120},
        {"name": "Mean Reversion Bot", "description": "Statistical arbitrage bot using mean reversion principles",
         "service_type": "strategy", "contract_address": generate_mock_address(11),
         "provider_address": generate_mock_address(101), "price": Decimal("75.0"), "pricing_model": "pay_per_use",
         "rating": Decimal("4.2"), "call_count": 89},
        {"name": "Trend Following AI", "description": "AI-powered trend following system with adaptive parameters",
         "service_type": "strategy", "contract_address": generate_mock_address(12),
         "provider_address": generate_mock_address(102), "price": Decimal("100.0"), "pricing_model": "subscription",
         "rating": Decimal("4.8"), "call_count": 200},
        {"name": "Portfolio Risk Analyzer", "description": "Real-time portfolio risk assessment and VaR calculation",
         "service_type": "risk_control", "contract_address": generate_mock_address(20),
         "provider_address": generate_mock_address(110), "price": Decimal("30.0"), "pricing_model": "pay_per_use",
         "rating": Decimal("4.0"), "call_count": 150},
        {"name": "Stop Loss Manager", "description": "Dynamic stop-loss management with trailing stop functionality",
         "service_type": "risk_control", "contract_address": generate_mock_address(21),
         "provider_address": generate_mock_address(111), "price": Decimal("25.0"), "pricing_model": "pay_per_use",
         "rating": Decimal("4.3"), "call_count": 95},
        {"name": "Position Sizer", "description": "Optimal position sizing based on Kelly Criterion and risk tolerance",
         "service_type": "risk_control", "contract_address": generate_mock_address(22),
         "provider_address": generate_mock_address(112), "price": Decimal("40.0"), "pricing_model": "subscription",
         "rating": Decimal("4.6"), "call_count": 180},
        {"name": "Real-time Price Feed", "description": "High-frequency price data feed with sub-second latency",
         "service_type": "data_source", "contract_address": generate_mock_address(30),
         "provider_address": generate_mock_address(120), "price": Decimal("20.0"), "pricing_model": "subscription",
         "rating": Decimal("4.7"), "call_count": 300},
        {"name": "Market Sentiment API", "description": "Social media and news sentiment analysis for crypto markets",
         "service_type": "data_source", "contract_address": generate_mock_address(31),
         "provider_address": generate_mock_address(121), "price": Decimal("35.0"), "pricing_model": "pay_per_use",
         "rating": Decimal("4.1"), "call_count": 145},
        {"name": "On-chain Analytics", "description": "On-chain metrics including whale movements and exchange flows",
         "service_type": "data_source", "contract_address": generate_mock_address(32),
         "provider_address": generate_mock_address(122), "price": Decimal("45.0"), "pricing_model": "subscription",
         "rating": Decimal("4.4"), "call_count": 220},
        {"name": "Backtesting Engine", "description": "Historical backtesting engine with walk-forward optimization",
         "service_type": "other", "contract_address": generate_mock_address(40),
         "provider_address": generate_mock_address(130), "price": Decimal("60.0"), "pricing_model": "pay_per_use",
         "rating": Decimal("4.5"), "call_count": 75},
        {"name": "Performance Reporter", "description": "Automated performance reporting with PnL analysis and metrics",
         "service_type": "other", "contract_address": generate_mock_address(41),
         "provider_address": generate_mock_address(131), "price": Decimal("15.0"), "pricing_model": "subscription",
         "rating": Decimal("4.2"), "call_count": 110},
        {"name": "Alert System", "description": "Multi-channel alert system for trading signals and risk events",
         "service_type": "other", "contract_address": generate_mock_address(42),
         "provider_address": generate_mock_address(132), "price": Decimal("10.0"), "pricing_model": "subscription",
         "rating": Decimal("4.0"), "call_count": 250}
    ]
    
    created_services = []
    for service_data in services_data:
        existing_service = db.query(Service).filter(Service.contract_address == service_data["contract_address"]).first()
        if not existing_service:
            service = Service(**service_data, status="active")
            db.add(service)
            created_services.append(service)
        else:
            created_services.append(existing_service)
    db.commit()
    for service in created_services:
        db.refresh(service)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan events for startup and shutdown"""
    # Startup
    print("Starting x402 AI Agent Trading Platform API...")
    
    # Initialize database tables automatically
    try:
        print("Initializing database tables...")
        # This will create tables only if they don't exist
        Base.metadata.create_all(bind=engine)
        print("✅ Database tables initialized successfully!")
        print("   Tables: users, agents, services, transactions, payments")
        
        # Check and seed mock data if needed
        check_and_seed_mock_data()
    except Exception as e:
        print(f"⚠️  Warning: Could not initialize database tables: {e}")
        print("   You may need to run 'python init_db.py' manually")
    
    yield
    
    # Shutdown
    print("Shutting down API...")


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    lifespan=lifespan
)

# CORS middleware
# Handle CORS origins - allow "*" for development or specific origins for production
cors_origins = settings.cors_origins_list
if cors_origins == ["*"] or (len(cors_origins) == 1 and cors_origins[0] == "*"):
    # Allow all origins (development only)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,  # Cannot use credentials with wildcard
        allow_methods=["*"],
        allow_headers=["*"],
    )
else:
    # Use configured origins
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
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

