import os
import numpy as np
from tqdm import tqdm

SOURCE_DIR = "E:/ALL PROJECTS/FINAL_YEAR_PROJECT_BACKUP/ASSETS/ISL_PROCESSED_VIDEO"
DEST_DIR = "E:/ALL PROJECTS/FINAL_YEAR_PROJECT_BACKUP/ASSETS/ISL_PROCESSED_VIDEO_160"
TARGET_FRAMES = 160
FEATURE_DIM = 1629


def process_sequence(arr, target_frames=TARGET_FRAMES, feature_dim=FEATURE_DIM):
    """
    Standardize a sequence to (target_frames, feature_dim) by center cropping or zero-padding.
    """
    if arr.shape[1] != feature_dim:
        raise ValueError(f"Feature dimension mismatch: {arr.shape[1]} != {feature_dim}")
    n_frames = arr.shape[0]
    if n_frames == target_frames:
        return arr
    elif n_frames > target_frames:
        # Center crop
        start = (n_frames - target_frames) // 2
        return arr[start:start+target_frames]
    else:
        # Zero pad at the end
        pad_width = ((0, target_frames - n_frames), (0, 0))
        return np.pad(arr, pad_width, mode='constant')


def process_file(src_path, dest_path):
    """
    Load, validate, process, and save a single .npy file.
    """
    try:
        arr = np.load(src_path)
        if not isinstance(arr, np.ndarray):
            print(f"❌ Not a numpy array: {src_path}")
            return False
        if arr.ndim != 2:
            print(f"❌ Not 2D: {src_path} | shape: {arr.shape}")
            return False
        if arr.shape[1] != FEATURE_DIM:
            print(f"❌ Feature dim wrong: {src_path} | shape: {arr.shape}")
            return False
        arr_std = process_sequence(arr)
        os.makedirs(os.path.dirname(dest_path), exist_ok=True)
        np.save(dest_path, arr_std)
        return True
    except Exception as e:
        print(f"🛑 Error processing {src_path}: {e}")
        return False


def main():
    """
    Walk SOURCE_DIR, process all .npy files, save to DEST_DIR, preserve structure.
    """
    npy_files = []
    for root, _, files in os.walk(SOURCE_DIR):
        for fname in files:
            if fname.endswith('.npy'):
                src_path = os.path.join(root, fname)
                rel_path = os.path.relpath(src_path, SOURCE_DIR)
                dest_path = os.path.join(DEST_DIR, rel_path)
                npy_files.append((src_path, dest_path))

    print(f"🔎 Found {len(npy_files)} .npy files to process.")
    success, fail = 0, 0
    for src_path, dest_path in tqdm(npy_files, desc="🚀 Processing .npy files", unit="file"):
        ok = process_file(src_path, dest_path)
        if ok:
            success += 1
        else:
            fail += 1
    print(f"\n✅ Done! {success} files processed successfully.")
    if fail:
        print(f"❌ {fail} files failed or were skipped.")


if __name__ == "__main__":
    main()
