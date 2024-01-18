from pydantic import BaseModel,ConfigDict
from typing import List
from .color import Color

class CardBase(BaseModel):
    name: str
    card_type: str
    description: str

class Card(CardBase):
    model_config = ConfigDict(from_attributes=True)
    id: int
    colors: List[Color]

class CardCreate(CardBase):
    model_config = ConfigDict(from_attributes=True)

    colors: List[Color]

