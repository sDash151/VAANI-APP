import os
import shutil
import random
from pathlib import Path

def flatten_and_split(src_dir, out_dir, train_ratio=0.8, seed=42):
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
        class_name = class_folder.name
        # Recursively collect all .npy files under this class
        npy_files = list(class_folder.glob('**/*.npy'))
        if not npy_files:
            print(f"[WARN] No .npy files found in {class_name}")
            continue
        random.shuffle(npy_files)
        split_idx = int(len(npy_files) * train_ratio)
        train_files = npy_files[:split_idx]
        val_files = npy_files[split_idx:]
        # Prepare output dirs
        train_class_dir = train_dir / class_name
        val_class_dir = val_dir / class_name
        train_class_dir.mkdir(parents=True, exist_ok=True)
        val_class_dir.mkdir(parents=True, exist_ok=True)
        # Copy files, handle name collisions
        def copy_files(files, dest_dir, split):
            for i, src_path in enumerate(files):
                # Use original subfolder and index to avoid collisions
                rel = src_path.relative_to(class_folder)
                base = rel.parent.as_posix().replace('/', '_')
                new_name = f"{base}_{src_path.stem}.npy" if base != '.' else f"{src_path.stem}.npy"
                dest_path = dest_dir / new_name
                # If file exists, add unique suffix
                count = 1
                while dest_path.exists():
                    dest_path = dest_dir / f"{new_name.rsplit('.',1)[0]}_{count}.npy"
                    count += 1
                shutil.copy2(src_path, dest_path)
            print(f"Class {class_name}: {len(files)} {split} files copied to {dest_dir}")
        copy_files(train_files, train_class_dir, 'train')
        copy_files(val_files, val_class_dir, 'val')

if __name__ == "__main__":
    src = r"E:/ALL PROJECTS/FINAL_YEAR_PROJECT_BACKUP/ASSETS/ISL_PROCESSED_VIDEO"
    out = r"E:/ALL PROJECTS/FINAL_YEAR_PROJECT_BACKUP/ASSETS/ISL_PROCESSED_VIDEO_SPLIT"
    flatten_and_split(src, out, train_ratio=0.8)
    print("Done.")
