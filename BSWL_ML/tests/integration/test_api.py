import pytest
import numpy as np
from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_video_processing(tmp_path):
    # Create a sample video file
    video_path = tmp_path / "test.mp4"
    create_sample_video(video_path)
    
    with open(video_path, "rb") as f:
        response = client.post(
            "/predict/video",
            files={"file": ("test.mp4", f, "video/mp4")}
        )
    
    assert response.status_code == 200
    data = response.json()
    assert "english" in data
    assert "hindi" in data
    assert "confidence" in data
    assert isinstance(data["confidence"], float)

def create_sample_video(path, duration=2, fps=30):
    import cv2
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(str(path), fourcc, fps, (640, 480))
    
    for _ in range(fps * duration):
        frame = np.zeros((480, 640, 3), dtype=np.uint8)
        out.write(frame)
    
    out.release()