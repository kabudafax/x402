"""Database configuration"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from src.config import settings

# For psycopg3, use postgresql+psycopg:// instead of postgresql://
# SQLAlchemy 2.0 automatically detects psycopg3 if installed
database_url = settings.DATABASE_URL
if database_url.startswith("postgresql://") and "psycopg" not in database_url:
    # Check if psycopg3 is installed, if so use psycopg driver
    try:
        import psycopg
        # Replace postgresql:// with postgresql+psycopg:// for psycopg3
        database_url = database_url.replace("postgresql://", "postgresql+psycopg://", 1)
    except ImportError:
        # psycopg3 not installed, use default (psycopg2)
        pass

engine = create_engine(database_url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

