"""
Database initialization script
Run this script to initialize the database and create all tables.
"""
import sys
from sqlalchemy import create_engine
from src.database import Base
from src.models import User, Agent, Service, Transaction, Payment
from src.config import settings

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

if __name__ == "__main__":
    try:
        init_database()
    except Exception as e:
        print(f"❌ Error initializing database: {e}")
        sys.exit(1)

