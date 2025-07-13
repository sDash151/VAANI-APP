from pydantic import BaseModel
from typing import List

class HealthResponse(BaseModel):
    status: str
    version: str
    model: str

class TranslationResponse(BaseModel):
    english: str
    hindi: str
    confidence: float
    processing_time: float
    fps: float

class ErrorResponse(BaseModel):
    error: str
    code: int
    details: dict = None

class BatchPredictionRequest(BaseModel):
    videos: List[str]  # List of base64-encoded videos

class BatchPredictionResponse(BaseModel):
    results: List[TranslationResponse]

class ModelInfoResponse(BaseModel):
    name: str
    version: str
    input_shape: list
    output_classes: int
    framework: str
    quantization: str
    accuracy: float
    latency: float