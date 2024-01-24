import os

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from models.base import Base

# Database URL (Change this to your PostgreSQL connection string)
#SQLALCHEMY_DATABASE_URL = "postgresql://myuser:mypassword@localhost/mydatabase"
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./mtg_cards.db")  
engine = create_engine(SQLALCHEMY_DATABASE_URL)

# Create a session local class to interact with the database
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def init_db():
    # Import all your models here so that Base has them before creating the tables
    from models.card import Card
    from models.color import Color

    # Create all tables in the database
    Base.metadata.create_all(bind=engine)
    seed_db()

def seed_db():
    print("Seeding DB")
    from models.card import Card
    from models.color import Color

    db = SessionLocal()

    # Check if the tables are empty and seed data if they are
    if db.query(Card).count() == 0 and db.query(Color).count() == 0:
        # Seed colors
        colors = [
            Color(name='Red'),
            Color(name='Blue'),
            Color(name='Green'),
            Color(name='White'),
            Color(name='Black')
        ]
        db.add_all(colors)
        db.commit()

        # Seed cards
        red = db.query(Color).filter_by(name='Red').first()
        blue = db.query(Color).filter_by(name='Blue').first()
        # ... and so on for other colors ...

        cards = [
            Card(name='Fireball', card_type='Instant', description='Deals damage', colors=[red]),
            Card(name='Counterspell', card_type='Instant', description='Counters a spell', colors=[blue]),
            # Add more sample cards as needed
        ]
        db.add_all(cards)
        db.commit()

    db.close()

