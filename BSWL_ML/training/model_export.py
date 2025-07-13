import torch
import torch.onnx
import numpy as np
from app.models.isl_model import SignLanguageTransformer
from app.core.config import load_config
import onnx
import onnxruntime as ort
import argparse

def export_model(model_path, output_path, quantize=False):
    # Load configuration
    config = load_config()
    
    # Initialize model
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = SignLanguageTransformer(
        input_dim=config.input_size,
        num_classes=config.num_classes
    ).to(device)
    
    # Load weights
    model.load_state_dict(torch.load(model_path, map_location=device))
    model.eval()
    
    # Create sample input
    sample_input = torch.randn(1, config.sequence_length, config.input_size).to(device)
    
    # Export to TorchScript
    scripted_model = torch.jit.script(model)
    scripted_model.save(output_path.replace(".onnx", ".pt"))
    
    # Export to ONNX
    torch.onnx.export(
        model,
        sample_input,
        output_path,
        opset_version=13,
        input_names=['input'],
        output_names=['output'],
        dynamic_axes={
            'input': {0: 'batch_size', 1: 'sequence_length'},
            'output': {0: 'batch_size'}
        }
    )
    
    # Validate ONNX model
    onnx_model = onnx.load(output_path)
    onnx.checker.check_model(onnx_model)
    
    # Quantize model
    if quantize:
        from onnxruntime.quantization import quantize_dynamic, QuantType
        quantized_path = output_path.replace(".onnx", "_quant.onnx")
        quantize_dynamic(
            output_path,
            quantized_path,
            weight_type=QuantType.QUInt8,
            per_channel=False,
            reduce_range=False
        )
        print(f"Quantized model saved to: {quantized_path}")
    
    # Test inference
    ort_session = ort.InferenceSession(quantized_path if quantize else output_path)
    ort_inputs = {ort_session.get_inputs()[0].name: sample_input.cpu().numpy()}
    ort_outs = ort_session.run(None, ort_inputs)
    
    # Verify outputs
    with torch.no_grad():
        torch_out = model(sample_input)
    
    np.testing.assert_allclose(
        torch_out.cpu().numpy(), 
        ort_outs[0], 
        rtol=1e-03, 
        atol=1e-05
    )
    
    print(f"Model exported successfully to: {output_path}")
    return {
        "torchscript": output_path.replace(".onnx", ".pt"),
        "onnx": output_path,
        "quantized": quantized_path if quantize else None
    }

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Export trained model')
    parser.add_argument('--model', type=str, required=True, help='Path to trained model')
    parser.add_argument('--output', type=str, default="models/isl_model.onnx", help='Output path')
    parser.add_argument('--quantize', action='store_true', help='Enable quantization')
    args = parser.parse_args()
    
    export_model(args.model, args.output, args.quantize)