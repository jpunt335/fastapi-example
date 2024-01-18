from pydantic import BaseModel,ConfigDict

class ColorBase(BaseModel):
    name: str

class Color(ColorBase):
    model_config = ConfigDict(from_attributes=True)
    id: int

