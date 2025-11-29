"""
Database initialization script
Run this script to initialize the database and create all tables.
"""
import sys
from decimal import Decimal
from sqlalchemy import create_engine
from src.database import Base, SessionLocal
from src.models import User, Agent, Service, Transaction, Payment
from src.config import settings


def generate_mock_address(index: int) -> str:
    """Generate a mock Ethereum address"""
    hex_part = hex(index)[2:].zfill(40)
    return f"0x{hex_part}"


def seed_mock_data(engine):
    """Seed database with mock data"""
    print("\n🌱 Seeding mock data...")
    
    db = SessionLocal()
    try:
        # Target wallet address
        target_wallet = "0x60a969a669db4837ffc9d96bb81668c87041f4a4"
        
        # 1. Create or get User
        user = db.query(User).filter(User.wallet_address == target_wallet).first()
        if not user:
            user = User(wallet_address=target_wallet)
            db.add(user)
            db.commit()
            db.refresh(user)
            print(f"  ✅ Created user: {target_wallet}")
        else:
            print(f"  ℹ️  User already exists: {target_wallet}")
        
        # 2. Create Agents
        agents_data = [
            {
                "name": "Alpha Trader",
                "description": "High-frequency trading agent specializing in momentum strategies",
                "contract_address": generate_mock_address(1),
                "balance": Decimal("1000.0"),
                "status": "active"
            },
            {
                "name": "Beta Strategy",
                "description": "Multi-strategy agent with risk-adjusted portfolio management",
                "contract_address": generate_mock_address(2),
                "balance": Decimal("500.0"),
                "status": "active"
            },
            {
                "name": "Gamma Risk Manager",
                "description": "Advanced risk control agent with dynamic position sizing",
                "contract_address": generate_mock_address(3),
                "balance": Decimal("200.0"),
                "status": "paused"
            },
            {
                "name": "Delta Analyzer",
                "description": "AI-powered market analysis agent with sentiment detection",
                "contract_address": generate_mock_address(4),
                "balance": Decimal("1500.0"),
                "status": "active"
            },
            {
                "name": "Epsilon Bot",
                "description": "Automated trading bot with low capital requirements",
                "contract_address": generate_mock_address(5),
                "balance": Decimal("10.0"),
                "status": "insufficient_balance"
            }
        ]
        
        created_agents = []
        for agent_data in agents_data:
            existing_agent = db.query(Agent).filter(
                Agent.contract_address == agent_data["contract_address"]
            ).first()
            
            if not existing_agent:
                agent = Agent(
                    user_id=user.id,
                    contract_address=agent_data["contract_address"],
                    name=agent_data["name"],
                    description=agent_data["description"],
                    balance=agent_data["balance"],
                    status=agent_data["status"]
                )
                db.add(agent)
                created_agents.append(agent)
                print(f"  ✅ Created agent: {agent_data['name']}")
            else:
                created_agents.append(existing_agent)
                print(f"  ℹ️  Agent already exists: {agent_data['name']}")
        
        db.commit()
        for agent in created_agents:
            db.refresh(agent)
        
        # 3. Create Services
        services_data = [
            # Strategy services
            {
                "name": "Momentum Strategy",
                "description": "Advanced momentum-based trading strategy with ML optimization",
                "service_type": "strategy",
                "contract_address": generate_mock_address(10),
                "provider_address": generate_mock_address(100),
                "price": Decimal("50.0"),
                "pricing_model": "pay_per_use",
                "rating": Decimal("4.5"),
                "call_count": 120
            },
            {
                "name": "Mean Reversion Bot",
                "description": "Statistical arbitrage bot using mean reversion principles",
                "service_type": "strategy",
                "contract_address": generate_mock_address(11),
                "provider_address": generate_mock_address(101),
                "price": Decimal("75.0"),
                "pricing_model": "pay_per_use",
                "rating": Decimal("4.2"),
                "call_count": 89
            },
            {
                "name": "Trend Following AI",
                "description": "AI-powered trend following system with adaptive parameters",
                "service_type": "strategy",
                "contract_address": generate_mock_address(12),
                "provider_address": generate_mock_address(102),
                "price": Decimal("100.0"),
                "pricing_model": "subscription",
                "rating": Decimal("4.8"),
                "call_count": 200
            },
            # Risk Control services
            {
                "name": "Portfolio Risk Analyzer",
                "description": "Real-time portfolio risk assessment and VaR calculation",
                "service_type": "risk_control",
                "contract_address": generate_mock_address(20),
                "provider_address": generate_mock_address(110),
                "price": Decimal("30.0"),
                "pricing_model": "pay_per_use",
                "rating": Decimal("4.0"),
                "call_count": 150
            },
            {
                "name": "Stop Loss Manager",
                "description": "Dynamic stop-loss management with trailing stop functionality",
                "service_type": "risk_control",
                "contract_address": generate_mock_address(21),
                "provider_address": generate_mock_address(111),
                "price": Decimal("25.0"),
                "pricing_model": "pay_per_use",
                "rating": Decimal("4.3"),
                "call_count": 95
            },
            {
                "name": "Position Sizer",
                "description": "Optimal position sizing based on Kelly Criterion and risk tolerance",
                "service_type": "risk_control",
                "contract_address": generate_mock_address(22),
                "provider_address": generate_mock_address(112),
                "price": Decimal("40.0"),
                "pricing_model": "subscription",
                "rating": Decimal("4.6"),
                "call_count": 180
            },
            # Data Source services
            {
                "name": "Real-time Price Feed",
                "description": "High-frequency price data feed with sub-second latency",
                "service_type": "data_source",
                "contract_address": generate_mock_address(30),
                "provider_address": generate_mock_address(120),
                "price": Decimal("20.0"),
                "pricing_model": "subscription",
                "rating": Decimal("4.7"),
                "call_count": 300
            },
            {
                "name": "Market Sentiment API",
                "description": "Social media and news sentiment analysis for crypto markets",
                "service_type": "data_source",
                "contract_address": generate_mock_address(31),
                "provider_address": generate_mock_address(121),
                "price": Decimal("35.0"),
                "pricing_model": "pay_per_use",
                "rating": Decimal("4.1"),
                "call_count": 145
            },
            {
                "name": "On-chain Analytics",
                "description": "On-chain metrics including whale movements and exchange flows",
                "service_type": "data_source",
                "contract_address": generate_mock_address(32),
                "provider_address": generate_mock_address(122),
                "price": Decimal("45.0"),
                "pricing_model": "subscription",
                "rating": Decimal("4.4"),
                "call_count": 220
            },
            # Other services
            {
                "name": "Backtesting Engine",
                "description": "Historical backtesting engine with walk-forward optimization",
                "service_type": "other",
                "contract_address": generate_mock_address(40),
                "provider_address": generate_mock_address(130),
                "price": Decimal("60.0"),
                "pricing_model": "pay_per_use",
                "rating": Decimal("4.5"),
                "call_count": 75
            },
            {
                "name": "Performance Reporter",
                "description": "Automated performance reporting with PnL analysis and metrics",
                "service_type": "other",
                "contract_address": generate_mock_address(41),
                "provider_address": generate_mock_address(131),
                "price": Decimal("15.0"),
                "pricing_model": "subscription",
                "rating": Decimal("4.2"),
                "call_count": 110
            },
            {
                "name": "Alert System",
                "description": "Multi-channel alert system for trading signals and risk events",
                "service_type": "other",
                "contract_address": generate_mock_address(42),
                "provider_address": generate_mock_address(132),
                "price": Decimal("10.0"),
                "pricing_model": "subscription",
                "rating": Decimal("4.0"),
                "call_count": 250
            }
        ]
        
        created_services = []
        for service_data in services_data:
            existing_service = db.query(Service).filter(
                Service.contract_address == service_data["contract_address"]
            ).first()
            
            if not existing_service:
                service = Service(
                    provider_address=service_data["provider_address"],
                    contract_address=service_data["contract_address"],
                    name=service_data["name"],
                    description=service_data["description"],
                    service_type=service_data["service_type"],
                    price=service_data["price"],
                    pricing_model=service_data["pricing_model"],
                    rating=service_data["rating"],
                    call_count=service_data["call_count"],
                    status="active"
                )
                db.add(service)
                created_services.append(service)
                print(f"  ✅ Created service: {service_data['name']} ({service_data['service_type']})")
            else:
                created_services.append(existing_service)
                print(f"  ℹ️  Service already exists: {service_data['name']}")
        
        db.commit()
        for service in created_services:
            db.refresh(service)
        
        # 4. Create Transactions
        token_addresses = [
            generate_mock_address(200),  # Token A
            generate_mock_address(201),  # Token B
            generate_mock_address(202),  # Token C
        ]
        
        transaction_index = 0
        for agent in created_agents:
            # Create 2-3 transactions per agent
            num_transactions = 2 if agent.status == "paused" else 3
            
            for i in range(num_transactions):
                transaction_index += 1
                is_buy = i % 2 == 0
                tx_hash = f"0x{hex(transaction_index * 1000 + i)[2:].zfill(64)}"
                
                transaction = Transaction(
                    agent_id=agent.id,
                    tx_hash=tx_hash,
                    transaction_type="buy" if is_buy else "sell",
                    token_address=token_addresses[i % len(token_addresses)],
                    amount=Decimal(f"{100 + i * 50}.0"),
                    price=Decimal(f"{1.5 + i * 0.1}"),
                    status="success" if transaction_index % 3 != 0 else ("pending" if transaction_index % 3 == 1 else "failed"),
                    block_number=Decimal(f"{1000000 + transaction_index}")
                )
                db.add(transaction)
        
        db.commit()
        print(f"  ✅ Created {transaction_index} transactions")
        
        # 5. Create Payments
        payment_index = 0
        for agent in created_agents[:3]:  # Only for first 3 agents
            # Create 1-2 payments per agent
            num_payments = 1 if agent.status == "paused" else 2
            
            for i in range(num_payments):
                payment_index += 1
                service = created_services[payment_index % len(created_services)]
                payment_id = f"pay_{payment_index:06d}"
                tx_hash = f"0x{hex(payment_index * 2000 + i)[2:].zfill(64)}"
                
                payment = Payment(
                    agent_id=agent.id,
                    service_id=service.id,
                    tx_hash=tx_hash,
                    payment_id=payment_id,
                    amount=service.price,
                    payment_type="service_call" if i % 2 == 0 else "subscription",
                    status="confirmed" if payment_index % 2 == 0 else "pending",
                    block_number=Decimal(f"{2000000 + payment_index}")
                )
                db.add(payment)
        
        db.commit()
        print(f"  ✅ Created {payment_index} payments")
        
        print("\n✅ Mock data seeding completed successfully!")
        print(f"\nSummary:")
        print(f"  - 1 user")
        print(f"  - {len(created_agents)} agents")
        print(f"  - {len(created_services)} services")
        print(f"  - {transaction_index} transactions")
        print(f"  - {payment_index} payments")
        
    except Exception as e:
        print(f"❌ Error seeding mock data: {e}")
        db.rollback()
        raise
    finally:
        db.close()


def init_database():
    """Initialize database and create all tables"""
    print("Initializing database...")
    print(f"Database URL: {settings.DATABASE_URL.split('@')[-1] if '@' in settings.DATABASE_URL else 'local'}")
    
    # Create engine
    engine = create_engine(settings.DATABASE_URL)
    
    # Create all tables
    print("Creating tables...")
    Base.metadata.create_all(bind=engine)
    
    print("✅ Database initialized successfully!")
    print("\nTables created:")
    print("  - users")
    print("  - agents")
    print("  - services")
    print("  - transactions")
    print("  - payments")
    
    # Seed mock data
    try:
        seed_mock_data(engine)
    except Exception as e:
        print(f"⚠️  Warning: Could not seed mock data: {e}")
        print("   Database tables are created, but mock data was not inserted.")


if __name__ == "__main__":
    try:
        init_database()
    except Exception as e:
        print(f"❌ Error initializing database: {e}")
        sys.exit(1)

