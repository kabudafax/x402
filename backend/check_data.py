"""
Check if mock data exists in the database
"""
import sys
from sqlalchemy import create_engine, text
from src.database import SessionLocal
from src.models import User, Agent, Service, Transaction, Payment
from src.config import settings

def check_data():
    """Check if mock data exists"""
    print("Checking database for mock data...")
    print(f"Database URL: {settings.DATABASE_URL.split('@')[-1] if '@' in settings.DATABASE_URL else 'local'}\n")
    
    db = SessionLocal()
    try:
        # Check users
        target_wallet = "0x60a969a669db4837ffc9d96bb81668c87041f4a4"
        user = db.query(User).filter(User.wallet_address == target_wallet).first()
        
        if user:
            print(f"✅ User found: {user.wallet_address}")
            print(f"   User ID: {user.id}")
            
            # Check agents
            agents = db.query(Agent).filter(Agent.user_id == user.id).all()
            print(f"\n✅ Found {len(agents)} agents:")
            for agent in agents:
                print(f"   - {agent.name} ({agent.contract_address[:20]}...) - Status: {agent.status}, Balance: {agent.balance}")
            
            # Check services
            services = db.query(Service).all()
            print(f"\n✅ Found {len(services)} services:")
            service_types = {}
            for service in services:
                service_types[service.service_type] = service_types.get(service.service_type, 0) + 1
            for stype, count in service_types.items():
                print(f"   - {stype}: {count}")
            
            # Check transactions
            transactions = db.query(Transaction).join(Agent).filter(Agent.user_id == user.id).all()
            print(f"\n✅ Found {len(transactions)} transactions for user's agents")
            
            # Check payments
            payments = db.query(Payment).join(Agent).filter(Agent.user_id == user.id).all()
            print(f"✅ Found {len(payments)} payments for user's agents")
            
        else:
            print(f"❌ User NOT found: {target_wallet}")
            print("\n💡 Solution: Run 'python init_db.py' to create mock data")
            
            # Check if any users exist
            all_users = db.query(User).all()
            print(f"\n   Total users in database: {len(all_users)}")
            if all_users:
                print("   Existing users:")
                for u in all_users[:5]:  # Show first 5
                    print(f"     - {u.wallet_address}")
        
        # Check total counts
        print(f"\n📊 Database Summary:")
        print(f"   Users: {db.query(User).count()}")
        print(f"   Agents: {db.query(Agent).count()}")
        print(f"   Services: {db.query(Service).count()}")
        print(f"   Transactions: {db.query(Transaction).count()}")
        print(f"   Payments: {db.query(Payment).count()}")
        
    except Exception as e:
        print(f"❌ Error checking database: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    try:
        check_data()
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

