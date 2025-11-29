"""Payment routes"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional

from src.database import get_db
from src.models.payment import Payment

router = APIRouter()


class PaymentResponse(BaseModel):
    id: str
    payment_id: str
    tx_hash: str
    amount: str
    payment_type: str
    status: str
    created_at: str

    class Config:
        from_attributes = True


@router.get("/payments", response_model=list[PaymentResponse])
async def get_payments(
    agent_id: Optional[str] = None,
    service_id: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """Get payments list"""
    query = db.query(Payment)
    
    if agent_id:
        query = query.filter(Payment.agent_id == agent_id)
    
    if service_id:
        query = query.filter(Payment.service_id == service_id)
    
    payments = query.order_by(Payment.created_at.desc()).offset(offset).limit(limit).all()
    
    return [
        PaymentResponse(
            id=str(p.id),
            payment_id=p.payment_id,
            tx_hash=p.tx_hash,
            amount=str(p.amount),
            payment_type=p.payment_type,
            status=p.status,
            created_at=p.created_at.isoformat()
        )
        for p in payments
    ]


@router.get("/payments/{payment_id}", response_model=PaymentResponse)
async def get_payment(payment_id: str, db: Session = Depends(get_db)):
    """Get payment by payment ID"""
    payment = db.query(Payment).filter(Payment.payment_id == payment_id).first()
    
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    return PaymentResponse(
        id=str(payment.id),
        payment_id=payment.payment_id,
        tx_hash=payment.tx_hash,
        amount=str(payment.amount),
        payment_type=payment.payment_type,
        status=payment.status,
        created_at=payment.created_at.isoformat()
    )

