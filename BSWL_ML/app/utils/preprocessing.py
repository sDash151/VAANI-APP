import cv2
import numpy as np

def preprocess(file_path):
    # Example: read image, resize, normalize
    img = cv2.imread(file_path)
    img = cv2.resize(img, (224, 224))
    img = img / 255.0
    img = np.transpose(img, (2, 0, 1))  # CHW
    img = np.expand_dims(img, 0)
    return img
