import os
import numpy as np
from tqdm import tqdm
from collections import Counter

# ======== CONFIG ========
root_dir = "E:/ALL PROJECTS/FINAL_YEAR_PROJECT_BACKUP/ASSETS/ISL_PROCESSED_VIDEO_SPLIT"
# ========================

malformed_files = []
valid_files = 0
shape_counter = Counter()

def scan_dir(dir_path):
    global valid_files
    npy_files = []

    # Step 1: Collect all .npy file paths
    for root, _, files in os.walk(dir_path):
        for fname in files:
            if fname.endswith('.npy'):
                npy_files.append(os.path.join(root, fname))

    # Step 2: Scan and validate files
    for fpath in tqdm(npy_files, desc="📂 Scanning .npy files"):
        try:
            arr = np.load(fpath)

            # Check if it's a 2D NumPy array
            if not isinstance(arr, np.ndarray) or arr.ndim != 2:
                malformed_files.append((fpath, arr.shape))
            else:
                valid_files += 1
                shape_counter[arr.shape] += 1

        except Exception as e:
            malformed_files.append((fpath, str(e)))

# Run the scan
scan_dir(root_dir)

# ========== RESULTS ==========
print(f"\n✅ Valid 2D .npy files: {valid_files}")
print(f"❌ Malformed or unreadable files: {len(malformed_files)}")

# Shape distribution summary
print("\n📏 Shape Summary of valid files:")
for shape, count in shape_counter.items():
    print(f"  {shape}: {count} files")

# List malformed files
if malformed_files:
    print("\n🛑 List of malformed files:")
    for fpath, issue in malformed_files:
        print(f" - {fpath} | Issue: {issue}")
