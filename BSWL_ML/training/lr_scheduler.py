import torch
import math

class WarmupCosineDecayScheduler(torch.optim.lr_scheduler._LRScheduler):
    def __init__(self, optimizer, warmup_epochs, total_epochs, min_lr=1e-6):
        self.warmup_epochs = warmup_epochs
        self.total_epochs = total_epochs
        self.min_lr = min_lr
        super().__init__(optimizer)
        
    def get_lr(self):
        if self.last_epoch < self.warmup_epochs:
            # Linear warmup
            return [
                base_lr * (self.last_epoch + 1) / self.warmup_epochs
                for base_lr in self.base_lrs
            ]
        else:
            # Cosine decay
            progress = (self.last_epoch - self.warmup_epochs) / (
                self.total_epochs - self.warmup_epochs
            )
            cosine_decay = 0.5 * (1 + math.cos(math.pi * progress))
            return [
                self.min_lr + (base_lr - self.min_lr) * cosine_decay
                for base_lr in self.base_lrs
            ]

def create_scheduler(optimizer, config):
    scheduler_type = config.get('scheduler', 'cosine')
    
    if scheduler_type == 'plateau':
        return torch.optim.lr_scheduler.ReduceLROnPlateau(
            optimizer,
            mode='max',
            factor=0.5,
            patience=5,
            verbose=True
        )
    elif scheduler_type == 'cosine':
        return WarmupCosineDecayScheduler(
            optimizer,
            warmup_epochs=config.get('warmup_epochs', 5),
            total_epochs=config.get('total_epochs', 100),
            min_lr=config.get('min_lr', 1e-6)
        )
    else:
        return torch.optim.lr_scheduler.MultiStepLR(
            optimizer,
            milestones=config.get('milestones', [30, 60, 90]),
            gamma=config.get('gamma', 0.1)
        )