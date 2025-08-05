import torch
import numpy as np
from app.core.config import settings
from app.utils import device_utils

# Import onnxruntime only when needed
try:
    import onnxruntime as ort
    ONNX_AVAILABLE = True
except ImportError:
    ONNX_AVAILABLE = False

class ModelLoader:
    def __init__(self, model_path, execution_provider=None):
        self.model_path = model_path
        self.execution_provider = execution_provider or device_utils.get_execution_provider()
        
        if model_path.endswith(".onnx"):
            self.model = self._load_onnx_model()
        elif model_path.endswith(".pt") or model_path.endswith(".pth") or model_path.endswith(".ts"):
            self.model = self._load_torch_model()
        else:
            raise ValueError(f"Unsupported model format: {model_path}")
            
    def _load_onnx_model(self):
        if not ONNX_AVAILABLE:
            raise ImportError("ONNX Runtime is not available. Please install onnxruntime.")
        
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
        try:
            # Try loading as TorchScript model
            model = torch.jit.load(self.model_path, map_location=device)
            model.eval()
            return model
        except Exception as e:
            # If TorchScript fails, try loading as regular PyTorch model
            try:
                model = torch.load(self.model_path, map_location=device)
                if isinstance(model, dict):
                    if 'model_state_dict' in model:
                        # Load state dict into a new model instance
                        from app.models.isl_model import ISLModel
                        # You may need to adjust these parameters based on your model
                        model_instance = ISLModel(input_dim=2048, num_classes=100)  # Adjust dimensions
                        model_instance.load_state_dict(model['model_state_dict'])
                        model_instance.eval()
                        return model_instance
                    elif 'model' in model:
                        # Load the actual model from checkpoint
                        model_instance = model['model']
                        if hasattr(model_instance, 'eval'):
                            model_instance.eval()
                            return model_instance
                        else:
                            # It's a state dict, create model instance
                            from app.models.lstm_model import LSTMClassifier
                            # Use the parameters from the trained model
                            model_instance = LSTMClassifier(
                                input_dim=1662,  # From trained model
                                hidden_dim=128,  # From trained model (512/4 for bidirectional)
                                num_classes=41,  # From trained model
                                bidirectional=True,
                                dropout_p=0.3
                            )
                            model_instance.load_state_dict(model['model'])
                            model_instance.eval()
                            return model_instance
                    else:
                        # Try to load as state dict directly
                        from app.models.isl_model import ISLModel
                        model_instance = ISLModel(input_dim=2048, num_classes=100)
                        model_instance.load_state_dict(model)
                        model_instance.eval()
                        return model_instance
                else:
                    model.eval()
                    return model
            except Exception as e2:
                raise ValueError(f"Failed to load model from {self.model_path}. TorchScript error: {e}. PyTorch error: {e2}")
    
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