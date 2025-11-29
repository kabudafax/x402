"""Payment model"""
from sqlalchemy import Column, String, Numeric, DateTime, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from src.database import Base


class Payment(Base):
    """Payment model"""
    __tablename__ = "payments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("agents.id"), nullable=True)
    service_id = Column(UUID(as_uuid=True), ForeignKey("services.id"), nullable=True)
    tx_hash = Column(String, unique=True, index=True, nullable=False)
    payment_id = Column(String, unique=True, index=True, nullable=False)  # x402 payment ID
    amount = Column(Numeric(36, 18), nullable=False)
    payment_type = Column(String, nullable=False)  # service_call, subscription
    status = Column(String, default="pending")  # pending, confirmed, failed
    block_number = Column(Numeric(20, 0))
    metadata = Column(JSON)  # Additional payment data
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    service = relationship("Service", back_populates="payments")

    def __repr__(self):
        return f"<Payment(id={self.id}, payment_id={self.payment_id}, amount={self.amount})>"

