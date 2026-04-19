import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminProvider extends ChangeNotifier {
  String name = '';
  String adminId = '';
  String phone = '';
  String email = '';
  String profileImage = ''; // ✅ جديد
  bool isLoggedIn = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// تحميل بيانات الأدمن
  Future<void> loadAdminData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    name = prefs.getString('admin_name') ?? '';
    adminId = prefs.getString('admin_id') ?? '';
    phone = prefs.getString('admin_phone') ?? '';
    email = prefs.getString('admin_email') ?? '';
    profileImage = prefs.getString('admin_profile_image') ?? ''; // ✅ جديد

    isLoggedIn = adminId.isNotEmpty;

    if (adminId.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse(
            'http://10.0.2.2/api/controllers/api_endpoints/get_admins.php?uni_id=$adminId',
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['data'] != null) {
            final adminData = data['data'];
            name = adminData['full_name'] ?? name;
            phone = adminData['phone'] ?? phone;
            email = adminData['email'] ?? email;
            profileImage = adminData['profile_image'] ?? ''; // ✅ جديد
            await saveAdminData();
          }
        }
      } catch (e) {
        print('خطأ في تحميل بيانات الأدمن: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// حفظ كل البيانات في SharedPreferences
  Future<void> saveAdminData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('admin_name', name);
    await prefs.setString('admin_id', adminId);
    await prefs.setString('admin_phone', phone);
    await prefs.setString('admin_email', email);
    await prefs.setString('admin_profile_image', profileImage); // ✅ جديد

    isLoggedIn = adminId.isNotEmpty;
    notifyListeners();
  }

  /// ✅ دالة رفع الصورة
  Future<void> updateProfileImage(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/api/controllers/api_endpoints/upload_profile_image.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uni_id': adminId, 'image_base64': base64Image}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        profileImage = data['image_url'] ?? '';
        await saveAdminData();
        notifyListeners();
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> signUpAdmin({
    required String newName,
    required String newId,
    required String newPhone,
    String newEmail = '',
  }) async {
    name = newName;
    adminId = newId;
    phone = newPhone;
    email = newEmail.isEmpty ? '$newId@sams.edu' : newEmail;
    await saveAdminData();
    await loadAdminData();
    notifyListeners();
  }

  Future<void> setLoginAdmin(
    String nameFromApi,
    String id,
    String phoneFromApi,
  ) async {
    adminId = id;
    name = nameFromApi;
    phone = phoneFromApi;
    email = '';
    await saveAdminData();
    await loadAdminData();
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('admin_name');
    await prefs.remove('admin_id');
    await prefs.remove('admin_phone');
    await prefs.remove('admin_email');
    await prefs.remove('admin_profile_image'); // ✅ جديد

    name = '';
    adminId = '';
    phone = '';
    email = '';
    profileImage = '';
    isLoggedIn = false;

    notifyListeners();
  }

  bool get isAdminLoggedIn => isLoggedIn;
}
