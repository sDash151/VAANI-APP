import os
import numpy as np
import torch
from torch.utils.data import Dataset, DataLoader
from torch.nn.utils.rnn import pad_sequence
import torch.nn as nn
import torch.optim as optim
import copy
from tqdm import tqdm

# ──────────────────────────────────────────────────────────────────────────────
# Dataset
# ──────────────────────────────────────────────────────────────────────────────
class ISLPhraseDataset(Dataset):
    """
    Folder structure expected:
    root/
      ├─ Hello/
      │   ├─ 0.npy, 1.npy, ...
      ├─ ThankYou/
      │   ├─ 0.npy, 1.npy, ...
      └─ ...
    Each subfolder is a class name, each .npy file is a sequence (T, D)
    """
    def __init__(self, root_dir):
        super().__init__()
        self.samples = []
        self.class_to_idx = {}

        class_names = sorted([d for d in os.listdir(root_dir) if os.path.isdir(os.path.join(root_dir, d))])
        self.class_to_idx = {name: idx for idx, name in enumerate(class_names)}

        for class_name in class_names:
            class_path = os.path.join(root_dir, class_name)
            for fname in os.listdir(class_path):
                if fname.endswith('.npy'):
                    fpath = os.path.join(class_path, fname)
                    try:
                        arr = np.load(fpath)
                        if not isinstance(arr, np.ndarray) or arr.ndim != 2:
                            continue
                        T, D = arr.shape
                        if T == 0 or D == 0:
                            continue
                    except Exception:
                        continue
                    self.samples.append((fpath, self.class_to_idx[class_name]))

        if not self.samples:
            raise RuntimeError(f"No valid .npy samples found in {root_dir}.")

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        fpath, label = self.samples[idx]
        arr = np.load(fpath)
        tensor = torch.tensor(arr, dtype=torch.float32)
        return tensor, tensor.shape[0], label

# ──────────────────────────────────────────────────────────────────────────────
# Collate function for padded batch
# ──────────────────────────────────────────────────────────────────────────────
def collate_fn(batch):
    sequences, lengths, labels = zip(*batch)
    padded = pad_sequence(sequences, batch_first=True)
    lengths = torch.tensor(lengths)
    return padded, lengths, torch.tensor(labels)

# ──────────────────────────────────────────────────────────────────────────────
# LSTM-based classifier
# ──────────────────────────────────────────────────────────────────────────────
class LSTMClassifier(nn.Module):
    def __init__(self, input_dim, hidden_dim, num_classes, num_layers=1, bidirectional=True, dropout_p=0.3):
        super().__init__()
        self.lstm = nn.LSTM(input_dim, hidden_dim, num_layers, batch_first=True, bidirectional=bidirectional)
        self.dropout = nn.Dropout(dropout_p)
        self.fc = nn.Linear(hidden_dim * (2 if bidirectional else 1), num_classes)
        self.bi = bidirectional

    def forward(self, x, lengths):
        packed = nn.utils.rnn.pack_padded_sequence(x, lengths.cpu(), batch_first=True, enforce_sorted=False)
        _, (hn, _) = self.lstm(packed)
        if self.bi:
            hn = torch.cat([hn[-2], hn[-1]], dim=1)
        else:
            hn = hn[-1]
        return self.fc(self.dropout(hn))

