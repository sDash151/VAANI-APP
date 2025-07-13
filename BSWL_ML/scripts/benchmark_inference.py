import time
import numpy as np
import torch
from app.models.model_loader import ModelLoader
from app.core.config import settings
from app.utils import device_utils

def benchmark(model_path, num_runs=100, sequence_length=30):
    device = device_utils.get_device()
    model = ModelLoader(model_path, settings.execution_provider)
    
    # Create dummy input
    dummy_input = np.random.randn(1, sequence_length, 75 * 3).astype(np.float32)
    
    # Warmup
    for _ in range(10):
        model.predict(dummy_input)
    
    # Benchmark latency
    latencies = []
    for _ in range(num_runs):
        start = time.perf_counter()
        model.predict(dummy_input)
        latencies.append(time.perf_counter() - start)
    
    # Calculate metrics
    avg_latency = np.mean(latencies) * 1000  # ms
    min_latency = np.min(latencies) * 1000
    max_latency = np.max(latencies) * 1000
    throughput = num_runs / np.sum(latencies)
    
    print(f"Benchmark Results ({device}):")
    print(f"  Average Latency: {avg_latency:.2f} ms")
    print(f"  Min Latency:     {min_latency:.2f} ms")
    print(f"  Max Latency:     {max_latency:.2f} ms")
    print(f"  Throughput:      {throughput:.2f} requests/sec")

if __name__ == "__main__":
    benchmark("models/isl_model.onnx")