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
      ├─ phrase1/
      │   ├─ 0/
      │   │   ├─ 0.npy … N.npy
      │   └─ 1/ …
      └─ phrase2/ …
    Each sequence folder (0–25) is one sample containing T .npy feature frames.
    """
    def __init__(self, root_dir):
        super().__init__()
        self.samples = []                # [(list_of_npy, label_idx), …]
        self.class_to_idx = {}

        for idx, class_name in enumerate(sorted(os.listdir(root_dir))):
            class_path = os.path.join(root_dir, class_name)
            if not os.path.isdir(class_path):
                continue
            self.class_to_idx[class_name] = idx

            for subfolder in os.listdir(class_path):
                subfolder_path = os.path.join(class_path, subfolder)
                if not os.path.isdir(subfolder_path):
                    continue
                # numeric sort: 0.npy … 25.npy
                npy_files = sorted(
                    [os.path.join(subfolder_path, f)
                     for f in os.listdir(subfolder_path)
                     if f.endswith(".npy")],
                    key=lambda f: int(os.path.splitext(os.path.basename(f))[0])
                )
                if npy_files:
                    self.samples.append((npy_files, idx))

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        npy_files, label = self.samples[idx]
        # memory‑map load to avoid full RAM blow‑up on large files
        seq = [torch.tensor(np.load(f, mmap_mode="r"), dtype=torch.float32)
               for f in npy_files]
        return torch.stack(seq), label


# ──────────────────────────────────────────────────────────────────────────────
# Collate function (variable‑length → padded batch)
# ──────────────────────────────────────────────────────────────────────────────
def collate_fn(batch):
    sequences, labels = zip(*batch)
    padded = pad_sequence(sequences, batch_first=True)        # (B, T, F)
    lengths = torch.tensor([seq.shape[0] for seq in sequences])
    return padded, lengths, torch.tensor(labels)


# ──────────────────────────────────────────────────────────────────────────────
# LSTM‑based classifier
# ──────────────────────────────────────────────────────────────────────────────
class LSTMClassifier(nn.Module):
    def __init__(self, input_dim, hidden_dim, num_classes,
                 num_layers=1, bidirectional=True, dropout_p=0.3):
        super().__init__()
        self.lstm = nn.LSTM(
            input_dim, hidden_dim, num_layers,
            batch_first=True, bidirectional=bidirectional
        )
        self.dropout = nn.Dropout(dropout_p)
        fc_in = hidden_dim * (2 if bidirectional else 1)
        self.fc = nn.Linear(fc_in, num_classes)
        self.bi = bidirectional

    def forward(self, x, lengths):
        packed = nn.utils.rnn.pack_padded_sequence(
            x, lengths.cpu(), batch_first=True, enforce_sorted=False
        )
        _, (hn, _) = self.lstm(packed)
        if self.bi:
            hn = torch.cat([hn[-2], hn[-1]], dim=1)
        else:
            hn = hn[-1]
        return self.fc(self.dropout(hn))


# ──────────────────────────────────────────────────────────────────────────────
# Training routine
# ──────────────────────────────────────────────────────────────────────────────
def train():
    root_dir   = r"E:/ALL PROJECTS/FINAL_YEAR_PROJECT_BACKUP/ASSETS/ISLPHRASES_VIDEO"
    batch_size = 8
    num_epochs = 50
    patience   = 5
    hidden_dim = 128
    dropout_p  = 0.3

    # ── dataset / split ───────────────────────────────────────────────────────
    dataset     = ISLPhraseDataset(root_dir)
    num_classes = len(dataset.class_to_idx)
    sample_seq, _ = dataset[0]               # inspect feature dim
    input_dim   = sample_seq.shape[1]

    idxs = np.random.permutation(len(dataset))
    split = int(0.8 * len(idxs))
    train_ds = torch.utils.data.Subset(dataset, idxs[:split])
    val_ds   = torch.utils.data.Subset(dataset, idxs[split:])

    train_loader = DataLoader(train_ds, batch_size, True,  collate_fn=collate_fn)
    val_loader   = DataLoader(val_ds,   batch_size, False, collate_fn=collate_fn)

    # ── model & helpers ───────────────────────────────────────────────────────
    device   = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model    = LSTMClassifier(input_dim, hidden_dim, num_classes,
                              bidirectional=True, dropout_p=dropout_p).to(device)
    crit     = nn.CrossEntropyLoss()
    optim_   = optim.Adam(model.parameters(), lr=1e-3)
    sched    = optim.lr_scheduler.ReduceLROnPlateau(optim_, "min", patience=2, factor=0.5)
    scaler   = torch.cuda.amp.GradScaler() if device.type == "cuda" else None

    best_val, best_state, best_opt = float("inf"), None, None
    no_improve = 0

    for epoch in range(1, num_epochs + 1):
        # ── training ──────────────────────────────────────────────────────────
        model.train()
        tloss, tcorrect, ttotal = 0.0, 0, 0
        for seq, length, label in tqdm(train_loader, desc=f"Train {epoch}"):
            seq, length, label = seq.to(device), length.to(device), label.to(device)
            optim_.zero_grad()
            if scaler:
                with torch.cuda.amp.autocast():
                    out = model(seq, length)
                    loss = crit(out, label)
                scaler.scale(loss).backward()
                scaler.step(optim_)
                scaler.update()
            else:
                out  = model(seq, length)
                loss = crit(out, label)
                loss.backward()
                optim_.step()

            tloss += loss.item()
            tcorrect += (out.argmax(1) == label).sum().item()
            ttotal   += label.size(0)

        tloss /= len(train_loader)
        tacc   = 100 * tcorrect / ttotal

        # ── validation ───────────────────────────────────────────────────────
        model.eval()
        vloss, vcorrect, vtotal = 0.0, 0, 0
        with torch.no_grad():
            for seq, length, label in tqdm(val_loader, desc=f"Val   {epoch}"):
                seq, length, label = seq.to(device), length.to(device), label.to(device)
                if scaler:
                    with torch.cuda.amp.autocast():
                        out  = model(seq, length)
                        loss = crit(out, label)
                else:
                    out  = model(seq, length)
                    loss = crit(out, label)
                vloss += loss.item()
                vcorrect += (out.argmax(1) == label).sum().item()
                vtotal   += label.size(0)

        vloss /= len(val_loader)
        vacc   = 100 * vcorrect / vtotal

        # ── scheduler + LR log ───────────────────────────────────────────────
        old_lr = optim_.param_groups[0]["lr"]
        sched.step(vloss)
        new_lr = optim_.param_groups[0]["lr"]
        if new_lr != old_lr:
            print(f"[Scheduler] LR reduced: {old_lr:.2e} → {new_lr:.2e}")

        print(f"Epoch {epoch} | TrainLoss {tloss:.4f} | TrainAcc {tacc:.2f}% "
              f"| ValLoss {vloss:.4f} | ValAcc {vacc:.2f}% | LR {new_lr:.2e}")

        # ── early‑stopping + checkpoint ──────────────────────────────────────
        if vloss < best_val:
            best_val, no_improve = vloss, 0
            best_state = copy.deepcopy(model.state_dict())
            best_opt   = copy.deepcopy(optim_.state_dict())
            os.makedirs("models", exist_ok=True)
            torch.save({"model": best_state, "optim": best_opt,
                        "epoch": epoch, "val_loss": best_val},
                       "models/isl_video_best.pt")
            print(f"[Checkpoint] Best model saved at epoch {epoch}")
        else:
            no_improve += 1
            if no_improve >= patience:
                print(f"[Early‑Stop] no val improvement in {patience} epochs.")
                break

   # ── export best model ──────────────────────────────────────────────────────
        model.load_state_dict(best_state)

# 1️⃣  TorchScript (works as is)
        scripted = torch.jit.script(model.cpu())
        scripted.save("models/isl_video_ts.pt")
        print("TorchScript model exported → models/isl_video_ts.pt")

# 2️⃣  ONNX-friendly wrapper (skips pack_padded_sequence)
        class ONNXWrapper(nn.Module):
            def __init__(self, lstm_model):
                super().__init__()
                self.lstm = lstm_model.lstm      # reuse trained weights
                self.dropout = lstm_model.dropout
                self.fc = lstm_model.fc
                self.bi = lstm_model.bi

            def forward(self, x, lengths):
                # 👇  DON’T pack; just run padded batch
                out, (hn, _) = self.lstm(x)
                if self.bi:
                    hn = torch.cat([hn[-2], hn[-1]], dim=1)
                else:
                    hn = hn[-1]
                return self.fc(self.dropout(hn))

        onnx_model = ONNXWrapper(model).cpu()

        max_seq = 32        # longest sequence length you padded to
        dummy_seq = torch.randn(1, max_seq, input_dim)
        dummy_len = torch.tensor([max_seq])

        torch.onnx.export(
            onnx_model,
            (dummy_seq, dummy_len),                    # (seq, lengths)
            "models/isl_video.onnx",
            input_names=["seq", "lengths"],
            output_names=["logits"],
            dynamic_axes={
                "seq":    {0: "batch", 1: "time"},
                "lengths": {0: "batch"},
                "logits": {0: "batch"}
            },
            opset_version=17,
            do_constant_folding=True
        )
        print("ONNX model exported → models/isl_video.onnx  (no pack_padded_sequence)")


if __name__ == "__main__":
    train()
