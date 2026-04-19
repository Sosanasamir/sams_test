from fastapi import APIRouter

from fastapi import Depends

from sqlalchemy.orm import Session

from app.services.admin_service import get_pending_users

from app.services.admin_service import approve_user

from app.core.dependencies import get_current_admin , get_current_user

from app.core.dependencies import get_db

from app.schemas.course_schema import CourseCreate

from app.services.admin_service import create_course

from app.schemas.prerequisite_schema import PrerequisiteCreate

from app.services.prerequisite_service import add_prerequisite

from app.services.prerequisite_service import get_prerequisites

from app.services.prerequisite_service import delete_prerequisite

from app.services.admin_service import approve_enrollment

from app.services.admin_service import reject_enrollment

from app.services.admin_service import get_pending_enrollments

from app.schemas.admin_schema import EnrollmentApproval

router = APIRouter(

    prefix="/admin",

    tags=["Admin"]

)


@router.get("/pending-users")

def pending_users(

    db:Session = Depends(get_db),

    admin = Depends(get_current_admin)

):

    users = get_pending_users(db)

    result=[]

    for u in users:

        result.append({

            "user_id":u.user_id,

            "name":u.full_name,

            "email":u.email,

            "role":u.role

        })

    return result


@router.put("/approve/{user_id}")

def approve(

    user_id:int,

    db:Session = Depends(get_db),

    admin = Depends(get_current_admin)

):

    user = approve_user(

        user_id,

        db

    )

    return {

        "message":"User approved",

        "user_id":user.user_id

    }


@router.post("/create-course")

def create_new_course(

    data:CourseCreate,

    db:Session=Depends(get_db),

    current_admin=Depends(get_current_admin)

):

    course=create_course(

        data,

        db

    )

    return{

        "message":"Course created",

        "course_id":course.course_id,

        "course_name":course.course_name

    }



@router.post("/add-prerequisite")

def add_prerequisite_endpoint(

    data:PrerequisiteCreate,

    db:Session=Depends(get_db),

    admin=Depends(get_current_admin)

):

    prereq=add_prerequisite(

        data,

        db

    )


    return{

        "message":"Prerequisite added",

        "id":prereq.id

    }



@router.get("/course-prerequisites/{course_id}")

def course_prerequisites(

    course_id:int,

    db:Session=Depends(get_db),

    admin=Depends(get_current_admin)

):

    prereqs=get_prerequisites(

        course_id,

        db

    )


    result=[]


    for p in prereqs:

        result.append({

            "id":p.id,

            "course_id":p.course_id,

            "prerequisite_id":p.prerequisite_id

        })


    return result



@router.delete("/delete-prerequisite/{prereq_id}")

def delete_prereq(

    prereq_id:int,

    db:Session=Depends(get_db),

    admin=Depends(get_current_admin)

):

    delete_prerequisite(

        prereq_id,

        db

    )


    return{

        "message":"Prerequisite deleted"

    }




@router.get("/pending-enrollments")

def pending_enrollments(

    db:Session=Depends(get_db),

    admin=Depends(get_current_admin)

):

    enrollments=get_pending_enrollments(db)


    result=[]


    for e in enrollments:

        result.append({

            "enrollment_id":e.enrollment_id,

            "student_id":e.student_id,

            "course_id":e.course_id,

            "status":e.approval_status

        })


    return result




@router.post("/approve-enrollment")

def approve(

    data:EnrollmentApproval,

    db:Session=Depends(get_db),

    admin=Depends(get_current_admin)

):

    enrollment=approve_enrollment(

        data.enrollment_id,

        db

    )


    return{

        "message":"Enrollment approved",

        "enrollment_id":enrollment.enrollment_id

    }




@router.post("/reject-enrollment")

def reject(

    data:EnrollmentApproval,

    db:Session=Depends(get_db),

    admin=Depends(get_current_admin)

):

    reject_enrollment(

        data.enrollment_id,

        db

    )


    return{

        "message":"Enrollment rejected"

    }