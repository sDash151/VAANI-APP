import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ApiService {
  final String baseUrl;
  final String mlServiceUrl;

  ApiService({
    required this.baseUrl,
    required this.mlServiceUrl,
  });

  // Basic HTTP methods
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final mergedHeaders = {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: mergedHeaders,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  // File upload method for video/image processing
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    Map<String, String>? headers,
    String fieldName = 'video',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/$endpoint'),
    );

    // Add headers
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Add file
    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  // ML Service specific methods
  Future<Map<String, dynamic>> checkMLHealth() async {
    final response = await http.get(
      Uri.parse('$mlServiceUrl/health'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getMLStatus() async {
    final response = await http.get(
      Uri.parse('$mlServiceUrl/status'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> translateVideo(
    File videoFile, {
    Map<String, String>? headers,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$mlServiceUrl/predict/video'),
    );

    // Add headers
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Add video file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        videoFile.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  // Backend ML integration
  Future<Map<String, dynamic>> translateVideoViaBackend(
    File videoFile, {
    Map<String, String>? headers,
  }) async {
    return await uploadFile(
      'api/v1/ml/translate',
      videoFile,
      headers: headers,
      fieldName: 'video',
    );
  }

  Future<Map<String, dynamic>> getBackendMLStatus() async {
    return await get('api/v1/ml/status');
  }

  Future<Map<String, dynamic>> getBackendHealth() async {
    return await get('api/v1/health');
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to load data: ${response.statusCode} - ${response.body}');
    }
  }
}
