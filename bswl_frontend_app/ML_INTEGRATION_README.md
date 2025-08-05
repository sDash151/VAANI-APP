# 🚀 Flutter ML Integration Setup

This document explains how the Flutter frontend is integrated with the Backend API and ML Service for Indian Sign Language (ISL) translation.

## 📋 Overview

The Flutter app now includes a complete ML integration system that allows users to:
- 📹 Upload or record videos for sign language translation
- 🤖 Process videos through the ML service
- 🌐 Get translations in English and Hindi
- 📊 Monitor system health and service status
- 🔄 Real-time processing with confidence scores

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Backend API    │    │   ML Service    │
│                 │    │   (Node.js)     │    │   (FastAPI)     │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │Video Upload │ │───▶│ │ML Controller│ │───▶│ │Video        │ │
│ │Translation  │ │    │ │File Upload  │ │    │ │Processing   │ │
│ │UI           │ │    │ │Auth         │ │    │ │Model        │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │System Health│ │◀───│ │Health Check │ │◀───│ │Health Check │ │
│ │Monitoring   │ │    │ │MongoDB      │ │    │ │Model Status │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 File Structure

```
lib/
├── config/
│   ├── app_config.dart          # API configuration
│   └── environment.dart         # Environment settings
├── services/
│   ├── api_service.dart         # HTTP client for API calls
│   ├── ml_service.dart          # ML service integration
│   └── service_provider.dart    # Dependency injection
├── src/
│   ├── screens/
│   │   └── ml_integration_screen.dart  # Main ML screen
│   └── widgets/
│       ├── video_translation_widget.dart  # Video processing UI
│       ├── system_health_widget.dart      # Health monitoring
│       └── ml_navigation_card.dart        # Navigation card
└── main.dart                    # App entry point
```

## 🔧 Configuration

### Environment Setup

The app uses environment variables for configuration. Create a `.env` file in the root directory:

```env
# Backend API Configuration
API_BASE_URL=http://localhost:3000

# ML Service Configuration
ML_SERVICE_URL=http://localhost:8000

# Development Configuration
DEBUG=true
ENVIRONMENT=development
```

### Fallback Configuration

If `.env` file is not available, the app uses fallback URLs from `lib/config/environment.dart`:

```dart
static const String devBackendUrl = 'http://localhost:3000';
static const String devMLServiceUrl = 'http://localhost:8000';
```

## 🚀 Getting Started

### 1. Prerequisites

Ensure your backend services are running:
- ✅ Backend API (Node.js) on port 3000
- ✅ ML Service (FastAPI) on port 8000
- ✅ MongoDB on port 27018

### 2. Run the Development Environment

```bash
# Start all services (backend, ML, MongoDB)
.\dev_start.bat

# In a new terminal, run Flutter app
cd bswl_frontend_app
flutter run
```

### 3. Access ML Integration

Navigate to the ML Integration screen:
- Use the navigation card on the home screen, or
- Navigate directly to `/ml-integration` route

## 🎯 Features

### Video Translation
- **Upload Video**: Pick videos from gallery
- **Record Video**: Record new videos using camera
- **Processing**: Real-time video processing with progress indicator
- **Results**: Display translation with confidence scores

### System Health Monitoring
- **Service Status**: Real-time monitoring of backend and ML services
- **Health Checks**: Automatic health verification
- **Error Handling**: Comprehensive error reporting
- **Service Details**: Detailed service information

### User Experience
- **Responsive UI**: Modern, intuitive interface
- **Progress Indicators**: Visual feedback during processing
- **Error Messages**: Clear error communication
- **Quick Actions**: Easy access to common functions

## 🔌 API Integration

### Backend API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/health` | GET | Backend health check |
| `/api/v1/ml/status` | GET | ML integration status |
| `/api/v1/ml/translate` | POST | Video translation (via backend) |

### ML Service Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | ML service health |
| `/status` | GET | ML service status |
| `/predict/video` | POST | Direct video translation |

### File Upload Format

```dart
// Video upload via backend (recommended)
final result = await mlService.translateVideoViaBackend(
  videoFile,
  authToken: 'your-auth-token', // Optional
);

// Direct ML service upload
final result = await mlService.translateVideoDirect(videoFile);
```

## 📊 Response Format

### Translation Result

```dart
class TranslationResult {
  final String english;      // English translation
  final String hindi;        // Hindi translation
  final double confidence;   // Confidence score (0.0 - 1.0)
  final double fps;          // Processing FPS
  final String? error;       // Error message if any
  
  bool get isSuccess => error == null;
  bool get isHighConfidence => confidence > 0.7;
}
```

### Health Check Response

```json
{
  "success": true,
  "message": "Backend is working!",
  "mongodb": "connected",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## 🛠️ Development

### Adding New Features

1. **Service Layer**: Add methods to `MLService` or `ApiService`
2. **UI Components**: Create widgets in `lib/src/widgets/`
3. **Screens**: Add screens in `lib/src/screens/`
4. **Configuration**: Update `app_config.dart` if needed

### Testing

```bash
# Run Flutter tests
flutter test

# Test specific integration
flutter test test/ml_integration_test.dart
```

### Debugging

- Check service health in the System Health tab
- Monitor network requests in Flutter DevTools
- View service logs in the backend terminals

## 🔒 Security

### Authentication
- JWT tokens for API authentication
- Firebase authentication integration
- Secure file upload handling

### Error Handling
- Comprehensive error catching
- User-friendly error messages
- Graceful degradation

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🚀 Deployment

### Production Configuration

1. Update `environment.dart`:
```dart
static const bool isDevelopment = false;
static const String prodBackendUrl = 'https://your-backend-domain.com';
static const String prodMLServiceUrl = 'https://your-ml-service-domain.com';
```

2. Build for production:
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🐛 Troubleshooting

### Common Issues

1. **Connection Refused**
   - Ensure backend services are running
   - Check ports (3000, 8000, 27018)
   - Verify firewall settings

2. **Video Upload Fails**
   - Check file format (MP4, AVI, MOV)
   - Ensure file size < 100MB
   - Verify network connectivity

3. **Translation Errors**
   - Check ML service health
   - Verify model is loaded
   - Review video quality

### Debug Commands

```bash
# Check service status
curl http://localhost:3000/api/v1/health
curl http://localhost:8000/health

# Test video upload
curl -X POST -F "video=@test.mp4" http://localhost:3000/api/v1/ml/translate
```

## 📞 Support

For issues or questions:
1. Check the System Health tab in the app
2. Review service logs
3. Test individual endpoints
4. Verify configuration settings

## 🎉 Success!

Your Flutter app is now fully integrated with the ML translation system! Users can:
- Upload and record videos for translation
- Get real-time sign language translations
- Monitor system health and performance
- Enjoy a seamless, professional experience

The integration is production-ready and includes comprehensive error handling, monitoring, and user feedback. 