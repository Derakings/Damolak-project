import logging
import os
import time

from fastapi import FastAPI

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger("app")

APP_VERSION = os.getenv("APP_VERSION", "dev")
ENVIRONMENT = os.getenv("ENVIRONMENT", "local")
START_TIME = time.time()

app = FastAPI(title="DevOps Challenge App")


@app.get("/")
def root():
    """Main endpoint. Returns version info (and pod name when running on EKS)."""
    logger.info("root endpoint called")
    return {
        "message": "Hello from the DevOps Challenge app from Damolak(v2)",
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
        "hostname": os.getenv("HOSTNAME", "unknown"),
    }


@app.get("/info")
def info():
    """Runtime details: which pod answered and how long it has been running."""
    return {
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
        "hostname": os.getenv("HOSTNAME", "unknown"),
        "uptime_seconds": int(time.time() - START_TIME),
    }


@app.get("/health")
def health():
    """Health check used by Docker and Kubernetes liveness/readiness probes."""
    return {"status": "ok"}