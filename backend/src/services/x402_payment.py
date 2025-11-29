"""x402 payment service"""
from typing import Dict, Any, Optional
from sqlalchemy.orm import Session

from src.services.blockchain import BlockchainService
from src.models.payment import Payment
from src.config import settings


class X402PaymentService:
    """Service for handling x402 payments"""
    
    def __init__(self):
        self.blockchain = BlockchainService()
    
    def verify_payment(
        self,
        payment_id: str,
        db: Session
    ) -> bool:
        """Verify x402 payment"""
        # Check if payment exists in database
        payment = db.query(Payment).filter(
            Payment.payment_id == payment_id
        ).first()
        
        if payment and payment.status == "confirmed":
            return True
        
        # Verify on-chain
        # This would require x402 handler ABI
        # For now, return True if payment exists
        return payment is not None
    
    def record_payment(
        self,
        payment_id: str,
        tx_hash: str,
        amount: str,
        payment_type: str,
        agent_id: Optional[str] = None,
        service_id: Optional[str] = None,
        db: Session = None
    ) -> Payment:
        """Record payment in database"""
        payment = Payment(
            payment_id=payment_id,
            tx_hash=tx_hash,
            amount=amount,
            payment_type=payment_type,
            agent_id=agent_id,
            service_id=service_id,
            status="pending"
        )
        
        db.add(payment)
        db.commit()
        db.refresh(payment)
        
        return payment
    
    def update_payment_status(
        self,
        payment_id: str,
        status: str,
        block_number: Optional[int] = None,
        db: Session = None
    ):
        """Update payment status"""
        payment = db.query(Payment).filter(
            Payment.payment_id == payment_id
        ).first()
        
        if payment:
            payment.status = status
            if block_number:
                payment.block_number = block_number
            db.commit()

