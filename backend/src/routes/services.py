"""Service routes"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional

from src.database import get_db
from src.models.service import Service

router = APIRouter()


class ServiceCreate(BaseModel):
    provider_address: str
    contract_address: str
    name: str
    description: Optional[str] = None
    service_type: str
    price: str
    pricing_model: str = "pay_per_use"


class ServiceResponse(BaseModel):
    id: str
    provider_address: str
    contract_address: str
    name: str
    description: Optional[str]
    service_type: str
    price: str
    rating: str
    call_count: int
    status: str
    created_at: str

    class Config:
        from_attributes = True


@router.post("/services", response_model=ServiceResponse)
async def create_service(service_data: ServiceCreate, db: Session = Depends(get_db)):
    """Create a new service"""
    # Check if service already exists
    existing_service = db.query(Service).filter(
        Service.contract_address == service_data.contract_address
    ).first()
    
    if existing_service:
        return ServiceResponse(
            id=str(existing_service.id),
            provider_address=existing_service.provider_address,
            contract_address=existing_service.contract_address,
            name=existing_service.name,
            description=existing_service.description,
            service_type=existing_service.service_type,
            price=str(existing_service.price),
            rating=str(existing_service.rating),
            call_count=existing_service.call_count,
            status=existing_service.status,
            created_at=existing_service.created_at.isoformat()
        )
    
    # Create new service
    new_service = Service(
        provider_address=service_data.provider_address,
        contract_address=service_data.contract_address,
        name=service_data.name,
        description=service_data.description,
        service_type=service_data.service_type,
        price=service_data.price,
        pricing_model=service_data.pricing_model
    )
    db.add(new_service)
    db.commit()
    db.refresh(new_service)
    
    return ServiceResponse(
        id=str(new_service.id),
        provider_address=new_service.provider_address,
        contract_address=new_service.contract_address,
        name=new_service.name,
        description=new_service.description,
        service_type=new_service.service_type,
        price=str(new_service.price),
        rating=str(new_service.rating),
        call_count=new_service.call_count,
        status=new_service.status,
        created_at=new_service.created_at.isoformat()
    )


@router.get("/services", response_model=list[ServiceResponse])
async def get_services(
    service_type: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """Get services list"""
    query = db.query(Service).filter(Service.status == "active")
    
    if service_type:
        query = query.filter(Service.service_type == service_type)
    
    services = query.offset(offset).limit(limit).all()
    
    return [
        ServiceResponse(
            id=str(s.id),
            provider_address=s.provider_address,
            contract_address=s.contract_address,
            name=s.name,
            description=s.description,
            service_type=s.service_type,
            price=str(s.price),
            rating=str(s.rating),
            call_count=s.call_count,
            status=s.status,
            created_at=s.created_at.isoformat()
        )
        for s in services
    ]


@router.get("/services/{service_id}", response_model=ServiceResponse)
async def get_service(service_id: str, db: Session = Depends(get_db)):
    """Get service by ID"""
    service = db.query(Service).filter(Service.id == service_id).first()
    
    if not service:
        raise HTTPException(status_code=404, detail="Service not found")
    
    return ServiceResponse(
        id=str(service.id),
        provider_address=service.provider_address,
        contract_address=service.contract_address,
        name=service.name,
        description=service.description,
        service_type=service.service_type,
        price=str(service.price),
        rating=str(service.rating),
        call_count=service.call_count,
        status=service.status,
        created_at=service.created_at.isoformat()
    )

