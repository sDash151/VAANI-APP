#!/usr/bin/env python3
"""
Test Flutter App Connection Simulation
"""

import asyncio
import websockets
import json
import base64
import numpy as np

async def simulate_flutter_connection():
    print("📱 Simulating Flutter App Connection")
    print("=" * 50)
    
    uri = "ws://localhost:8000/ws/predict"
    
    try:
        print(f"🔌 Connecting to {uri}")
        async with websockets.connect(uri) as websocket:
            print("✅ Connected!")
            
            # Wait for initial connection message (like Flutter does)
            initial_response = await websocket.recv()
            print(f"📥 Initial: {initial_response}")
            
            # Send ping (like Flutter does)
            print("📤 Sending ping...")
            await websocket.send("ping")
            
            # Wait for pong response
            pong_response = await websocket.recv()
            print(f"🏓 Pong: {pong_response}")
            
            # Now simulate sending camera frames (like Flutter does)
            print("\n📹 Simulating camera frame transmission...")
            
            for i in range(5):  # Send 5 frames
                # Create a dummy frame (simulating Flutter camera)
                dummy_frame = np.random.randint(0, 255, (480, 640, 3), dtype=np.uint8)
                frame_bytes = dummy_frame.tobytes()
                frame_base64 = base64.b64encode(frame_bytes).decode('utf-8')
                
                print(f"📤 Sending frame {i+1} ({len(frame_bytes)} bytes)...")
                await websocket.send(frame_base64)
                
                # Wait for prediction response
                response = await websocket.recv()
                prediction = json.loads(response)
                print(f"📥 Frame {i+1} prediction: {prediction['translation']} (confidence: {prediction['confidence']:.3f})")
                
                # Small delay between frames
                await asyncio.sleep(0.5)
            
            print("\n✅ Flutter connection simulation successful!")
            print("🎯 The Flutter app should now show 'ML CONNECTED' and receive predictions!")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False
    
    return True

if __name__ == "__main__":
    success = asyncio.run(simulate_flutter_connection())
    if success:
        print("\n🎉 Flutter app should work correctly now!")
    else:
        print("\n❌ Flutter connection simulation failed") 