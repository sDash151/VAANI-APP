import os
import sys
import torch
import yaml
import argparse
import random
import numpy as np
import torch.nn as nn
import torch.optim as optim
from datetime import datetime
from tqdm import tqdm
from torch.utils.data import DataLoader
from isl_phrase_train import ISLPhraseDataset, collate_fn, LSTMClassifier

try:
    from torch.utils.tensorboard import SummaryWriter
except ImportError:
    SummaryWriter = None

def set_seed(seed=42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

def load_config(config_path=None):
    default_path = "../app/config.yaml"
    path = config_path if config_path is not None else default_path
    try:
        with open(path, 'r', encoding='utf-8') as f:
            cfg = yaml.safe_load(f)
        if not isinstance(cfg, dict):
            raise ValueError("YAML config did not decode to a dictionary.")
        return cfg
    except Exception as e:
        print(f"[ERROR] Could not load config.yaml: {e}\nPlease check for non-UTF-8 characters or YAML formatting errors.")
        sys.exit(1)

# CLI arguments
parser = argparse.ArgumentParser()
parser.add_argument('--config', type=str, default=None, help='Path to config.yaml')
parser.add_argument('--tensorboard', action='store_true', help='Enable TensorBoard logging (overrides config)')
args, _ = parser.parse_known_args()

config = load_config(args.config)

for k in ["train_data_path", "val_data_path"]:
    if k not in config or not config[k]:
        print(f"[ERROR] Config missing required key: {k}")
        sys.exit(1)
    if not os.path.exists(config[k]):
        print(f"[ERROR] Dataset path does not exist: {config[k]}")
        sys.exit(1)

BATCH_SIZE = config.get('batch_size', 32)
EPOCHS = config.get('epochs', 50)
LEARNING_RATE = config.get('learning_rate', 0.001)
HIDDEN_DIM = config.get('hidden_dim', 128)
DROPOUT_P = config.get('dropout_p', 0.3)
SEED = config.get('seed', 42)

train_data_path = config.get('train_data_path')
val_data_path = config.get('val_data_path')
torchscript_path = config.get('torchscript_path', 'models/isl_video_best.pt.ts')
checkpoint_dir = config.get('checkpoint_dir', 'checkpoints')
tensorboard_log_dir = config.get('tensorboard_log_dir', 'logs/tensorboard')
model_save_path = os.path.join(checkpoint_dir, 'best.pt')
TENSORBOARD = args.tensorboard or config.get('tensorboard', False)

os.makedirs(checkpoint_dir, exist_ok=True)

def train():
    set_seed(SEED)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    train_dataset = ISLPhraseDataset(train_data_path)
    val_dataset = ISLPhraseDataset(val_data_path)

    train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True, collate_fn=collate_fn)
    val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, collate_fn=collate_fn)

    sample_seq, _, _ = train_dataset[0]
    input_dim = sample_seq.shape[1]
    num_classes = len(train_dataset.class_to_idx)

    model = LSTMClassifier(input_dim=input_dim, hidden_dim=HIDDEN_DIM, num_classes=num_classes,
                           bidirectional=True, dropout_p=DROPOUT_P).to(device)

    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', patience=2, factor=0.5)
    scaler = torch.cuda.amp.GradScaler() if device.type == 'cuda' else None

    best_val = float('inf')
    best_state, best_opt = None, None
    patience = 5
    no_improve = 0

    if os.path.exists(model_save_path):
        print(f"[INFO] Fine-tuning from checkpoint: {model_save_path}")
        checkpoint = torch.load(model_save_path, map_location=device)
        prev_state = checkpoint['model']
        model_state = model.state_dict()
        loaded_state = {k: v for k, v in prev_state.items() if k in model_state and v.shape == model_state[k].shape}
        model_state.update(loaded_state)
        model.load_state_dict(model_state)
        try:
            optimizer.load_state_dict(checkpoint['optim'])
        except:
            print("[WARN] Optimizer state not loaded.")
        best_val = checkpoint.get('val_loss', float('inf'))
        best_state = model.state_dict()
        best_opt = optimizer.state_dict()

    writer = None
    if TENSORBOARD and SummaryWriter is not None:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        logdir = os.path.join(tensorboard_log_dir, f'isl_run_{timestamp}')
        os.makedirs(logdir, exist_ok=True)
        writer = SummaryWriter(log_dir=logdir)

    for epoch in range(1, EPOCHS+1):
        model.train()
        train_loss, tcorrect, ttotal = 0.0, 0, 0

        for inputs, lengths, labels in tqdm(train_loader, desc=f"Train {epoch}"):
            inputs, lengths, labels = inputs.to(device), lengths.to(device), labels.to(device)
            optimizer.zero_grad()
            if scaler:
                with torch.cuda.amp.autocast():
                    outputs = model(inputs, lengths)
                    loss = criterion(outputs, labels)
                scaler.scale(loss).backward()
                scaler.step(optimizer)
                scaler.update()
            else:
                outputs = model(inputs, lengths)
                loss = criterion(outputs, labels)
                loss.backward()
                optimizer.step()

            train_loss += loss.item()
            tcorrect += (outputs.argmax(1) == labels).sum().item()
            ttotal += labels.size(0)

        train_loss /= len(train_loader)
        train_acc = 100 * tcorrect / ttotal

        model.eval()
        val_loss, vcorrect, vtotal = 0.0, 0, 0
        with torch.no_grad():
            for inputs, lengths, labels in tqdm(val_loader, desc=f"Val   {epoch}"):
                inputs, lengths, labels = inputs.to(device), lengths.to(device), labels.to(device)
                if scaler:
                    with torch.cuda.amp.autocast():
                        outputs = model(inputs, lengths)
                        loss = criterion(outputs, labels)
                else:
                    outputs = model(inputs, lengths)
                    loss = criterion(outputs, labels)
                val_loss += loss.item()
                vcorrect += (outputs.argmax(1) == labels).sum().item()
                vtotal += labels.size(0)

        val_loss /= len(val_loader)
        val_acc = 100 * vcorrect / vtotal
        scheduler.step(val_loss)

        if writer:
            writer.add_scalar('Loss/train', train_loss, epoch)
            writer.add_scalar('Loss/val', val_loss, epoch)
            writer.add_scalar('Accuracy/train', train_acc, epoch)
            writer.add_scalar('Accuracy/val', val_acc, epoch)

        print(f"Epoch {epoch} | TrainLoss {train_loss:.4f} | TrainAcc {train_acc:.2f}% "
              f"| ValLoss {val_loss:.4f} | ValAcc {val_acc:.2f}% | LR {optimizer.param_groups[0]['lr']:.2e}")

        if val_loss < best_val:
            best_val, no_improve = val_loss, 0
            best_state = model.state_dict()
            best_opt = optimizer.state_dict()
            torch.save({
                'model': best_state,
                'optim': best_opt,
                'epoch': epoch,
                'val_loss': best_val
            }, model_save_path)
            print(f"[Checkpoint] Best model saved at epoch {epoch}")
        else:
            no_improve += 1
            if no_improve >= patience:
                print(f"[Early-Stop] no improvement in {patience} epochs.")
                break

    if writer:
        writer.close()

    model.load_state_dict(best_state)
    model_scripted = torch.jit.script(model.cpu())
    model_scripted.save(torchscript_path)
    print(f"TorchScript model exported → {torchscript_path}")

if __name__ == "__main__":
    train()
