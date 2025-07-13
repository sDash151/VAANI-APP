from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.api.endpoints import router as api_router
from app.api.stream_endpoints import router as ws_router
from app.core.config import settings
from app.core.logging import logger

app = FastAPI(
    title="ISL Translation Service",
    description="Real-time Indian Sign Language Translation API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url=None
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)
app.include_router(ws_router)

@app.on_event("startup")
async def startup_event():
    logger.info("Starting ISL Translation Service")
    logger.info(f"Using execution provider: {settings.execution_provider}")

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Shutting down ISL Translation Service")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)