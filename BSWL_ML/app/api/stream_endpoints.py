from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from app.models.isl_model import ISLModel
from app.utils.video_stream import decode_and_preprocess
import numpy as np
import base64

router = APIRouter()
model = ISLModel()

@router.websocket("/ws/predict")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            # Expecting base64-encoded image frame
            frame_bytes = base64.b64decode(data)
            frame = decode_and_preprocess(frame_bytes)
            result = model.predict(frame)
            await websocket.send_json(result)
    except WebSocketDisconnect:
        pass
