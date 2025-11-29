"""Service model"""
from sqlalchemy import Column, String, Numeric, Integer, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from src.database import Base


class Service(Base):
    """Service model"""
    __tablename__ = "services"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    provider_address = Column(String, index=True, nullable=False)
    contract_address = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    description = Column(String)
    service_type = Column(String, nullable=False)  # strategy, risk_control, data_source, other
    price = Column(Numeric(36, 18), nullable=False)
    pricing_model = Column(String, default="pay_per_use")  # pay_per_use, subscription
    rating = Column(Numeric(3, 2), default=0)  # Average rating (0-5)
    call_count = Column(Integer, default=0)
    status = Column(String, default="active")  # active, paused, delisted
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    payments = relationship("Payment", back_populates="service")

    def __repr__(self):
        return f"<Service(id={self.id}, name={self.name}, contract_address={self.contract_address})>"

