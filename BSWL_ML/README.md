# Indian Sign Language Translation ML Service

Real-time ISL translation microservice with PyTorch Transformer, ONNX Runtime, and Kubernetes deployment.

## Features
- Real-time video processing at 30+ FPS
- MediaPipe Holistic landmark extraction
- Transformer-based sequence modeling
- Multi-language output (English/Hindi)
- GPU-accelerated inference
- Kubernetes-native deployment
- Automatic scaling
- End-to-end encryption

## Quick Start
```bash
# Clone repository
git clone https://github.com/yourorg/isl-ml-service.git

# Install dependencies
pip install -r requirements/app.txt

# Start service (development)
uvicorn app.main:app --reload

# Test endpoint
curl -X POST -F "file=@sample.mp4" http://localhost:8000/predict/video