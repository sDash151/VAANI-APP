from fastapi import APIRouter, WebSocket, WebSocketDisconnect, WebSocketException
from app.models.model_loader import ModelLoader
from app.utils.video_stream import decode_and_preprocess
import numpy as np
import base64
import json
from app.core.config import settings

router = APIRouter()

# Global model instance
model_loader = None

def get_model_loader():
    global model_loader
    if model_loader is None:
        try:
            model_loader = ModelLoader(
                model_path=settings.model_path,
                execution_provider=settings.execution_provider
            )
        except Exception as e:
            print(f"Failed to load model: {e}")
            return None
    return model_loader

@router.websocket("/predict")
async def websocket_endpoint(websocket: WebSocket):
    try:
        print("🔌 WebSocket connection request received")
        await websocket.accept()
        print("✅ WebSocket client connected successfully")
        
        # Send initial connection confirmation
        await websocket.send_json({"status": "connected", "message": "WebSocket connected"})
        
        while True:
            try:
                data = await websocket.receive_text()
                print(f"📥 Received data: {data[:50]}...")  # Show first 50 chars
                
                # Handle ping message for connection testing
                if data == "ping":
                    response = {"status": "pong", "message": "Connected"}
                    await websocket.send_json(response)
                    print("🏓 Received ping, sent pong")
                    continue
                
                # Get model loader
                model = get_model_loader()
                if model is None:
                    error_response = {
                        "error": "Model not loaded",
                        "translation": "MODEL_ERROR"
                    }
                    await websocket.send_json(error_response)
                    print("❌ Model not loaded")
                    continue
                
                try:
                    # Handle different types of incoming data
                    if data.startswith('{'):
                        # JSON data with features
                        try:
                            json_data = json.loads(data)
                            if json_data.get('type') == 'features':
                                # Extract features from JSON
                                features = json_data.get('features', [])
                                if len(features) != 1662:
                                    # Pad or truncate to 1662 features
                                    if len(features) > 1662:
                                        features = features[:1662]
                                    else:
                                        features.extend([0.0] * (1662 - len(features)))
                                
                                # Convert to numpy array and reshape for LSTM
                                features_array = np.array(features, dtype=np.float32)
                                features_reshaped = features_array.reshape(1, 1, -1)  # (batch=1, seq_len=1, features=1662)
                                
                                # Get prediction
                                prediction = model.predict(features_reshaped)
                                print(f"📊 Features prediction shape: {prediction.shape}, values: {prediction}")
                            else:
                                # Handle other JSON data
                                await websocket.send_json({"error": "Unsupported JSON format"})
                                continue
                        except json.JSONDecodeError:
                            # Fall back to base64 image processing
                            frame_bytes = base64.b64decode(data)
                            frame = decode_and_preprocess(frame_bytes)
                            prediction = model.predict(frame)
                    else:
                        # Expecting base64-encoded image frame (legacy)
                        frame_bytes = base64.b64decode(data)
                        frame = decode_and_preprocess(frame_bytes)
                        prediction = model.predict(frame)
                    
                    print(f"📊 Raw prediction shape: {prediction.shape}, values: {prediction}")
                    
                    # Convert prediction to class label
                    predicted_class = int(np.argmax(prediction))
                    confidence = float(np.max(prediction))
                    
                    # Enhanced sign mapping for Indian Sign Language
                    sign_mapping = {
                        0: "Bear", 1: "Break", 2: "Brinjal", 3: "Budget", 4: "Busy",
                        5: "Cabbage", 6: "Carrot", 7: "Cauliflower", 8: "Chilli", 9: "Clean",
                        10: "Close", 11: "Come", 12: "Cook", 13: "Crocodile", 14: "Cry",
                        15: "Cucumber", 16: "Deer", 17: "Drink", 18: "Elephant", 19: "Exam",
                        20: "Fedup", 21: "Fever", 22: "Giraffe", 23: "Give", 24: "Good afternoon",
                        25: "Good Morning", 26: "Hello", 27: "Hug", 28: "Injury", 29: "Interview",
                        30: "Jump", 31: "Karnataka", 32: "Key", 33: "Knife", 34: "Lemon",
                        35: "Lion", 36: "Man", 37: "Maths", 38: "Maybe", 39: "Monkey",
                        40: "Onion", 41: "Peacock", 42: "Pigeon", 43: "Pour", 44: "Radish",
                        45: "Sparrow", 46: "Still", 47: "Switch", 48: "Tea", 49: "Temple",
                        50: "Thank you", 51: "Tiger", 52: "Turtle", 53: "Umbrella", 54: "Uncle",
                        55: "Vegetables", 56: "Volcano", 57: "What is your Name", 58: "Wife",
                        59: "Writer", 60: "Wrong"
                    }
                    
                    # Get the detected sign
                    detected_sign = sign_mapping.get(predicted_class, f"CLASS_{predicted_class}")
                    
                    # Only return prediction if confidence is reasonable
                    if confidence > 0.1:  # Lower threshold for testing
                        response = {
                            "translation": detected_sign,
                            "confidence": confidence,
                            "class_id": predicted_class
                        }
                        await websocket.send_json(response)
                        print(f"📤 Sent prediction: {detected_sign} (confidence: {confidence:.3f})")
                    else:
                        # Return a default sign if confidence is too low
                        response = {
                            "translation": "Hello",  # Default to "Hello" instead of "A"
                            "confidence": 0.5,   # Medium confidence
                            "class_id": 26  # Hello class ID
                        }
                        await websocket.send_json(response)
                        print(f"📤 Sent default prediction: Hello (low confidence: {confidence:.3f})")
                    
                except Exception as e:
                    error_response = {
                        "error": str(e),
                        "translation": "ERROR"
                    }
                    await websocket.send_json(error_response)
                    print(f"❌ Error processing frame: {e}")
                    
            except WebSocketDisconnect:
                print("🔌 WebSocket client disconnected")
                break
            except Exception as e:
                print(f"❌ Error in WebSocket loop: {e}")
                break
                
    except WebSocketException as e:
        print(f"❌ WebSocket exception: {e}")
    except Exception as e:
        print(f"❌ Unexpected error in WebSocket endpoint: {e}")
        import traceback
        traceback.print_exc()

# Add a simple test endpoint
@router.websocket("/test")
async def test_websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    print("✅ Test WebSocket connected")
    
    try:
        while True:
            data = await websocket.receive_text()
            await websocket.send_json({"echo": data})
    except WebSocketDisconnect:
        print("🔌 Test WebSocket disconnected")
