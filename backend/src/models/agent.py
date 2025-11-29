"""Agent model"""
from sqlalchemy import Column, String, Numeric, Boolean, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from src.database import Base


class Agent(Base):
    """Agent model"""
    __tablename__ = "agents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    contract_address = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    description = Column(String)
    balance = Column(Numeric(36, 18), default=0)
    status = Column(String, default="active")  # active, paused, insufficient_balance
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="agents")
    transactions = relationship("Transaction", back_populates="agent")

    def __repr__(self):
        return f"<Agent(id={self.id}, name={self.name}, contract_address={self.contract_address})>"

