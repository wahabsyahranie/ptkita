import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetectionService {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.18.113:5000',
  );

  static Future<Map<String, dynamic>> detect(File imageFile) async {
    try {
      final uri = Uri.parse("$baseUrl/detect");

      var request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();

      var responseBody = await response.stream.bytesToString();

      print("Response server: $responseBody");

      // ===============================
      // HANDLE ERROR STATUS CODE
      // ===============================
      if (response.statusCode != 200) {
        return {
          "status": "failed",
          "message": "Server error ${response.statusCode}"
        };
      }

      final decoded = json.decode(responseBody);

      // ===============================
      // VALIDASI RESPONSE
      // ===============================
      if (decoded == null || decoded['status'] == null) {
        return {
          "status": "failed",
          "message": "Response tidak valid"
        };
      }

      return decoded;
    } catch (e) {
      print("Detection error: $e");

      return {
        "status": "failed",
        "message": "Tidak bisa terhubung ke server"
      };
    }
  }
}

// Untuk Emulator Android
  // static const String baseUrl = "http://10.0.2.2:5000";
  // untuk emulator dan ios = http://localhost:5000
  // Untuk HP asli (nanti ganti jika pakai device fisik)