import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sams/models/doctor_model.dart';

class AdminDoctorsProvider extends ChangeNotifier {
  List<Doctor> _doctors = [];

  List<Doctor> get doctors => List.unmodifiable(_doctors);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// جلب الدكاترة من الـ API
  Future<void> loadDoctors() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2/api/data/get_doctors.php'))
          .timeout(const Duration(seconds: 10));

      print('رد get_doctors: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // تحقق إن data هو Map وفيه success
        if (data is Map<String, dynamic> && data['success'] == true) {
          final doctorsData = data['doctors'];

          // تحقق إن doctorsData هو List قبل الـ map
          if (doctorsData is List) {
            _doctors = doctorsData
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return Doctor.fromJson(item);
                  } else {
                    print('عنصر غير صالح في قائمة الدكاترة: $item');
                    return null;
                  }
                })
                .whereType<Doctor>()
                .toList();
          } else {
            _errorMessage =
                'حقل "doctors" مش قائمة (List)، نوعه: ${doctorsData.runtimeType}';
            print('نوع doctorsData: ${doctorsData.runtimeType}');
          }
        } else {
          _errorMessage = data is Map
              ? (data['message'] ?? 'فشل جلب الدكاترة - الرد غير صالح')
              : 'الرد من السيرفر غير صالح';
        }
      } else {
        _errorMessage =
            'خطأ في السيرفر: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e, stack) {
      _errorMessage = 'خطأ أثناء الجلب: $e';
      print('Error in loadDoctors: $e');
      print('Stack trace: $stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة دكتور جديد
  Future<bool> addDoctor(Doctor doctor) async {
    print('محاولة إضافة دكتور: ${doctor.toJson()}');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/data/add_doctor.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(doctor.toJson()),
      );

      print('رد add_doctor API: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _doctors.add(doctor);
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'فشل الإضافة في الداتابيز';
          print('فشل الإضافة في الداتابيز: ${data['message']}');
        }
      } else {
        _errorMessage = 'خطأ سيرفر في الإضافة: ${response.statusCode}';
        print('خطأ سيرفر: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'خطأ أثناء الإضافة: $e';
      print('خطأ محلي في الإضافة: $e');
    }

    notifyListeners();
    return false;
  }

  /// تعديل دكتور موجود
  Future<bool> updateDoctor(int index, Doctor updatedDoctor) async {
    if (index < 0 || index >= _doctors.length) {
      _errorMessage = 'رقم الدكتور غير صالح';
      notifyListeners();
      return false;
    }

    print('محاولة تعديل دكتور في الـ Provider: ${updatedDoctor.toJson()}');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/data/update_doctor.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedDoctor.toJson()),
      );

      print('رد update_doctor API: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _doctors[index] = updatedDoctor;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'فشل التعديل في الداتابيز';
          print('فشل التعديل في الداتابيز: ${data['message']}');
        }
      } else {
        _errorMessage = 'خطأ في السيرفر: ${response.statusCode}';
        print('خطأ سيرفر: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'خطأ أثناء التعديل: $e';
      print('خطأ محلي في التعديل: $e');
    }

    notifyListeners();
    return false;
  }

  /// حذف دكتور
  Future<bool> deleteDoctor(int index) async {
    if (index < 0 || index >= _doctors.length) {
      _errorMessage = 'رقم الدكتور غير صالح';
      notifyListeners();
      return false;
    }

    final doctor = _doctors[index];

    print('محاولة حذف دكتور: uni_id = ${doctor.uni_id}');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/data/delete_doctor.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uni_id': doctor.uni_id}),
      );

      print('رد delete_doctor API: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _doctors.removeAt(index);
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'فشل الحذف في الداتابيز';
          print('فشل الحذف في الداتابيز: ${data['message']}');
        }
      } else {
        _errorMessage = 'خطأ سيرفر في الحذف: ${response.statusCode}';
        print('خطأ سيرفر: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'خطأ أثناء الحذف: $e';
      print('خطأ محلي في الحذف: $e');
    }

    notifyListeners();
    return false;
  }

  void clear() {
    _doctors.clear();
    notifyListeners();
  }

  Future<void> retryLoad() => loadDoctors();
}
