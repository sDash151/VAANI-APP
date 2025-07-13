import torch
import onnxruntime as ort
import numpy as np
from app.core.config import settings
from app.utils import device_utils

class ModelLoader:
    def __init__(self, model_path, execution_provider=None):
        self.model_path = model_path
        self.execution_provider = execution_provider or device_utils.get_execution_provider()
        
        if model_path.endswith(".onnx"):
            self.model = self._load_onnx_model()
        elif model_path.endswith(".pt") or model_path.endswith(".pth"):
            self.model = self._load_torch_model()
        else:
            raise ValueError("Unsupported model format")
            
    def _load_onnx_model(self):
        sess_options = ort.SessionOptions()
        sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
        sess_options.intra_op_num_threads = 4
        
        providers = ["CPUExecutionProvider"]
        if "CUDAExecutionProvider" in ort.get_available_providers() and "gpu" in self.execution_provider.lower():
            providers = [("CUDAExecutionProvider", {"cudnn_conv_algo_search": "DEFAULT"})]
        elif "DmlExecutionProvider" in ort.get_available_providers():
            providers = ["DmlExecutionProvider"]
            
        return ort.InferenceSession(
            self.model_path,
            sess_options,
            providers=providers
        )
    
    def _load_torch_model(self):
        device = device_utils.get_device()
        model = torch.jit.load(self.model_path, map_location=device)
        model.eval()
        return model
    
    def predict(self, inputs):
        if isinstance(self.model, ort.InferenceSession):
            input_name = self.model.get_inputs()[0].name
            outputs = self.model.run(None, {input_name: inputs})
            return outputs[0]
        else:
            with torch.no_grad():
                tensor_inputs = torch.from_numpy(inputs).to(
                    next(self.model.parameters()).device
                )
                outputs = self.model(tensor_inputs)
                return outputs.cpu().numpy()