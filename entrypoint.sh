#!/bin/bash

alembic upgrade head &&
	uvicorn server:app --host=0.0.0.0
