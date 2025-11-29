"""Transaction model"""
from sqlalchemy import Column, String, Numeric, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from src.database import Base


class Transaction(Base):
    """Transaction model"""
    __tablename__ = "transactions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("agents.id"), nullable=False)
    tx_hash = Column(String, unique=True, index=True, nullable=False)
    transaction_type = Column(String, nullable=False)  # buy, sell
    token_address = Column(String, nullable=False)
    amount = Column(Numeric(36, 18), nullable=False)
    price = Column(Numeric(36, 18))
    status = Column(String, default="pending")  # pending, success, failed
    block_number = Column(Numeric(20, 0))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    agent = relationship("Agent", back_populates="transactions")

    def __repr__(self):
        return f"<Transaction(id={self.id}, tx_hash={self.tx_hash}, type={self.transaction_type})>"

