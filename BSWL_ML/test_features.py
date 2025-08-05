#!/usr/bin/env python3
"""
Test script to verify ML service with 1662 features
"""
import asyncio
import websockets
import json
import numpy as np

async def test_features():
    """Test sending 1662 features to the ML service"""
    uri = "ws://localhost:8000/ws/predict"
    
    try:
        async with websockets.connect(uri) as websocket:
            print("✅ Connected to ML service")
            
            # Create dummy 1662 features (similar to what the hand tracker would send)
            features = np.random.random(1662).tolist()
            
            # Create feature data
            feature_data = {
                "type": "features",
                "features": features,
                "timestamp": 1234567890
            }
            
            # Send features
            await websocket.send(json.dumps(feature_data))
            print(f"📤 Sent {len(features)} features")
            
            # Wait for response
            response = await websocket.recv()
            print(f"📥 Received: {response}")
            
            # Parse response
            result = json.loads(response)
            print(f"🎯 Prediction: {result.get('translation', 'Unknown')}")
            print(f"📊 Confidence: {result.get('confidence', 0):.3f}")
            print(f"🆔 Class ID: {result.get('class_id', -1)}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_features()) 