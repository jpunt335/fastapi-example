from sqlalchemy import Column, Integer, String, Table, ForeignKey
from sqlalchemy.orm import relationship
from .base import Base

# Association table for many-to-many relationship
card_color_association = Table(
    'card_color_association',
    Base.metadata,
    Column('card_id', ForeignKey('cards.id'), primary_key=True),
    Column('color_id', ForeignKey('colors.id'), primary_key=True)
)

class Card(Base):
    __tablename__ = 'cards'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    card_type = Column(String)
    description = Column(String)
    colors = relationship("Color", secondary=card_color_association, backref="cards")
