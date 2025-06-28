import 'package:http/http.dart' as http;
import 'dart:io';

/// Test connection to the backend /api/v1/health endpoint.
Future<void> testBackendConnection() async {
  const url = 'http://10.0.2.2:3000/api/v1/health';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('✅ Backend connection successful: \n${response.body}');
    } else {
      print('❌ Backend responded with status: \n${response.statusCode}');
      print('Response body: \n${response.body}');
    }
  } on SocketException catch (e) {
    print('❌ Could not connect to backend (SocketException): $e');
  } catch (e) {
    print('❌ Error connecting to backend: $e');
  }
}
