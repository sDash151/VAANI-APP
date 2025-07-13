import cv2
import mediapipe as mp
import numpy as np
from app.core.config import settings

class MediaPipeLandmarkExtractor:
    def __init__(self, min_detection_confidence=0.5, min_tracking_confidence=0.5, use_gpu=False):
        self.mp_holistic = mp.solutions.holistic
        self.holistic = self.mp_holistic.Holistic(
            static_image_mode=False,
            model_complexity=2,
            smooth_landmarks=True,
            min_detection_confidence=min_detection_confidence,
            min_tracking_confidence=min_tracking_confidence
        )
        self.use_gpu = use_gpu
        self.landmark_indices = self._get_important_landmarks()
    
    def process(self, frame):
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.holistic.process(frame_rgb)
        return self._normalize_landmarks(results)
    
    def _normalize_landmarks(self, results):
        landmarks = []
        
        # Pose landmarks (25 points)
        if results.pose_landmarks:
            landmarks.extend(self._extract_key_landmarks(
                results.pose_landmarks.landmark, 
                self.landmark_indices['pose']
            ))
        else:
            landmarks.extend(np.zeros(len(self.landmark_indices['pose']) * 3))
        
        # Left hand (21 points)
        if results.left_hand_landmarks:
            landmarks.extend(self._extract_key_landmarks(
                results.left_hand_landmarks.landmark,
                range(21)  # All hand landmarks
            ))
        else:
            landmarks.extend(np.zeros(21 * 3))
        
        # Right hand (21 points)
        if results.right_hand_landmarks:
            landmarks.extend(self._extract_key_landmarks(
                results.right_hand_landmarks.landmark,
                range(21)  # All hand landmarks
            ))
        else:
            landmarks.extend(np.zeros(21 * 3))
        
        return np.array(landmarks).flatten()
    
    def _extract_key_landmarks(self, landmark_list, indices):
        return [
            (lm.x, lm.y, lm.z)
            for i, lm in enumerate(landmark_list)
            if i in indices
        ]
    
    def _get_important_landmarks(self):
        # Only include key pose landmarks to reduce dimensionality
        return {
            'pose': [0, 11, 12, 13, 14, 15, 16, 23, 24],  # Nose, shoulders, elbows, hips
            'face': [],  # Excluded for performance
            'hands': list(range(21))  # All hand landmarks
        }
    
    def __del__(self):
        self.holistic.close()