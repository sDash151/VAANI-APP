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

video_processor = VideoProcessor(settings)
model_loader = ModelLoader(
    model_path=settings.model_path,
    execution_provider=settings.execution_provider
)
translator = TranslationMapper(settings.label_mappings)

@router.post("/predict/video", response_model=TranslationResponse)
async def predict_video(file: UploadFile = File(...)):
    try:
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