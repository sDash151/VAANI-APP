import cv2
import mediapipe as mp
import numpy as np

class FrameProcessor:
    def __init__(self, max_sequence_length=30):
        self.mp_holistic = mp.solutions.holistic
        self.holistic = self.mp_holistic.Holistic(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        self.max_sequence_length = max_sequence_length
        self.sequence = []

    def extract_landmarks(self, frame):
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.holistic.process(frame_rgb)
        
        landmarks = []
        # Pose landmarks
        if results.pose_landmarks:
            landmarks.extend([(lm.x, lm.y, lm.z) for lm in results.pose_landmarks.landmark])
        
        # Left hand landmarks
        if results.left_hand_landmarks:
            landmarks.extend([(lm.x, lm.y, lm.z) for lm in results.left_hand_landmarks.landmark])
        
        # Right hand landmarks
        if results.right_hand_landmarks:
            landmarks.extend([(lm.x, lm.y, lm.z) for lm in results.right_hand_landmarks.landmark])
        
        return np.array(landmarks).flatten() if landmarks else np.zeros(75*3)  # 75 landmarks * 3 coordinates

    def process_frame(self, frame):
        landmarks = self.extract_landmarks(frame)
        self.sequence.append(landmarks)
        
        if len(self.sequence) > self.max_sequence_length:
            self.sequence = self.sequence[-self.max_sequence_length:]
        
        return np.array(self.sequence)

    def reset_sequence(self):
        self.sequence = []