# ──────────────────────────────────────────────────────────────────────────────
# Training
# ──────────────────────────────────────────────────────────────────────────────
def train():
    root_dir = r"E:/ALL PROJECTS/FINAL_YEAR_PROJECT_BACKUP/ASSETS/ISL_PROCESSED_VIDEO_160"
    batch_size = 8
    num_epochs = 50
    patience = 5
    hidden_dim = 128
    dropout_p = 0.3

    # Load Dataset
    dataset = ISLPhraseDataset(root_dir)
    num_classes = len(dataset.class_to_idx)
    input_dim = np.load(dataset.samples[0][0]).shape[1]

    idxs = np.random.permutation(len(dataset))
    split = int(0.8 * len(idxs))
    train_ds = torch.utils.data.Subset(dataset, idxs[:split])
    val_ds = torch.utils.data.Subset(dataset, idxs[split:])

    train_loader = DataLoader(train_ds, batch_size, shuffle=True, collate_fn=collate_fn)
    val_loader = DataLoader(val_ds, batch_size, shuffle=False, collate_fn=collate_fn)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = LSTMClassifier(input_dim, hidden_dim, num_classes, bidirectional=True, dropout_p=dropout_p).to(device)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=1e-3)
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, "min", patience=2, factor=0.5)
    scaler = torch.cuda.amp.GradScaler() if device.type == "cuda" else None

    best_val_loss = float("inf")
    best_model_state = None
    best_opt_state = None
    no_improve = 0

    for epoch in range(1, num_epochs + 1):
        # Train
        model.train()
        total_loss, correct, total = 0, 0, 0
        for seqs, lengths, labels in tqdm(train_loader, desc=f"Train Epoch {epoch}"):
            seqs, lengths, labels = seqs.to(device), lengths.to(device), labels.to(device)
            optimizer.zero_grad()
            if scaler:
                with torch.cuda.amp.autocast():
                    outputs = model(seqs, lengths)
                    loss = criterion(outputs, labels)
                scaler.scale(loss).backward()
                scaler.step(optimizer)
                scaler.update()
            else:
                outputs = model(seqs, lengths)
                loss = criterion(outputs, labels)
                loss.backward()
                optimizer.step()

            total_loss += loss.item()
            correct += (outputs.argmax(1) == labels).sum().item()
            total += labels.size(0)

        avg_train_loss = total_loss / len(train_loader)
        train_acc = 100 * correct / total

        # Validate
        model.eval()
        val_loss, val_correct, val_total = 0, 0, 0
        with torch.no_grad():
            for seqs, lengths, labels in tqdm(val_loader, desc=f"Val Epoch {epoch}"):
                seqs, lengths, labels = seqs.to(device), lengths.to(device), labels.to(device)
                if scaler:
                    with torch.cuda.amp.autocast():
                        outputs = model(seqs, lengths)
                        loss = criterion(outputs, labels)
                else:
                    outputs = model(seqs, lengths)
                    loss = criterion(outputs, labels)

                val_loss += loss.item()
                val_correct += (outputs.argmax(1) == labels).sum().item()
                val_total += labels.size(0)

        avg_val_loss = val_loss / len(val_loader)
        val_acc = 100 * val_correct / val_total

        old_lr = optimizer.param_groups[0]["lr"]
        scheduler.step(avg_val_loss)
        new_lr = optimizer.param_groups[0]["lr"]
        if new_lr != old_lr:
            print(f"[Scheduler] LR reduced: {old_lr:.2e} → {new_lr:.2e}")

        print(f"Epoch {epoch} | Train Loss: {avg_train_loss:.4f} | Acc: {train_acc:.2f}% | "
              f"Val Loss: {avg_val_loss:.4f} | Acc: {val_acc:.2f}% | LR: {new_lr:.2e}")

        if avg_val_loss < best_val_loss:
            best_val_loss = avg_val_loss
            best_model_state = copy.deepcopy(model.state_dict())
            best_opt_state = copy.deepcopy(optimizer.state_dict())
            no_improve = 0
            os.makedirs("models", exist_ok=True)
            torch.save({
                "model": best_model_state,
                "optim": best_opt_state,
                "epoch": epoch,
                "val_loss": best_val_loss
            }, "models/isl_video_best.pt")
            print(f"[Checkpoint] Saved best model at epoch {epoch}")
        else:
            no_improve += 1
            if no_improve >= patience:
                print(f"[Early Stop] No improvement for {patience} epochs. Stopping.")
                break

    # Export TorchScript
    model.load_state_dict(best_model_state)
    scripted = torch.jit.script(model.cpu())
    scripted.save("models/isl_video_ts.pt")
    print("✅ TorchScript model saved → models/isl_video_ts.pt")

    # Export ONNX
    class ONNXWrapper(nn.Module):
        def __init__(self, lstm_model):
            super().__init__()
            self.lstm = lstm_model.lstm
            self.dropout = lstm_model.dropout
            self.fc = lstm_model.fc
            self.bi = lstm_model.bi

        def forward(self, x, lengths):
            packed = nn.utils.rnn.pack_padded_sequence(x, lengths.cpu(), batch_first=True, enforce_sorted=False)
            _, (hn, _) = self.lstm(packed)
            if self.bi:
                hn = torch.cat([hn[-2], hn[-1]], dim=1)
            else:
                hn = hn[-1]
            return self.fc(self.dropout(hn))

    onnx_model = ONNXWrapper(model).cpu()
    max_seq = 160
    dummy_seq = torch.randn(1, max_seq, input_dim)
    dummy_len = torch.tensor([max_seq])

    torch.onnx.export(
        onnx_model,
        (dummy_seq, dummy_len),
        "models/isl_video.onnx",
        input_names=["seq", "lengths"],
        output_names=["logits"],
        dynamic_axes={
            "seq": {0: "batch", 1: "time"},
            "lengths": {0: "batch"},
            "logits": {0: "batch"}
        },
        opset_version=17,
        do_constant_folding=True
    )
    print("✅ ONNX model exported → models/isl_video.onnx")

if __name__ == "__main__":
    train()
