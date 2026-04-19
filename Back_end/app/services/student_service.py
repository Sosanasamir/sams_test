from app.models.student import Student

from app.models.course import Course

from app.models.enrollment import Enrollment

from app.models.course_prerequisite import CoursePrerequisite

from app.services.gpa_service import calculate_gpa

from fastapi import HTTPException

def get_student(

    current_user,

    db

):

    student = db.query(

        Student

    ).filter(

        Student.user_id == current_user.user_id

    ).first()


    return student




def complete_student_profile(

    current_user,

    data,

    db

):

    student=db.query(

        Student

    ).filter(

        Student.user_id==current_user.user_id

    ).first()


    if not student:

        raise HTTPException(
            status_code= 400,

           detail= "Student not found")


    if not student.uni_id:

        student.uni_id=data.uni_id


    if data.department:

        student.department=data.department


    if data.level:

        student.level=data.level


    if data.phone:

        student.phone=data.phone


    db.commit()

    db.refresh(student)


    return student


def check_prerequisites(

    student_id,

    course_id,

    db

):

    prerequisites = db.query(

        CoursePrerequisite

    ).filter(

        CoursePrerequisite.course_id == course_id

    ).all()


    if not prerequisites:

        return True


    for p in prerequisites:

        passed = db.query(

            Enrollment

        ).filter(

            Enrollment.student_id == student_id,

            Enrollment.course_id == p.prerequisite_id,

            Enrollment.status == "passed"

        ).first()


        if not passed:

            return False


    return True




def enroll_course(

    current_user,

    data,

    db

):

    student = get_student(

        current_user,

        db

    )


    course = db.query(

        Course

    ).filter(

        Course.course_id == data.course_id

    ).first()


    if not course:

        raise HTTPException (
            status_code= 401,

            detail="Course not found"

        )


    existing = db.query(

        Enrollment

    ).filter(

        Enrollment.student_id == student.student_id,

        Enrollment.course_id == data.course_id

    ).first()


    if existing:

        raise HTTPException ( 
            status_code= 402,

            detail= "Already requested"

         )


    prerequisite_ok = check_prerequisites(

        student.student_id,

        data.course_id,

        db

    )


    if not prerequisite_ok:

        raise HTTPException(

    status_code=403,

    detail="Prerequisite not completed"

    )


    current_count = db.query(

        Enrollment

    ).filter(

        Enrollment.course_id == data.course_id,

        Enrollment.approval_status=="approved"

    ).count()


    if current_count >= course.capacity:

        raise HTTPException(
            status_code= 404,

            detail= "Course full"

        )


    enrollment = Enrollment(

        student_id=student.student_id,

        course_id=data.course_id,

        advisor_id=course.advisor_id,

        status="registered",

        approval_status="pending"

    )


    db.add(enrollment)

    db.commit()

    db.refresh(enrollment)


    return enrollment




def get_my_enrollments(

    current_user,

    db

):

    student = get_student(

        current_user,

        db

    )


    enrollments = db.query(

        Enrollment

    ).filter(

        Enrollment.student_id == student.student_id

    ).all()


    return enrollments




def get_my_approved_courses(

    current_user,

    db

):

    student = get_student(

        current_user,

        db

    )


    enrollments = db.query(

        Enrollment

    ).filter(

        Enrollment.student_id == student.student_id,

        Enrollment.approval_status=="approved"

    ).all()


    return enrollments




def student_dashboard(

    current_user,

    db

):

    student=db.query(

        Student

    ).filter(

        Student.user_id==current_user.user_id

    ).first()


    gpa_data=calculate_gpa(

        student.student_id,

        db

    )


    return{

        "current_gpa":gpa_data["gpa"],

        "completed_credits":gpa_data["total_credits"]

    }




def eligible_courses(

    current_user,

    db

):

    student=db.query(

        Student

    ).filter(

        Student.user_id==current_user.user_id

    ).first()


    passed=db.query(

        Enrollment.course_id

    ).filter(

        Enrollment.student_id==student.student_id,

        Enrollment.status=="passed"

    ).all()


    passed_ids=[p[0] for p in passed]


    courses=db.query(

        Course

    ).all()


    eligible=[]


    for course in courses:

        if course.course_id in passed_ids:

            continue


        prereqs=db.query(

            CoursePrerequisite

        ).filter(

            CoursePrerequisite.course_id==course.course_id

        ).all()


        prereq_ids=[p.prerequisite_id for p in prereqs]


        if not set(prereq_ids).issubset(set(passed_ids)):

            continue


        eligible.append({

            "course_id":course.course_id,

            "course_name":course.course_name,

            "credits":course.credit_hours

        })


    return eligible