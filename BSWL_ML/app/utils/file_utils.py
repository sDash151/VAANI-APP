import os
import tempfile
import cv2
import numpy as np
from app.core.config import settings

def save_upload_file(upload_file):
    try:
        suffix = os.path.splitext(upload_file.filename)[1]
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            content = upload_file.file.read()
            if len(content) > settings.max_video_size:
                raise ValueError("File size exceeds maximum limit")
            tmp.write(content)
            return tmp.name
    finally:
        upload_file.file.close()

def frames_to_video(frames, output_path, fps=30):
    if not frames:
        raise ValueError("No frames provided")
    
    height, width, _ = frames[0].shape
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
    
    for frame in frames:
        out.write(frame)
    out.release()
    return output_path

def extract_frames(video_path, max_frames=None):
    cap = cv2.VideoCapture(video_path)
    frames = []
    frame_count = 0
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
            
        frames.append(frame)
        frame_count += 1
        
        if max_frames and frame_count >= max_frames:
            break
    
    cap.release()
    return frames

def clean_temp_files(file_paths):
    for path in file_paths:
        try:
            if os.path.exists(path):
                os.unlink(path)
        except Exception as e:
            pass