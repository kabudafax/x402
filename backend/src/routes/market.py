"""Market routes"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional

from src.database import get_db
from src.models.service import Service

router = APIRouter()


@router.get("/market/services")
async def get_market_services(
    service_type: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """Get services from market"""
    query = db.query(Service).filter(Service.status == "active")
    
    if service_type:
        query = query.filter(Service.service_type == service_type)
    
    services = query.order_by(Service.rating.desc()).offset(offset).limit(limit).all()
    
    return [
        {
            "id": str(s.id),
            "contract_address": s.contract_address,
            "name": s.name,
            "description": s.description,
            "service_type": s.service_type,
            "price": str(s.price),
            "rating": float(s.rating),
            "call_count": s.call_count,
            "provider_address": s.provider_address
        }
        for s in services
    ]


@router.get("/market/services/{service_id}")
async def get_market_service(service_id: str, db: Session = Depends(get_db)):
    """Get service details from market"""
    service = db.query(Service).filter(Service.id == service_id).first()
    
    if not service:
        raise HTTPException(status_code=404, detail="Service not found")
    
    return {
        "id": str(service.id),
        "contract_address": service.contract_address,
        "name": service.name,
        "description": service.description,
        "service_type": service.service_type,
        "price": str(service.price),
        "rating": float(service.rating),
        "call_count": service.call_count,
        "provider_address": service.provider_address,
        "pricing_model": service.pricing_model
    }

