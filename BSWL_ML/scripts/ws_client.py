import asyncio
import websockets
import cv2
import base64

async def send_frames(uri):
    cap = cv2.VideoCapture(0)
    async with websockets.connect(uri) as websocket:
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            _, buffer = cv2.imencode('.jpg', frame)
            frame_b64 = base64.b64encode(buffer).decode('utf-8')
            await websocket.send(frame_b64)
            result = await websocket.recv()
            print("Prediction:", result)
    cap.release()

if __name__ == "__main__":
    asyncio.run(send_frames("ws://localhost:8000/ws/predict"))
