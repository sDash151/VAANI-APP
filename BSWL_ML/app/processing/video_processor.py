import cv2
import numpy as np
from concurrent.futures import ThreadPoolExecutor
from .landmark_extractor import MediaPipeLandmarkExtractor
from .sequence_batcher import SequenceBatcher

class VideoProcessor:
    def __init__(self, config):
        self.frame_buffer = []
        self.executor = ThreadPoolExecutor(max_workers=4)
        self.landmark_extractor = MediaPipeLandmarkExtractor(
            min_detection_confidence=0.7,
            min_tracking_confidence=0.7,
            use_gpu=True
        )
        self.sequence_batcher = SequenceBatcher(
            sequence_length=config.sequence_length,
            overlap=config.sequence_overlap
        )
        self.config = config

    async def process_frame(self, frame):
        # Resize and convert color space
        frame = cv2.resize(frame, (self.config.frame_width, self.config.frame_height))
        
        # Submit for async processing
        future = self.executor.submit(self.landmark_extractor.process, frame)
        landmarks = future.result()
        
        # Add to sequence batcher
        sequence = self.sequence_batcher.add_landmarks(landmarks)
        return sequence

    def reset(self):
        self.sequence_batcher.reset()
