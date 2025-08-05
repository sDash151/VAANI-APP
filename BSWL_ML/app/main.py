from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.logging import logger
import uvicorn

app = FastAPI(
    title="ISL Translation Service",
    description="Real-time Indian Sign Language Translation API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url=None
)

# Global model instance
model_loader = None

# CORS Configuration - Critical for WebSocket connections
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,  # Required for WebSocket
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"]
)

# Import routers only when needed to avoid startup issues
from app.api.endpoints import router as api_router
from app.api.stream_endpoints import router as ws_router

app.include_router(api_router, prefix="/api/v1")
app.include_router(ws_router, prefix="/ws")

# Add a test endpoint to verify WebSocket route is registered
@app.get("/ws/test")
async def websocket_test():
    return {"message": "WebSocket endpoint is available at /ws/predict"}

# Add a direct WebSocket endpoint for testing
@app.websocket("/ws/direct")
async def direct_websocket(websocket: WebSocket):
    await websocket.accept()
    print("✅ Direct WebSocket connected")
    
    try:
        while True:
            data = await websocket.receive_text()
            print(f"📥 Direct WS received: {data}")
            
            if data == "ping":
                await websocket.send_json({"status": "pong", "message": "Direct connection works"})
                print("🏓 Direct WS sent pong")
            else:
                await websocket.send_json({"echo": data})
                
    except WebSocketDisconnect:
        print("🔌 Direct WebSocket disconnected")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "ISL Translation Service"}

@app.get("/status")
async def status_check():
    global model_loader
    try:
        if model_loader is None:
            return {
                "status": "operational",
                "service": "ISL Translation Service",
                "model_loaded": False,
                "error": "Model not loaded yet",
                "execution_provider": settings.execution_provider,
                "num_classes": settings.num_classes,
                "sequence_length": settings.sequence_length
            }
        return {
            "status": "operational",
            "service": "ISL Translation Service",
            "model_loaded": True,
            "execution_provider": settings.execution_provider,
            "num_classes": settings.num_classes,
            "sequence_length": settings.sequence_length
        }
    except Exception as e:
        return {
            "status": "operational",
            "service": "ISL Translation Service",
            "model_loaded": False,
            "error": str(e),
            "execution_provider": settings.execution_provider,
            "num_classes": settings.num_classes,
            "sequence_length": settings.sequence_length
        }

@app.on_event("startup")
async def startup_event():
    global model_loader
    logger.info("Starting ISL Translation Service")
    logger.info(f"Using execution provider: {settings.execution_provider}")
    
    try:
        # Load the model during startup
        from app.models.model_loader import ModelLoader
        model_loader = ModelLoader(
            model_path=settings.model_path,
            execution_provider=settings.execution_provider
        )
        logger.info("Model loaded successfully")
    except Exception as e:
        logger.error(f"Failed to load model: {e}")
        model_loader = None

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Shutting down ISL Translation Service")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")