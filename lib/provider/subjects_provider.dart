import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubjectsProvider with ChangeNotifier {
  List<String> _selectedSubjects = [];           // المواد المختارة مؤقتًا (للجدول)
  List<dynamic> _enrolledCourses = [];           // المواد المسجلة فعليًا (من enrollments)

  List<String> get selectedSubjects => List.unmodifiable(_selectedSubjects);
  List<dynamic> get enrolledCourses => List.unmodifiable(_enrolledCourses);

  int get selectedCount => _selectedSubjects.length;

  bool isSelected(String subject) {
    return _selectedSubjects.contains(subject);
  }

  // تبديل حالة المادة (للاختيار المؤقت)
  void toggleSubject(String subject) {
    if (subject.trim().isEmpty) return;

    if (isSelected(subject)) {
      _selectedSubjects.remove(subject);
    } else {
      _selectedSubjects.add(subject);
    }
    notifyListeners();
    _saveToPrefs();
  }

  // تعيين المواد من الـ API (مثل في ScheduleScreen)
  void setSelectedSubjects(List<String> subjects) {
    _selectedSubjects = List.from(subjects)..sort();
    notifyListeners();
    _saveToPrefs();
  }

  // ====================== التسجيل الحقيقي (الجديد) ======================

  /// تسجيل مادة واحدة في قاعدة البيانات (enrollments)
  Future<bool> enrollCourse({
    required String uniId,
    required int courseId,
    required String courseName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/controllers/api_endpoints/enroll_course.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uni_id': uniId,
          'course_id': courseId,
          'course_name': courseName,   // اختياري للـ debug
        }),
      );

      print('📥 Enroll response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // إضافة المادة للقائمة المسجلة
          _enrolledCourses.add({
            'course_id': courseId,
            'course_name': courseName,
            'status': 'registered'
          });
          notifyListeners();
          print('✅ تم تسجيل المادة بنجاح: $courseName');
          return true;
        } else {
          print('❌ فشل التسجيل: ${data['message']}');
          return false;
        }
      }
      return false;
    } catch (e) {
      print('❌ خطأ في enrollCourse: $e');
      return false;
    }
  }

  // إضافة مادة بدون API (للاختيار المؤقت فقط)
  void addSubject(String subject) {
    final trimmed = subject.trim();
    if (trimmed.isEmpty || isSelected(trimmed)) return;
    _selectedSubjects.add(trimmed);
    notifyListeners();
    _saveToPrefs();
  }

  void removeSubject(String subject) {
    if (_selectedSubjects.remove(subject)) {
      notifyListeners();
      _saveToPrefs();
    }
  }

  void clearAll() {
    _selectedSubjects.clear();
    notifyListeners();
    _saveToPrefs();
  }

  bool get hasSelections => _selectedSubjects.isNotEmpty;

  // حفظ في SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selected_subjects', _selectedSubjects);
    } catch (e) {
      debugPrint('خطأ في حفظ المواد: $e');
    }
  }

  // تحميل من SharedPreferences
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('selected_subjects') ?? [];
      if (saved.isNotEmpty && !_listsEqual(_selectedSubjects, saved)) {
        _selectedSubjects = saved;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المواد: $e');
    }
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // حفظ المواد المختارة في قاعدة البيانات (الطريقة القديمة - لو لسه محتاجها)
  Future<void> saveSelectedSubjects(String uniId) async {
    if (_selectedSubjects.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/controllers/api_endpoints/save_subjects.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uni_id': uniId,
          'subjects': _selectedSubjects,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ تم حفظ المواد المختارة بنجاح');
        }
      }
    } catch (e) {
      print('❌ خطأ في saveSelectedSubjects: $e');
    }
  }
}