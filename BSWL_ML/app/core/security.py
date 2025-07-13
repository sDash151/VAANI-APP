from fastapi import HTTPException, status, Depends
from fastapi.security import APIKeyHeader
from app.core.config import settings
import os
import time

API_KEY_NAME = "X-API-Key"
api_key_scheme = APIKeyHeader(name=API_KEY_NAME, auto_error=False)

def validate_api_key(api_key: str = Depends(api_key_scheme)):
    if not api_key or api_key != settings.api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API Key",
        )
    return api_key

def generate_api_key():
    return os.urandom(32).hex()

class RateLimiter:
    def __init__(self, max_requests: int, time_window: int):
        self.max_requests = max_requests
        self.time_window = time_window
        self.access_records = {}
    
    async def check_limit(self, client_ip: str):
        current_time = time.time()
        window_start = current_time - self.time_window
        
        # Clean up old records
        self.access_records[client_ip] = [
            t for t in self.access_records.get(client_ip, []) if t > window_start
        ]
        
        if len(self.access_records[client_ip]) >= self.max_requests:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Rate limit exceeded",
            )
        
        self.access_records[client_ip].append(current_time)
        return True