import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetectionService {
  // Untuk Emulator Android
  // static const String baseUrl = "http://10.0.2.2:5000";

  // Untuk HP asli (nanti ganti jika pakai device fisik)
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  static Future<Map<String, dynamic>> detect(File imageFile) async {
    try {
      final uri = Uri.parse("$baseUrl/detect");

      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();

      // Cek status server
      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      final responseBody = await response.stream.bytesToString();

      // Debug print
      print("Response dari server: $responseBody");

      return json.decode(responseBody);
    } catch (e) {
      print("Detection error: $e");
      throw Exception("Gagal menghubungi server");
    }
  }
}
