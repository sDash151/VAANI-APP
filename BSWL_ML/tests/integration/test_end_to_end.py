import cv2
import requests
from app.utils.video_stream import frames_to_video

def test_video_inference():
    # Load sample ISL video
    cap = cv2.VideoCapture("tests/data/hello_isl.mp4")
    frames = []
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        frames.append(frame)
    
    # Convert to multipart payload
    files = {"file": ("test.mp4", frames_to_video(frames), "video/mp4")}
    
    # Send to service
    response = requests.post(
        "http://localhost:8000/predict/video",
        files=files,
        timeout=30
    )
    
    # Validate response
    assert response.status_code == 200
    result = response.json()
    assert "english" in result
    assert "hindi" in result
    assert "confidence" in result
    assert result["confidence"] > 0.8
    assert result["english"].lower() == "hello"