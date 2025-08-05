import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'environment.dart';

class AppConfig {
  // Backend API URL - Use dotenv with fallback to Environment
  static String get apiBaseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null) {
      return envUrl;
    }
    return Environment.backendUrl;
  }

  // ML Service URL - Use dotenv with fallback to Environment
  static String get mlServiceUrl {
    final envUrl = dotenv.env['ML_SERVICE_URL'];
    if (envUrl != null) {
      return envUrl;
    }
    return Environment.mlServiceUrl;
  }

  // ML Service Host and Port for WebSocket
  static String get mlServiceHost {
    final url = mlServiceUrl;
    if (url.startsWith('http://')) {
      return url.substring(7).split(':')[0];
    } else if (url.startsWith('https://')) {
      return url.substring(8).split(':')[0];
    }
    return '127.0.0.1';
  }

  static int get mlServicePort {
    final url = mlServiceUrl;
    if (url.contains(':')) {
      final portPart = url.split(':').last.split('/')[0];
      return int.tryParse(portPart) ?? 8000;
    }
    return 8000;
  }

  // Development URLs (fallback)
  static const String devBackendUrl = 'http://localhost:3000';
  static const String devMLServiceUrl = 'http://localhost:8000';

  // API Endpoints
  static const String healthEndpoint = 'api/v1/health';
  static const String mlStatusEndpoint = 'api/v1/ml/status';
  static const String mlTranslateEndpoint = 'api/v1/ml/translate';

  // ML Service Endpoints
  static const String mlHealthEndpoint = '/health';
  static const String mlServiceStatusEndpoint = '/status';
  static const String mlPredictEndpoint = '/predict/video';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
