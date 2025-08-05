#!/usr/bin/env python
import os
# ──────────────────────────────────────────────────────────────────────────────
# Mute TensorFlow C++ and Mediapipe logs before importing cv2/mediapipe
# ──────────────────────────────────────────────────────────────────────────────
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
try:
    from absl import logging as _absl_logging
    _absl_logging.set_verbosity(_absl_logging.ERROR)
except ImportError:
    pass

import cv2
import numpy as np
from tqdm import tqdm
import mediapipe as mp
from concurrent.futures import ProcessPoolExecutor, as_completed
import argparse

# Pre‑instantiate MediaPipe solutions once (avoids repeated init/teardown)
mp_hands_module = mp.solutions.hands
mp_pose_module  = mp.solutions.pose
mp_face_module  = mp.solutions.face_mesh

def extract_landmarks_from_video(video_path, frame_step=1, verbose=False):
    hands = mp_hands_module.Hands(static_image_mode=False)
    pose  = mp_pose_module.Pose(static_image_mode=False)
    face  = mp_face_module.FaceMesh(static_image_mode=False)
    cap   = cv2.VideoCapture(video_path)
    landmarks_seq = []
    frame_idx = 0

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            if frame_idx % frame_step != 0:
                frame_idx += 1
                continue

            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            res_h = hands.process(rgb)
            res_p = pose.process(rgb)
            res_f = face.process(rgb)

            frame_landmarks = []

            # Hands (up to 2 hands)
            if res_h.multi_hand_landmarks:
                for hand in res_h.multi_hand_landmarks:
                    frame_landmarks += [l.x for l in hand.landmark] + \
                                       [l.y for l in hand.landmark] + \
                                       [l.z for l in hand.landmark]
                # if only one hand, pad for the second
                if len(res_h.multi_hand_landmarks) == 1:
                    frame_landmarks += [0.0] * 21 * 3
            else:
                frame_landmarks += [0.0] * 21 * 3 * 2

            # Pose (33 landmarks)
            if res_p.pose_landmarks:
                frame_landmarks += [l.x for l in res_p.pose_landmarks.landmark] + \
                                   [l.y for l in res_p.pose_landmarks.landmark] + \
                                   [l.z for l in res_p.pose_landmarks.landmark]
            else:
                frame_landmarks += [0.0] * 33 * 3

            # Face (468 landmarks)
            if res_f.multi_face_landmarks:
                for face_landmarks in res_f.multi_face_landmarks:
                    frame_landmarks += [l.x for l in face_landmarks.landmark] + \
                                       [l.y for l in face_landmarks.landmark] + \
                                       [l.z for l in face_landmarks.landmark]
            else:
                frame_landmarks += [0.0] * 468 * 3

            landmarks_seq.append(np.array(frame_landmarks, dtype=np.float32))
            frame_idx += 1

        if verbose:
            print(f"[INFO] {video_path}: extracted {len(landmarks_seq)} frames")
    finally:
        cap.release()
        hands.close()
        pose.close()
        face.close()

    return landmarks_seq

def save_landmarks_sequence(landmarks_seq, output_dir, file_name, as_npz=False):
    os.makedirs(output_dir, exist_ok=True)
    # stack into (T, D); raises if shapes don't match
    sequence = np.vstack(landmarks_seq)

    # sanity check
    if sequence.ndim != 2 or sequence.shape[0] < 1:
        raise ValueError(f"Malformed sequence {file_name}: shape {sequence.shape}")

    out_path = os.path.join(output_dir, f"{file_name}.{'npz' if as_npz else 'npy'}")
    if as_npz:
        np.savez_compressed(out_path, sequence=sequence)
    else:
        np.save(out_path, sequence)

def preprocess_single_video(args):
    (class_name, video_file, class_path, out_class_path,
     idx, frame_step, skip_existing, as_npz, verbose) = args

    video_path = os.path.join(class_path, video_file)
    file_name  = str(idx)
    out_file   = os.path.join(out_class_path, f"{file_name}.{'npz' if as_npz else 'npy'}")

    if skip_existing and os.path.exists(out_file):
        if verbose:
            print(f"[SKIP] {video_path}")
        return (video_path, 'skipped', 0)

    try:
        seq = extract_landmarks_from_video(video_path, frame_step, verbose)
        if not seq:
            raise ValueError("no frames extracted")
        save_landmarks_sequence(seq, out_class_path, file_name, as_npz)
        return (video_path, 'success', len(seq))
    except Exception as e:
        return (video_path, 'error', str(e))

def preprocess_videos(raw_root, out_root, frame_step, skip_existing, as_npz, verbose, max_workers):
    os.makedirs(out_root, exist_ok=True)
    tasks = []

    for class_name in os.listdir(raw_root):
        class_path = os.path.join(raw_root, class_name)
        if not os.path.isdir(class_path):
            continue
        out_class = os.path.join(out_root, class_name)
        os.makedirs(out_class, exist_ok=True)

        videos = [f for f in os.listdir(class_path) if f.lower().endswith('.mp4')]
        for idx, vid in enumerate(videos):
            tasks.append((class_name, vid, class_path, out_class,
                          idx, frame_step, skip_existing, as_npz, verbose))

    with ProcessPoolExecutor(max_workers=max_workers) as exe:
        for path, status, info in tqdm(exe.map(preprocess_single_video, tasks),
                                       total=len(tasks), desc="Processing Videos"):
            if status == 'error':
                print(f"[ERROR] {path}: {info}")
            elif verbose and status == 'success':
                print(f"[OK]    {path} → {info} frames")

if __name__ == "__main__":
    parser = argparse.ArgumentParser("Video → Landmarks Preprocessing")
    parser.add_argument("--raw-root",      required=True, help="Root folder of per-class .mp4s")
    parser.add_argument("--out-root",      required=True, help="Output folder for .npy/.npz sequences")
    parser.add_argument("--frame-step",    type=int, default=1, help="Process every Nth frame")
    parser.add_argument("--skip-existing", action="store_true", help="Skip already-processed files")
    parser.add_argument("--as-npz",        action="store_true", help="Save sequences as .npz instead of multiple .npy")
    parser.add_argument("--verbose",       action="store_true", help="Verbose logging")
    parser.add_argument("--max-workers",   type=int, default=None, help="Parallel worker count")
    args = parser.parse_args()

    preprocess_videos(
        raw_root      = args.raw_root,
        out_root      = args.out_root,
        frame_step    = args.frame_step,
        skip_existing = args.skip_existing,
        as_npz        = args.as_npz,
        verbose       = args.verbose,
        max_workers   = args.max_workers
    )
