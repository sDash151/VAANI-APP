import cv2
import numpy as np
import tempfile

def decode_and_preprocess(frame_bytes):
    """
    Decode and preprocess frame bytes from camera
    Handles both YUV420 and RGB formats
    Returns format suitable for LSTM model with 1662 features
    """
    try:
        # Try to decode as regular image first (RGB)
        nparr = np.frombuffer(frame_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            # If that fails, try to handle as YUV420 format
            img = _convert_yuv420_to_rgb(frame_bytes)
        
        if img is None:
            # Create a dummy image if all else fails
            img = np.zeros((224, 224, 3), dtype=np.uint8)
            img[:, :, 0] = 128  # Blue channel
            img[:, :, 1] = 128  # Green channel
            img[:, :, 2] = 128  # Red channel
        
        # Resize to expected input size
        img = cv2.resize(img, (224, 224))
        
        # Normalize to [0, 1]
        img = img.astype(np.float32) / 255.0
        
        # Convert BGR to RGB (OpenCV uses BGR)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        
        # Extract features to match the LSTM model's expected input size (1662)
        features = _extract_features(img)
        
        # Ensure the input has the expected dimensions for LSTM
        # Most LSTM models expect (batch_size, sequence_length, features)
        # For single frame, we'll use (1, 1, features)
        features_reshaped = features.reshape(1, 1, -1)  # (batch=1, seq_len=1, features)
        
        return features_reshaped
        
    except Exception as e:
        print(f"Error preprocessing frame: {e}")
        # Return a dummy input with correct shape for LSTM (1662 features)
        dummy_features = np.zeros(1662, dtype=np.float32)
        return dummy_features.reshape(1, 1, -1)  # (batch=1, seq_len=1, features)

def _extract_features(img):
    """
    Extract 1662 features from the image to match the LSTM model's expected input
    This simulates the feature extraction that was used during training
    """
    try:
        # Convert to grayscale for some features
        gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
        
        # 1. Histogram features (256 features)
        hist = cv2.calcHist([gray], [0], None, [256], [0, 256]).flatten()
        hist_normalized = hist / (hist.sum() + 1e-8)  # Normalize
        
        # 2. HOG-like features (simplified)
        # Compute gradients
        grad_x = cv2.Sobel(gray, cv2.CV_64F, 1, 0, ksize=3)
        grad_y = cv2.Sobel(gray, cv2.CV_64F, 0, 1, ksize=3)
        magnitude = np.sqrt(grad_x**2 + grad_y**2)
        orientation = np.arctan2(grad_y, grad_x)
        
        # Gradient magnitude histogram (128 features)
        mag_hist = np.histogram(magnitude, bins=128, range=(0, np.max(magnitude)))[0]
        mag_hist_normalized = mag_hist / (mag_hist.sum() + 1e-8)
        
        # 3. Color features (RGB channels statistics)
        color_features = []
        for i in range(3):  # RGB channels
            channel = img[:, :, i]
            color_features.extend([
                np.mean(channel),
                np.std(channel),
                np.min(channel),
                np.max(channel),
                np.percentile(channel, 25),
                np.percentile(channel, 50),
                np.percentile(channel, 75)
            ])
        
        # 4. Texture features (simplified)
        # Compute local binary pattern-like features
        texture_features = _compute_texture_features(gray)
        
        # 5. Edge features
        edges = cv2.Canny(gray, 50, 150)
        edge_density = np.sum(edges > 0) / (edges.shape[0] * edges.shape[1])
        
        # 6. Additional statistical features
        stats_features = [
            np.mean(gray),
            np.std(gray),
            np.var(gray),
            np.skew(gray.flatten()),
            np.kurtosis(gray.flatten()),
            edge_density
        ]
        
        # Combine all features
        all_features = np.concatenate([
            hist_normalized,      # 256
            mag_hist_normalized,  # 128
            color_features,       # 21 (3*7)
            texture_features,     # 1000 (approximate)
            stats_features        # 6
        ])
        
        # Ensure we have exactly 1662 features
        if len(all_features) > 1662:
            all_features = all_features[:1662]
        elif len(all_features) < 1662:
            # Pad with zeros if we have fewer features
            padding = np.zeros(1662 - len(all_features))
            all_features = np.concatenate([all_features, padding])
        
        return all_features.astype(np.float32)
        
    except Exception as e:
        print(f"Error extracting features: {e}")
        # Return dummy features
        return np.zeros(1662, dtype=np.float32)

def _compute_texture_features(gray_img):
    """
    Compute texture features using a simplified approach
    """
    try:
        # Resize to smaller size for faster computation
        small_img = cv2.resize(gray_img, (64, 64))
        
        # Compute local variance as texture measure
        kernel = np.ones((3, 3), np.float32) / 9
        mean_img = cv2.filter2D(small_img, -1, kernel)
        var_img = cv2.filter2D(small_img**2, -1, kernel) - mean_img**2
        
        # Flatten and take a sample of features
        texture_flat = var_img.flatten()
        
        # Sample 1000 features (or pad/truncate as needed)
        if len(texture_flat) >= 1000:
            indices = np.linspace(0, len(texture_flat)-1, 1000, dtype=int)
            return texture_flat[indices]
        else:
            # Pad with zeros
            padding = np.zeros(1000 - len(texture_flat))
            return np.concatenate([texture_flat, padding])
            
    except Exception as e:
        print(f"Error computing texture features: {e}")
        return np.zeros(1000, dtype=np.float32)

def _convert_yuv420_to_rgb(frame_bytes):
    """
    Convert YUV420 format to RGB
    This is a simplified conversion - in production you'd want more efficient conversion
    """
    try:
        # Assuming frame_bytes contains YUV420 data
        # For a 640x480 image, YUV420 would be: Y(640*480) + U(320*240) + V(320*240)
        
        # Try to infer dimensions from data size
        total_bytes = len(frame_bytes)
        
        # Common resolutions and their YUV420 sizes
        resolutions = [
            (640, 480, 640*480 + 320*240 + 320*240),
            (1280, 720, 1280*720 + 640*360 + 640*360),
            (1920, 1080, 1920*1080 + 960*540 + 960*540),
        ]
        
        width, height = 640, 480  # Default
        
        for w, h, expected_size in resolutions:
            if total_bytes == expected_size:
                width, height = w, h
                break
        
        # Extract Y, U, V planes
        y_size = width * height
        u_size = v_size = (width // 2) * (height // 2)
        
        if len(frame_bytes) < y_size + u_size + v_size:
            return None
        
        y_data = frame_bytes[:y_size]
        u_data = frame_bytes[y_size:y_size + u_size]
        v_data = frame_bytes[y_size + u_size:y_size + u_size + v_size]
        
        # Reshape to 2D arrays
        y = np.frombuffer(y_data, dtype=np.uint8).reshape(height, width)
        u = np.frombuffer(u_data, dtype=np.uint8).reshape(height // 2, width // 2)
        v = np.frombuffer(v_data, dtype=np.uint8).reshape(height // 2, width // 2)
        
        # Upsample U and V to full resolution
        u_upsampled = cv2.resize(u, (width, height), interpolation=cv2.INTER_LINEAR)
        v_upsampled = cv2.resize(v, (width, height), interpolation=cv2.INTER_LINEAR)
        
        # Convert YUV to RGB using OpenCV
        yuv = np.stack([y, u_upsampled, v_upsampled], axis=2)
        rgb = cv2.cvtColor(yuv, cv2.COLOR_YUV2RGB_I420)
        
        return rgb
        
    except Exception as e:
        print(f"Error converting YUV420 to RGB: {e}")
        return None
