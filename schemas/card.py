from pydantic import BaseModel
from typing import List
from .color import Color

class CardBase(BaseModel):
    name: str
    card_type: str
    description: str

class Card(CardBase):
    id: int
    colors: List[Color]

    class Config:
        from_attributes = True

class CardCreate(CardBase):
    colors: List[Color]

    class Config:
        from_attributes = True
