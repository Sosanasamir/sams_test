import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthServiceRealDevice {
  final String baseUrl = "http://192.168.1.12/api/controllers/";

  Future<Map<String, dynamic>> registerStudent({
    required String name,
    required String uniId,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/register_student.php'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'full_name': name, 'uni_id': uniId, 'phone': phone}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل التسجيل: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login({
    required String uniId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/login.php'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'uni_id': uniId, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل تسجيل الدخول: ${response.body}');
    }
  }
}