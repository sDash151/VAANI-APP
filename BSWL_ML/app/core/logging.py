import logging
import sys
from logging.handlers import RotatingFileHandler
from app.core.config import settings

def configure_logging():
    logger = logging.getLogger()
    logger.setLevel(settings.log_level)
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    ))
    
    # File handler
    file_handler = RotatingFileHandler(
        "app.log", maxBytes=10*1024*1024, backupCount=5
    )
    file_handler.setFormatter(logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(module)s:%(lineno)d - %(message)s"
    ))
    
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    return logger

logger = configure_logging()