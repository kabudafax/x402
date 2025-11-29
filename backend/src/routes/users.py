"""User routes"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel

from src.database import get_db
from src.models.user import User

router = APIRouter()


class UserCreate(BaseModel):
    wallet_address: str


class UserResponse(BaseModel):
    id: str
    wallet_address: str
    created_at: str

    class Config:
        from_attributes = True


@router.post("/users", response_model=UserResponse)
async def create_user(user_data: UserCreate, db: Session = Depends(get_db)):
    """Create a new user"""
    # Check if user already exists
    existing_user = db.query(User).filter(
        User.wallet_address == user_data.wallet_address
    ).first()
    
    if existing_user:
        return UserResponse(
            id=str(existing_user.id),
            wallet_address=existing_user.wallet_address,
            created_at=existing_user.created_at.isoformat()
        )
    
    # Create new user
    new_user = User(wallet_address=user_data.wallet_address)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return UserResponse(
        id=str(new_user.id),
        wallet_address=new_user.wallet_address,
        created_at=new_user.created_at.isoformat()
    )


@router.get("/users/{wallet_address}", response_model=UserResponse)
async def get_user(wallet_address: str, db: Session = Depends(get_db)):
    """Get user by wallet address"""
    user = db.query(User).filter(User.wallet_address == wallet_address).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserResponse(
        id=str(user.id),
        wallet_address=user.wallet_address,
        created_at=user.created_at.isoformat()
    )


@router.get("/users/{wallet_address}/agents")
async def get_user_agents(wallet_address: str, db: Session = Depends(get_db)):
    """Get all agents for a user"""
    user = db.query(User).filter(User.wallet_address == wallet_address).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return [{"id": str(agent.id), "name": agent.name, "contract_address": agent.contract_address} 
            for agent in user.agents]

