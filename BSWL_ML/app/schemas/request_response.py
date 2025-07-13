from pydantic import BaseModel

class TranslationResponse(BaseModel):
    translation: str
    confidence: float
    lang: str
