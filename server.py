#!/usr/bin/env python3
from fastapi import FastAPI, HTTPException, Depends
from models.card import Card
from models.color import Color
from schemas.card import Card as CardSchema
from schemas.card import CardCreate as CardCreateSchema
from database import init_db, SessionLocal
from typing import List

# FastAPI app initialization
app = FastAPI()

@app.on_event("startup")
async def startup_event():
    init_db()
    

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

        
# Endpoint to retrieve all cards
@app.get("/cards/", response_model=List[CardSchema])
def read_cards(db=Depends(get_db)):
    cards = db.query(Card).all()
    return cards

# Endpoint to retrieve a specific card by ID
@app.get("/cards/{card_id}")
def read_card(card_id: int, db=Depends(get_db)):
    card = db.query(Card).filter(Card.id == card_id).first()
    if card is None:
        raise HTTPException(status_code=404, detail="Card not found")
    return card

@app.post("/cards/", response_model=CardSchema)
def create_card(card: CardCreateSchema, db = Depends(get_db)):
    db_card = Card(name=card.name,
                   card_type=card.card_type,
                   description=card.description)

    for color_data in card.colors:
        color = db.query(Color).filter(Color.name == color_data.name).first()  # Adjust if using color IDs
        if color:
            db_card.colors.append(color)

    db.add(db_card)
    db.commit()
    db.refresh(db_card)
    return db_card
