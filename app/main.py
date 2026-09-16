import os

from fastapi import FastAPI

app = FastAPI(
    title="Azure Platform Lab API",
    version="0.1.0",
)


@app.get("/health", tags=["health"])
def health() -> dict[str, str]:
    """Report whether the application process is running."""
    return {"status": "healthy"}


@app.get("/ready", tags=["health"])
def readiness() -> dict[str, str]:
    """Report whether the application is ready to receive traffic."""
    return {"status": "ready"}


@app.get("/info", tags=["info"])
def info() -> dict[str, str]:
    """Report the injected configuration and the pod serving the request."""
    return {
        "environment": os.getenv("ENVIRONMENT", "unset"),
        "log_level": os.getenv("LOG_LEVEL", "unset"),
        "release": os.getenv("RELEASE", "unset"),
        "pod": os.getenv("POD_NAME", "unset"),
    }
