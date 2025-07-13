import numpy as np
import cv2

class ISLDataAugmenter:
    def __init__(self, augment_prob=0.5):
        self.augment_prob = augment_prob
        self.transformations = [
            self.time_warp,
            self.spatial_jitter,
            self.random_rotation,
            self.random_scaling,
            self.temporal_subsample
        ]

    def __call__(self, sequence):
        if np.random.rand() > self.augment_prob:
            return sequence
            
        transform = np.random.choice(self.transformations)
        return transform(sequence)

    def time_warp(self, sequence, warp_factor=0.1):
        seq_len = sequence.shape[0]
        warp_points = max(2, int(seq_len * warp_factor))
        indices = np.sort(np.random.choice(seq_len, warp_points, replace=False))
        new_seq = np.zeros_like(sequence)
        
        for i in range(1, len(indices)):
            start_idx = indices[i-1]
            end_idx = indices[i]
            segment = sequence[start_idx:end_idx]
            
            # Randomly stretch or compress segment
            new_length = max(1, int(len(segment) * np.random.uniform(0.8, 1.2)))
            warped_segment = cv2.resize(segment, (sequence.shape[1], new_length))
            
            new_seq = np.concatenate([new_seq, warped_segment])
            
        return new_seq[:seq_len]  # Ensure same length

    def spatial_jitter(self, sequence, sigma=0.01):
        jitter = np.random.normal(0, sigma, sequence.shape)
        return sequence + jitter

    # Additional augmentation methods...