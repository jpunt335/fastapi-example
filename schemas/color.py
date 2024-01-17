from pydantic import BaseModel

class ColorBase(BaseModel):
    name: str

class Color(ColorBase):
    id: int

    class Config:
        from_attributes = True
