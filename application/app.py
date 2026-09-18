import os

from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(
    title="Enterprise Hybrid Resilience Platform",
    version="1.0.0",
)

APP_ENVIRONMENT = os.getenv("APP_ENVIRONMENT", "dev")


@app.get("/")
def root():
    return {
        "application": "resilience-app",
        "environment": APP_ENVIRONMENT,
        "status": "running",
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
    }


Instrumentator().instrument(app).expose(app)
