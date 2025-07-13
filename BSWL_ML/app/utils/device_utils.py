import torch
import onnxruntime as ort

def get_device():
    return "cuda" if torch.cuda.is_available() else "cpu"

def get_execution_provider(device_preference="auto"):
    if device_preference == "auto":
        if ort.get_device() == "GPU" and torch.cuda.is_available():
            return "CUDAExecutionProvider"
        if "DmlExecutionProvider" in ort.get_available_providers():
            return "DmlExecutionProvider"
        return "CPUExecutionProvider"
    
    return device_preference

def optimize_for_device(model, device):
    if device == "cuda":
        model = model.half()  # Convert to FP16
        model = torch.compile(model)  # PyTorch 2.0 compiler
    return model

def gpu_available():
    return torch.cuda.is_available()
