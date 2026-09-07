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