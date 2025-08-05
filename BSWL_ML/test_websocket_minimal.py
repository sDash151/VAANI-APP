#!/usr/bin/env python3
"""
Minimal FastAPI WebSocket Test
"""

from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI()

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.websocket("/ws/test")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    print("✅ WebSocket client connected")
    
    try:
        while True:
            data = await websocket.receive_text()
            print(f"📥 Received: {data}")
            
            if data == "ping":
                await websocket.send_json({"status": "pong", "message": "Connected"})
                print("🏓 Sent pong")
            else:
                await websocket.send_json({"message": f"Echo: {data}"})
                
    except Exception as e:
        print(f"❌ WebSocket error: {e}")

@app.get("/")
async def root():
    return {"message": "WebSocket test server"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001) 