import cv2
import numpy as np
import tempfile

def decode_and_preprocess(frame_bytes):
    # Convert bytes to numpy array
    nparr = np.frombuffer(frame_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    img = cv2.resize(img, (224, 224))
    img = img / 255.0
    img = np.transpose(img, (2, 0, 1))  # CHW
    img = np.expand_dims(img, 0)
    return img
