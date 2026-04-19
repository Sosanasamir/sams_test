from sqlalchemy.orm import Session
from fastapi import HTTPException

from app.models.user import User
from app.models.student import Student
from app.models.advisor import Advisor

from app.schemas.auth_schema import RegisterRequest

from app.core.security import hash_password


def register_user(data: RegisterRequest, db: Session):

    # Normalize code
    code = data.code.lower().strip()

    # Check email exists
    existing = db.query(User).filter(
        User.email == data.email
    ).first()

    if existing:

        raise HTTPException(
            status_code=400,
            detail="Email already registered"
        )

    # Map code → role
    role_map = {

        "st":"student",

        "ad":"admin",

        "do":"advisor"

    }

    if code not in role_map:

        raise HTTPException(
            status_code=400,
            detail="Invalid approval code"
        )

    role = role_map[code]

    # First admin auto approved
    is_active = False

    if role == "admin":

        admin_count = db.query(User).filter(
            User.role=="admin"
        ).count()

        if admin_count == 0:

            is_active = True

    # Hash password
    hashed = hash_password(data.password)

    # Create user
    new_user = User(

        full_name=data.full_name,

        email=data.email,

        password=hashed,

        role=role,

        is_active=is_active

    )

    db.add(new_user)

    db.flush()

    # Student profile
    if role == "student":

        student = Student(

            user_id=new_user.user_id,

            gpa=0

        )

        db.add(student)

    # Advisor profile
    if role == "advisor":

        advisor = Advisor(

            user_id=new_user.user_id

        )

        db.add(advisor)

    db.commit()

    db.refresh(new_user)

    return new_user

from fastapi import HTTPException

from app.core.security import verify_password

from app.core.security import create_access_token


def login_user(data, db):

    user = db.query(User).filter(

        User.email == data.email

    ).first()

    if not user:

        raise HTTPException(

            status_code=404,

            detail="User not found"

        )

    if not verify_password(

        data.password,

        user.password

    ):

        raise HTTPException(

            status_code=401,

            detail="Incorrect password"

        )

    if not user.is_active:

        raise HTTPException(

            status_code=403,

            detail="Account waiting admin approval"

        )

    token = create_access_token({

        "user_id":user.user_id,

        "role":user.role

    })

    return {

        "access_token":token,

        "token_type":"bearer",

        "role":user.role,

        "user_id":user.user_id

    }