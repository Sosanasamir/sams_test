import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sams/models/student_model.dart';

class AdminStudentsProvider extends ChangeNotifier {
  List<Student> _students = [];

  List<Student> get students => List.unmodifiable(_students);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// جلب الطلاب من الـ API
  Future<void> loadStudents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2/api/data/get_students.php'))
          .timeout(const Duration(seconds: 10));

      print('رد loadStudents: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true) {
          final studentsJson = data['students'];

          if (studentsJson is List) {
            _students = studentsJson
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return Student.fromJson(item);
                  } else {
                    debugPrint('Invalid student item: $item');
                    return null;
                  }
                })
                .whereType<Student>()
                .toList();
          } else {
            _errorMessage = 'حقل students ليس قائمة';
          }
        } else {
          _errorMessage = data['message']?.toString() ?? 'فشل جلب الطلاب';
        }
      } else {
        _errorMessage =
            'خطأ في السيرفر: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = 'خطأ أثناء الجلب: $e';
      debugPrint('Error in loadStudents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة طالب جديد
  Future<bool> addStudent(Student student) async {
    print('محاولة إضافة طالب: ${student.toJson()}');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/data/add_student.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(student.toJson()),
      );

      print('رد add API: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _students.add(student);
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

  /// تعديل طالب موجود
  Future<bool> updateStudent(int index, Student updatedStudent) async {
    if (index < 0 || index >= _students.length) {
      _errorMessage = 'رقم الطالب غير صالح';
      notifyListeners();
      return false;
    }

    final oldStudent = _students[index];
    final oldStatus = oldStudent.status ?? 'pending';
    final newStatus = updatedStudent.status ?? 'pending';

    print('محاولة تعديل طالب: ${updatedStudent.toJson()}');
    print('الحالة القديمة: $oldStatus | الجديدة: $newStatus');

    try {
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/api/controllers/api_endpoints/approve_students.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedStudent.toJson()),
      );

      print('رد update API: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // ✅ تحديث الطالب في القائمة
          _students[index] = updatedStudent;
          notifyListeners();

          // ✅ إرسال الإشعار
          if (newStatus == 'accepted' || newStatus == 'rejected') {
            print(
              'إرسال إشعار لأن الحالة الجديدة: $newStatus (القديمة: $oldStatus)',
            );
            await _sendNotification(updatedStudent.uni_id, newStatus);
          }

          // ✅ PERFORMANCE FIX: Don't reload all students - just update locally
          // This prevents N+1 query pattern and significantly improves performance

          return true;
        } else {
          _errorMessage = data['message'] ?? 'فشل التعديل في الداتابيز';
        }
      } else {
        _errorMessage = 'خطأ في السيرفر: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'خطأ أثناء التعديل: $e';
      print('خطأ في updateStudent: $e');
    }

    notifyListeners();
    return false;
  }

  Future<bool> deleteStudent(int index) async {
    if (index < 0 || index >= _students.length) {
      _errorMessage = 'رقم الطالب غير صالح';
      notifyListeners();
      return false;
    }

    final student = _students[index];

    print('محاولة حذف طالب: uni_id = ${student.uni_id}');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/data/delete_student.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uni_id': student.uni_id}),
      );

      print('رد delete API: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _students.removeAt(index);
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

  /// دالة خاصة لإرسال إشعار للطالب
  Future<bool> _sendNotification(String uniId, String status) async {
    try {
      print('محاولة إرسال إشعار لـ uni_id: $uniId | status: $status');

      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/data/send_notification.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uni_id': uniId, 'status': status}),
      );

      print('رد إرسال إشعار: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('إشعار تم إرساله بنجاح');
          return true;
        } else {
          print('فشل إرسال الإشعار: ${data['message']}');
          return false;
        }
      } else {
        print('خطأ في السيرفر: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('خطأ في _sendNotification: $e');
      return false;
    }
  }

  // باقي الدوال (deleteStudent, clear, retryLoad) زي ما هي
}
