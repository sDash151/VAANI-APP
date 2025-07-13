#!/bin/bash

# Download pretrained model weights
MODEL_URL="https://example.com/models/isl_model_v1.0.0.pth"
OUTPUT_DIR="models"
OUTPUT_FILE="${OUTPUT_DIR}/isl_model.pth"

# Create directory if not exists
mkdir -p $OUTPUT_DIR

# Download model
echo "Downloading model weights..."
wget -q --show-progress -O $OUTPUT_FILE $MODEL_URL

# Verify download
if [ $? -eq 0 ]; then
    echo "Model downloaded successfully to ${OUTPUT_FILE}"
    echo "File size: $(du -h $OUTPUT_FILE | cut -f1)"
else
    echo "Failed to download model"
    exit 1
fi

# Convert to ONNX
echo "Converting to ONNX format..."
python scripts/convert_to_onnx.py --model $OUTPUT_FILE

echo "Setup complete!"