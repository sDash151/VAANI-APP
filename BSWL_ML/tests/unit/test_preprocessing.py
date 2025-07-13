import cv2
import numpy as np
import pytest
from app.processing.landmark_extractor import MediaPipeLandmarkExtractor
from app.processing.sequence_batcher import SequenceBatcher

@pytest.fixture
def sample_frame():
    # Create a sample blank frame
    return np.zeros((480, 640, 3), dtype=np.uint8)

def test_landmark_extraction(sample_frame):
    extractor = MediaPipeLandmarkExtractor()
    landmarks = extractor.process(sample_frame)
    
    # Should return a fixed-size vector
    assert landmarks.shape == (75 * 3,)  # 75 landmarks * 3 coordinates
    
    # All zeros since no landmarks detected
    assert np.all(landmarks == 0)

def test_sequence_batching():
    batcher = SequenceBatcher(sequence_length=5, overlap=2)
    
    # Add 10 sets of landmarks
    for i in range(10):
        batcher.add_landmarks(np.array([i]))
        
    # Should return sequences: [0,1,2,3,4], [3,4,5,6,7], [6,7,8,9]
    sequences = batcher.sequences
    
    assert len(sequences) == 3
    assert sequences[0].tolist() == [0,1,2,3,4]
    assert sequences[1].tolist() == [3,4,5,6,7]
    assert sequences[2].tolist() == [6,7,8,9]

def test_batch_reset():
    batcher = SequenceBatcher(sequence_length=5)
    for i in range(3):
        batcher.add_landmarks(np.array([i]))
        
    batcher.reset()
    assert len(batcher.sequences) == 0
    assert batcher.current_sequence.size == 0