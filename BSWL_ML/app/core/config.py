import os
import yaml
# NEW (add this line)
from pydantic_settings import BaseSettings
from pydantic import Field

class AppConfig(BaseSettings):
    model_path: str = Field("models/isl_model.pt", env="MODEL_PATH")
    execution_provider: str = Field("CPUExecutionProvider", env="EXECUTION_PROVIDER")
    sequence_length: int = 30
    sequence_overlap: int = 5
    frame_width: int = 640
    frame_height: int = 480
    max_video_size: int = 50 * 1024 * 1024  # 50MB
    label_mappings: dict = {}
    log_level: str = "INFO"
    gpu_threshold: float = 0.8

    class Config:
        env_file = ".env"
        env_prefix = "ISL_"

    @classmethod
    def from_yaml(cls, config_path: str):
        with open(config_path, 'r') as f:
            config_data = yaml.safe_load(f)
        return cls(**config_data)

def load_config(config_path: str = "app/config.yaml") -> AppConfig:
    return AppConfig.from_yaml(config_path)

settings = AppConfig()