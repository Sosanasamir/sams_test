from sqlalchemy.orm import Session

from app.models.user import User

from fastapi import HTTPException

from app.models.course import Course

from app.models.advisor import Advisor

from app.services.notification_service import create_notification

from app.models.student import Student

def get_pending_users(db:Session):

    users = db.query(User).filter(

        User.is_active == False

    ).all()

    return users


def approve_user(user_id:int,db:Session):

    user = db.query(User).filter(

        User.user_id == user_id

    ).first()

    if not user:

        raise HTTPException(

            status_code=404,

            detail="User not found"

        )

    user.is_active = True

    db.commit()

    return user





def create_course(data,db):

    advisor = db.query(

        Advisor

    ).filter(

        Advisor.advisor_id == data.advisor_id

    ).first()

    if not advisor:

        raise HTTPException(
           status_code= 400,
            detail="Advisor not found"

        )


    course = Course(

        course_name = data.course_name,

        course_code = data.course_code,

        credit_hours = data.credit_hours,

        department = data.department,

        level = data.level,

        semester = data.semester,

        year = data.year,

        advisor_id = data.advisor_id,

        capacity = data.capacity

    )

    db.add(course)

    db.commit()

    db.refresh(course)

    return course



from app.models.enrollment import Enrollment



def approve_enrollment(

    enrollment_id,

    db

):

    enrollment=db.query(

        Enrollment

    ).filter(

        Enrollment.enrollment_id==enrollment_id

    ).first()


    if not enrollment:

        raise HTTPException(

            status_code=404,

            detail="Enrollment not found"

        )


    enrollment.approval_status="approved"


    student=db.query(

        Student

    ).filter(

        Student.student_id==enrollment.student_id

    ).first()


    if student:

        create_notification(

            student.user_id,

            "Enrollment Approved",

            "Your enrollment request has been approved",

            db,

            "enrollment"

        )


    db.commit()

    db.refresh(enrollment)


    return enrollment





def reject_enrollment(

    enrollment_id,

    db

):

    enrollment=db.query(

        Enrollment

    ).filter(

        Enrollment.enrollment_id==enrollment_id

    ).first()


    if not enrollment:

        raise HTTPException(

            status_code=404,

            detail="Enrollment not found"

        )


    enrollment.approval_status="rejected"


    student=db.query(

        Student

    ).filter(

        Student.student_id==enrollment.student_id

    ).first()


    if student:

        create_notification(

            student.user_id,

            "Enrollment Rejected",

            "Your enrollment request was rejected",

            db,

            "enrollment"

        )


    db.commit()

    return True



def get_pending_enrollments(

    db

):

    enrollments=db.query(

        Enrollment

    ).filter(

        Enrollment.approval_status=="pending"

    ).all()


    return enrollments