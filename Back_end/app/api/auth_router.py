from fastapi import APIRouter

from app.schemas.auth_schema import RegisterRequest

from app.schemas.auth_schema import LoginRequest

from app.services.auth_service import register_user

from app.services.auth_service import login_user

from app.db.database import SessionLocal


router = APIRouter(

    prefix="/auth",

    tags=["Authentication"]

)


@router.post("/register")

def register(data: RegisterRequest):

    db = SessionLocal()

    user = register_user(

        data,

        db

    )

    return {

        "message":"User registered successfully",

        "user_id":user.user_id,

        "role":user.role,

        "is_active":user.is_active

    }


@router.post("/login")

def login(data: LoginRequest):

    db = SessionLocal()

    result = login_user(

        data,

        db

    )

    return result