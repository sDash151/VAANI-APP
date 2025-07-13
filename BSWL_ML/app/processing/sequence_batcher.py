import numpy as np
from collections import deque

class SequenceBatcher:
    def __init__(self, sequence_length=30, overlap=5):
        self.sequence_length = sequence_length
        self.overlap = overlap
        self.sequences = []
        self.current_sequence = deque(maxlen=sequence_length + overlap)
    
    def add_landmarks(self, landmarks):
        self.current_sequence.append(landmarks)
        
        # Check if we have enough frames for a new sequence
        if len(self.current_sequence) >= self.sequence_length:
            start_idx = max(0, len(self.current_sequence) - self.sequence_length)
            sequence = list(self.current_sequence)[start_idx:start_idx + self.sequence_length]
            sequence_array = np.stack(sequence)
            self.sequences.append(sequence_array)
            
            # Remove overlapped frames
            if self.overlap > 0 and len(self.current_sequence) > self.sequence_length:
                self.current_sequence = deque(
                    list(self.current_sequence)[-self.sequence_length - self.overlap:],
                    maxlen=self.sequence_length + self.overlap
                )
            
            return sequence_array
        
        return None
    
    def get_latest_sequence(self):
        if len(self.current_sequence) >= self.sequence_length:
            return np.stack(list(self.current_sequence)[-self.sequence_length:])
        return None
    
    def reset(self):
        self.sequences = []
        self.current_sequence.clear()