import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<File?> pickImageFromGallery() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    return File(pickedFile.path);
  }
  return null;
}

Future<String?> uploadToCloudinary(File imageFile) async {
  const cloudName = 'dfipqyrz0';
  const uploadPreset = 'bswl_preset';
  final url =
      Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();
  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final jsonResponse = json.decode(responseData);
    return jsonResponse['secure_url'];
  } else {
    print("Upload failed: ${response.statusCode}");
    return null;
  }
}
