# BSWL ML Microservice Integration Guide

This guide explains how to integrate your trained ML model with your BSWL application.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Backend API    │    │  ML Microservice │
│   (Frontend)    │◄──►│   (Node.js)     │◄──►│   (FastAPI)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │    MongoDB      │    │  Trained Model  │
                       │   (Database)    │    │   (ONNX/PyTorch)│
                       └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

1. **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop)
2. **Trained Model** - Ensure your model is in `BSWL_ML/models/` directory
3. **Environment Setup** - Make sure all dependencies are installed

### Deployment

#### Option 1: Using Docker Compose (Recommended)

```bash
# Run the deployment script
./deploy.bat  # Windows
./deploy.sh   # Linux/Mac
```

#### Option 2: Manual Deployment

```bash
# 1. Install backend dependencies
cd BSWL_BACKEND
npm install

# 2. Install ML service dependencies
cd ../BSWL_ML
pip install -r requirements.txt

# 3. Start services
docker-compose up -d
```

## 📡 API Endpoints

### Backend API (Port 3000)

#### Video Translation
```http
POST /api/v1/ml/translate
Content-Type: multipart/form-data
Authorization: Bearer <jwt_token>

Body: video file
```

**Response:**
```json
{
  "success": true,
  "message": "Video translated successfully",
  "data": {
    "english": "Hello",
    "hindi": "नमस्ते",
    "confidence": 0.95,
    "fps": 30.0
  }
}
```

#### Health Check
```http
GET /api/v1/ml/health
```

**Response:**
```json
{
  "success": true,
  "data": {
    "ml_service_healthy": true,
    "timestamp": "2024-01-01T12:00:00.000Z"
  }
}
```

#### Service Status
```http
GET /api/v1/ml/status
```

### ML Service (Port 8000)

#### Direct Video Processing
```http
POST /predict/video
Content-Type: multipart/form-data

Body: video file
```

#### Health Check
```http
GET /health
```

#### Service Status
```http
GET /status
```

#### WebSocket (Real-time)
```javascript
const ws = new WebSocket('ws://localhost:8000/ws/predict');
ws.send(base64EncodedFrame);
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the backend directory:

```env
# Backend Configuration
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://localhost:27017/bswl
JWT_SECRET=your_jwt_secret_here

# ML Service Configuration
ML_SERVICE_URL=http://localhost:8000
```

### ML Service Configuration

Update `BSWL_ML/app/config.yaml`:

```yaml
# Model Configuration
model_path: "models/isl_model.onnx"
execution_provider: "auto"
sequence_length: 160
num_classes: 50

# Processing Configuration
frame_width: 640
frame_height: 480
max_video_size: 52428800  # 50MB
```

## 📱 Frontend Integration

### Flutter Example

```dart
import 'dart:io';
import 'package:http/http.dart' as http;

class MLService {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  
  static Future<Map<String, dynamic>> translateVideo(File videoFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ml/translate'),
      );
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add video file
      request.files.add(
        await http.MultipartFile.fromPath('video', videoFile.path),
      );
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<bool> checkHealth() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/ml/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

### Real-time Processing

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

class RealTimeMLService {
  WebSocketChannel? _channel;
  
  void startRealTimeProcessing() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8000/ws/predict'),
    );
    
    _channel!.stream.listen((data) {
      // Handle real-time predictions
      print('Prediction: $data');
    });
  }
  
  void sendFrame(String base64Frame) {
    _channel?.sink.add(base64Frame);
  }
  
  void stop() {
    _channel?.sink.close();
  }
}
```

## 🐳 Docker Commands

### Start Services
```bash
docker-compose up -d
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f ml-service
docker-compose logs -f backend
```

### Stop Services
```bash
docker-compose down
```

### Rebuild Services
```bash
docker-compose up --build -d
```

### Update Services
```bash
docker-compose pull
docker-compose up -d
```

## 🔍 Monitoring & Debugging

### Health Checks

```bash
# Backend health
curl http://localhost:3000/api/v1/ml/health

# ML service health
curl http://localhost:8000/health

# Overall system health
curl http://localhost/health
```

### Logs

```bash
# Backend logs
docker-compose logs backend

# ML service logs
docker-compose logs ml-service

# Real-time logs
docker-compose logs -f
```

### Performance Monitoring

```bash
# Check resource usage
docker stats

# Check service status
docker-compose ps
```

## 🚨 Troubleshooting

### Common Issues

1. **ML Service Not Responding**
   - Check if model file exists in `BSWL_ML/models/`
   - Verify GPU drivers if using CUDA
   - Check logs: `docker-compose logs ml-service`

2. **Video Upload Fails**
   - Check file size (max 50MB)
   - Verify file format (MP4, AVI, MOV, WMV, FLV)
   - Check upload directory permissions

3. **Authentication Errors**
   - Verify JWT token
   - Check JWT_SECRET environment variable
   - Ensure user is logged in

4. **Database Connection Issues**
   - Check MongoDB container status
   - Verify MONGODB_URI environment variable
   - Check network connectivity

### Debug Mode

To run in debug mode:

```bash
# Backend debug
cd BSWL_BACKEND
npm run dev

# ML service debug
cd BSWL_ML
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 📊 Performance Optimization

### ML Service Optimization

1. **GPU Acceleration**
   - Install NVIDIA Docker runtime
   - Set `execution_provider: "cuda"` in config
   - Ensure CUDA drivers are installed

2. **Model Optimization**
   - Convert to ONNX format for faster inference
   - Use model quantization
   - Implement batch processing

3. **Caching**
   - Implement Redis caching for frequent predictions
   - Cache processed video frames
   - Use CDN for static assets

### Backend Optimization

1. **Rate Limiting**
   - Configure rate limits in nginx
   - Implement request queuing
   - Add request validation

2. **File Handling**
   - Implement streaming uploads
   - Add file compression
   - Use cloud storage for large files

## 🔒 Security Considerations

1. **Authentication**
   - Use JWT tokens for API access
   - Implement role-based access control
   - Add request validation

2. **File Security**
   - Validate file types and sizes
   - Scan uploaded files for malware
   - Implement secure file storage

3. **Network Security**
   - Use HTTPS in production
   - Implement CORS policies
   - Add rate limiting

## 📈 Scaling

### Horizontal Scaling

```yaml
# docker-compose.yml
services:
  ml-service:
    deploy:
      replicas: 3
    environment:
      - EXECUTION_PROVIDER=cpu  # Use CPU for scaling
```

### Load Balancing

```nginx
# nginx.conf
upstream ml-service {
    server ml-service-1:8000;
    server ml-service-2:8000;
    server ml-service-3:8000;
}
```

## 📝 API Documentation

- **Backend API**: http://localhost:3000/api-docs
- **ML Service**: http://localhost:8000/docs
- **Health Check**: http://localhost/health

## 🤝 Support

For issues and questions:

1. Check the logs: `docker-compose logs`
2. Verify configuration files
3. Test individual services
4. Check network connectivity
5. Review this documentation

## 📚 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Express.js Documentation](https://expressjs.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/) 