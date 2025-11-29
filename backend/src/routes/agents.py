"""Agent routes"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, List

from src.database import get_db
from src.models.agent import Agent
from src.models.user import User

router = APIRouter()


class AgentCreate(BaseModel):
    user_wallet_address: str
    contract_address: str
    name: str
    description: Optional[str] = None


class AgentResponse(BaseModel):
    id: str
    user_id: str
    contract_address: str
    name: str
    description: Optional[str]
    balance: str
    status: str
    created_at: str

    class Config:
        from_attributes = True


@router.post("/agents", response_model=AgentResponse)
async def create_agent(agent_data: AgentCreate, db: Session = Depends(get_db)):
    """Create a new agent"""
    # Get or create user
    user = db.query(User).filter(
        User.wallet_address == agent_data.user_wallet_address
    ).first()
    
    if not user:
        user = User(wallet_address=agent_data.user_wallet_address)
        db.add(user)
        db.commit()
        db.refresh(user)
    
    # Check if agent already exists
    existing_agent = db.query(Agent).filter(
        Agent.contract_address == agent_data.contract_address
    ).first()
    
    if existing_agent:
        return AgentResponse(
            id=str(existing_agent.id),
            user_id=str(existing_agent.user_id),
            contract_address=existing_agent.contract_address,
            name=existing_agent.name,
            description=existing_agent.description,
            balance=str(existing_agent.balance),
            status=existing_agent.status,
            created_at=existing_agent.created_at.isoformat()
        )
    
    # Create new agent
    new_agent = Agent(
        user_id=user.id,
        contract_address=agent_data.contract_address,
        name=agent_data.name,
        description=agent_data.description
    )
    db.add(new_agent)
    db.commit()
    db.refresh(new_agent)
    
    return AgentResponse(
        id=str(new_agent.id),
        user_id=str(new_agent.user_id),
        contract_address=new_agent.contract_address,
        name=new_agent.name,
        description=new_agent.description,
        balance=str(new_agent.balance),
        status=new_agent.status,
        created_at=new_agent.created_at.isoformat()
    )


@router.get("/agents/{agent_id}", response_model=AgentResponse)
async def get_agent(agent_id: str, db: Session = Depends(get_db)):
    """Get agent by ID"""
    agent = db.query(Agent).filter(Agent.id == agent_id).first()
    
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    
    return AgentResponse(
        id=str(agent.id),
        user_id=str(agent.user_id),
        contract_address=agent.contract_address,
        name=agent.name,
        description=agent.description,
        balance=str(agent.balance),
        status=agent.status,
        created_at=agent.created_at.isoformat()
    )


@router.get("/agents/{agent_id}/transactions")
async def get_agent_transactions(agent_id: str, db: Session = Depends(get_db)):
    """Get agent transactions"""
    agent = db.query(Agent).filter(Agent.id == agent_id).first()
    
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    
    return [
        {
            "id": str(tx.id),
            "tx_hash": tx.tx_hash,
            "transaction_type": tx.transaction_type,
            "amount": str(tx.amount),
            "status": tx.status,
            "created_at": tx.created_at.isoformat()
        }
        for tx in agent.transactions
    ]


@router.get("/agents/{agent_id}/stats")
async def get_agent_stats(agent_id: str, db: Session = Depends(get_db)):
    """Get agent statistics"""
    agent = db.query(Agent).filter(Agent.id == agent_id).first()
    
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    
    transactions = agent.transactions
    total_trades = len(transactions)
    successful_trades = len([t for t in transactions if t.status == "success"])
    
    return {
        "total_trades": total_trades,
        "successful_trades": successful_trades,
        "balance": str(agent.balance),
        "status": agent.status
    }

