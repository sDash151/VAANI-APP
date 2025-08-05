import os
import shutil
import random
from pathlib import Path

def split_data(src_dir, out_dir, train_ratio=0.8, seed=42):
    random.seed(seed)
    src_dir = Path(src_dir)
    out_dir = Path(out_dir)
    train_dir = out_dir / 'train'
    val_dir = out_dir / 'val'
    train_dir.mkdir(parents=True, exist_ok=True)
    val_dir.mkdir(parents=True, exist_ok=True)

    for class_folder in src_dir.iterdir():
        if not class_folder.is_dir():
            continue
        files = list(class_folder.glob('*.npy'))
        if not files:
            continue
        random.shuffle(files)
        split_idx = int(len(files) * train_ratio)
        train_files = files[:split_idx]
        val_files = files[split_idx:]
        # Create class subfolders
        train_class_dir = train_dir / class_folder.name
        val_class_dir = val_dir / class_folder.name
        train_class_dir.mkdir(parents=True, exist_ok=True)
        val_class_dir.mkdir(parents=True, exist_ok=True)
        # Copy files
        for f in train_files:
            shutil.copy2(f, train_class_dir / f.name)
        for f in val_files:
            shutil.copy2(f, val_class_dir / f.name)
        print(f"Class {class_folder.name}: {len(train_files)} train, {len(val_files)} val")

if __name__ == "__main__":
    src = r"E:\ALL PROJECTS\FINAL_YEAR_PROJECT_BACKUP\ASSETS\ISL_PROCESSED_VIDEO_160"
    out = r"E:\ALL PROJECTS\FINAL_YEAR_PROJECT_BACKUP\ASSETS\ISL_PROCESSED_VIDEO_SPLIT"
    split_data(src, out, train_ratio=0.8)
    print("Done.")
