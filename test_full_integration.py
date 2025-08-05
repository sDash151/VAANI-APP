#!/usr/bin/env python3
"""
Full Camera-ML Integration Test
"""

import asyncio
import websockets
import json
import base64
import numpy as np
import requests

async def test_full_integration():
    print("🧪 Testing Full Camera-ML Integration")
    print("=" * 50)
    
    # Test 1: HTTP Endpoints
    print("1️⃣ Testing HTTP endpoints...")
    try:
        health_response = requests.get("http://localhost:8000/health")
        status_response = requests.get("http://localhost:8000/status")
        
        print(f"   Health: {health_response.status_code} - {health_response.json()}")
        print(f"   Status: {status_response.status_code} - {status_response.json()}")
        
        if health_response.status_code == 200 and status_response.status_code == 200:
            print("   ✅ HTTP endpoints working")
        else:
            print("   ❌ HTTP endpoints failed")
            return False
    except Exception as e:
        print(f"   ❌ HTTP test failed: {e}")
        return False
    
    # Test 2: WebSocket Connection
    print("\n2️⃣ Testing WebSocket connection...")
    try:
        uri = "ws://localhost:8000/ws/predict"
        async with websockets.connect(uri) as websocket:
            print("   ✅ WebSocket connected")
            
            # Wait for initial message
            initial = await websocket.recv()
            print(f"   📥 Initial: {initial}")
            
            # Test ping/pong
            await websocket.send("ping")
            pong = await websocket.recv()
            print(f"   🏓 Pong: {pong}")
            
            print("   ✅ WebSocket communication working")
    except Exception as e:
        print(f"   ❌ WebSocket test failed: {e}")
        return False
    
    # Test 3: Frame Processing
    print("\n3️⃣ Testing frame processing...")
    try:
        uri = "ws://localhost:8000/ws/predict"
        async with websockets.connect(uri) as websocket:
            # Wait for initial message
            await websocket.recv()
            
            # Create a dummy frame (simulating camera input)
            dummy_frame = np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8)
            frame_bytes = dummy_frame.tobytes()
            frame_base64 = base64.b64encode(frame_bytes).decode('utf-8')
            
            print(f"   📤 Sending frame ({len(frame_bytes)} bytes)...")
            await websocket.send(frame_base64)
            
            # Wait for prediction
            response = await websocket.recv()
            prediction = json.loads(response)
            print(f"   📥 Prediction: {prediction}")
            
            if 'translation' in prediction and 'confidence' in prediction:
                print(f"   ✅ Frame processing working - Detected: {prediction['translation']}")
            else:
                print(f"   ❌ Unexpected prediction format")
                return False
    except Exception as e:
        print(f"   ❌ Frame processing test failed: {e}")
        return False
    
    print("\n" + "=" * 50)
    print("🎉 ALL TESTS PASSED!")
    print("✅ Camera-ML integration is working correctly!")
    print("✅ The Flutter app should now connect to the ML service!")
    return True

if __name__ == "__main__":
    success = asyncio.run(test_full_integration())
    if not success:
        print("\n❌ Integration test failed")
        exit(1) 