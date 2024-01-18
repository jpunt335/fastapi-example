from fastapi import FastAPI
from fastapi.testclient import TestClient
import logging 
import pytest

from server import app
from database import init_db
from models.base import Base

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = "sqlite:///./mtg_cards.db"  # SQLite database
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})

client = TestClient(app)

@pytest.fixture()
def test_db():
    Base.metadata.create_all(bind=engine)
    init_db()
    yield
    Base.metadata.drop_all(bind=engine)
    
def test_read_main(test_db):
    response = client.get("/cards/")
    assert response.status_code == 200
    assert response.json() == [
        {'card_type': 'Instant',
         'colors': [{'id': 1,
                     'name': 'Red'}],
         'description': 'Deals damage',
         'id': 1,
         'name': 'Fireball'},
        {'card_type': 'Instant',
         'colors': [{'id': 2,
                     'name': 'Blue'}],
         'description': 'Counters a spell',
         'id': 2,
         'name': 'Counterspell'}
    ]

def test_card_id(test_db):
    response = client.get("/cards/1")
    assert response.status_code == 200
    assert response.json() == {'card_type': 'Instant',
                               'colors': [{'id': 1, 'name': 'Red'}],
                               'description': 'Deals damage',
                               'id': 1,
                               'name': 'Fireball'}

def test_create_card(test_db):
    response = client.post("/cards", json={'card_type': 'Sorcery',
                                           'colors': [{'id':2, 'name':'Blue'}],
                                           'description': 'If you smell what The Rock has cooking!',
                                           'name': 'The Rock'})
    print(response.json())
    assert response.status_code == 201

def test_not_found(test_db):
    response = client.get("/cards/2666")
    assert response.status_code == 404
    
