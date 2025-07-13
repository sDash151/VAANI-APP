import os
import numpy as np
import torch
from torch.utils.data import Dataset, DataLoader
from app.core.config import settings
from app.utils import device_utils

class ISLDataset(Dataset):
    def __init__(self, data_dir, transform=None, mode='train'):
        self.data_dir = data_dir
        self.transform = transform
        self.mode = mode
        self.samples = self._load_samples()
        self.device = device_utils.get_device()

    def _load_samples(self):
        samples = []
        class_dirs = [d for d in os.listdir(self.data_dir) 
                     if os.path.isdir(os.path.join(self.data_dir, d))]
        
        for class_idx, class_dir in enumerate(class_dirs):
            class_path = os.path.join(self.data_dir, class_dir)
            sequences = [f for f in os.listdir(class_path) 
                        if f.endswith('.npy')]
            
            for seq_file in sequences:
                samples.append({
                    'path': os.path.join(class_path, seq_file),
                    'label': class_idx
                })
                
        return samples

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        sample = self.samples[idx]
        sequence = np.load(sample['path'])
        label = sample['label']
        
        if self.transform:
            sequence = self.transform(sequence)
            
        # Pad sequences to fixed length
        sequence = self._pad_sequence(sequence, settings.sequence_length)
        
        return (
            torch.tensor(sequence, dtype=torch.float32).to(self.device),
            torch.tensor(label, dtype=torch.long).to(self.device)
        )
    
    def _pad_sequence(self, sequence, target_length):
        if len(sequence) > target_length:
            return sequence[:target_length]
        
        padded = np.zeros((target_length, sequence.shape[1]))
        padded[:len(sequence)] = sequence
        return padded