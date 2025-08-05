from fastapi import APIRouter, File, UploadFile
from fastapi.responses import JSONResponse
from app.core.config import settings
from app.processing.video_processor import VideoProcessor
from app.models.model_loader import ModelLoader
from app.utils.translation_mapper import TranslationMapper
from .schemas import TranslationResponse
from tempfile import NamedTemporaryFile
import cv2
import numpy as np
import shutil

router = APIRouter()

# Lazy loading - don't instantiate at import time
_video_processor = None
_model_loader = None
_translator = None

def get_video_processor():
    global _video_processor
    if _video_processor is None:
        _video_processor = VideoProcessor(settings)
    return _video_processor

def get_model_loader():
    global _model_loader
    if _model_loader is None:
        _model_loader = ModelLoader(
            model_path=settings.model_path,
            execution_provider=settings.execution_provider
        )
    return _model_loader

def get_translator():
    global _translator
    if _translator is None:
        _translator = TranslationMapper(settings.label_mappings)
    return _translator

@router.post("/predict/video", response_model=TranslationResponse)
async def predict_video(file: UploadFile = File(...)):
    try:
        # Get instances when needed
        video_processor = get_video_processor()
        model_loader = get_model_loader()
        translator = get_translator()
        
        # Stream processing to avoid large memory usage
        with NamedTemporaryFile(delete=True) as temp_video:
            shutil.copyfileobj(file.file, temp_video)
            temp_video.seek(0)
            
            cap = cv2.VideoCapture(temp_video.name)
            fps = cap.get(cv2.CAP_PROP_FPS)
            
            results = []
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break
                
                sequence = await video_processor.process_frame(frame)
                if sequence is not None:
                    outputs = model_loader.predict(sequence)
                    results.append(outputs)
            
            # Temporal aggregation
            aggregated = np.mean(results, axis=0)
            pred_idx = np.argmax(aggregated)
            confidence = aggregated[pred_idx]
            
            return TranslationResponse(
                english=translator.get_english(pred_idx),
                hindi=translator.get_hindi(pred_idx),
                confidence=float(confidence),
                fps=fps
            )
            
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": f"Processing failed: {str(e)}"}
        )