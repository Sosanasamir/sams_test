import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String name = '';
  String phone = '';
  String uniId = '';
  String year = '';
  String department = '';
  String profileImage = ''; // ✅ جديد

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    uniId = prefs.getString('uniId') ?? '';
    name = prefs.getString('name') ?? '';
    phone = prefs.getString('phone') ?? '';
    year = prefs.getString('year') ?? '';
    department = prefs.getString('department') ?? '';
    profileImage = prefs.getString('profile_image') ?? ''; // ✅ جديد

    if (uniId.isNotEmpty) {
      await refreshFromApi();
    }
    notifyListeners();
  }

  Future<void> refreshFromApi() async {
    if (uniId.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2/api/controllers/api_endpoints/get_user_info.php?uni_id=$uniId',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data'];
          name = userData['full_name'] ?? name;
          phone = userData['phone'] ?? phone;
          year = userData['year']?.toString() ?? year;
          department = userData['department'] ?? department;
          profileImage = userData['profile_image'] ?? ''; // ✅ جديد
          await saveUserData();
        }
      }
    } catch (e) {
      print('❌ Error refreshing user data: $e');
    }
    notifyListeners();
  }

  Future<void> saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('phone', phone);
    await prefs.setString('uniId', uniId);
    await prefs.setString('year', year);
    await prefs.setString('department', department);
    await prefs.setString('profile_image', profileImage); // ✅ جديد
  }

  Future<void> setLoginUser(String newName, String newUniId) async {
    name = newName;
    uniId = newUniId;
    await saveUserData();
    await refreshFromApi();
    notifyListeners();
  }

  Future<void> setStudyInfo(String newYear, String newDepartment) async {
    year = newYear;
    department = newDepartment;
    await saveUserData();
    notifyListeners();
  }

  // ✅ دالة رفع الصورة
  Future<void> updateProfileImage(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/api/controllers/api_endpoints/upload_profile_image.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uni_id': uniId, 'image_base64': base64Image}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        profileImage = data['image_url'] ?? '';
        await saveUserData();
        notifyListeners();
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    name = '';
    phone = '';
    uniId = '';
    year = '';
    department = '';
    profileImage = '';
    notifyListeners();
  }

  Future<void> signUpInfo({
    required String name,
    required String phone,
    required String uniId,
  }) async {
    this.name = name;
    this.phone = phone;
    this.uniId = uniId;
    await saveUserData();
    notifyListeners();
  }
}
