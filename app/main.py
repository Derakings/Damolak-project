import logging
import os

from fastapi import FastAPI

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger("app")

APP_VERSION = os.getenv("APP_VERSION", "dev")
ENVIRONMENT = os.getenv("ENVIRONMENT", "local")

app = FastAPI(title="DevOps Challenge App")


@app.get("/")
def root():
    """Main endpoint. Returns version info (and pod name when running on EKS)."""
    logger.info("root endpoint called")
    return {
        "message": "Hello from the DevOps Challenge app",
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
        "hostname": os.getenv("HOSTNAME", "unknown"),
    }


@app.get("/health")
def health():
    """Health check used by Docker and Kubernetes liveness/readiness probes."""
    return {"status": "ok"}
