from pydantic import BaseModel


class GradeAssign(BaseModel):

    enrollment_id:int

    grade:str