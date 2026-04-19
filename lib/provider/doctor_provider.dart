import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sams/tools/subject_doc.dart';

class DoctorProvider with ChangeNotifier {
  String name = '';
  String phone = '';
  String docId = '';
  String year = '';
  String department = '';
  String profileImage = ''; // ✅ جديد

  List<SubjectSchedule> _allSubjects = [];
  List<SubjectSchedule> _approvedSubjects = [];

  List<SubjectSchedule> get allSubjects => _allSubjects;
  List<SubjectSchedule> get mySubjects => _allSubjects;
  List<SubjectSchedule> get approvedSubjects => _approvedSubjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadDoctorData() async {
    print('بدأ loadDoctorData - الاسم قبل أي حاجة: [$name]');
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    name = prefs.getString('doc_name') ?? '';
    phone = prefs.getString('doc_phone') ?? '';
    docId = prefs.getString('doc_id') ?? '';
    department = prefs.getString('doc_department') ?? '';
    year = prefs.getString('doc_year') ?? '';
    profileImage = prefs.getString('doc_profile_image') ?? ''; // ✅ جديد

    final subjectsJson = prefs.getString('doc_subjects_json');
    if (subjectsJson != null && subjectsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(subjectsJson);
        _allSubjects = decoded.map((e) {
          if (e is String) {
            return SubjectSchedule(e, day: null, time: null);
          } else {
            return SubjectSchedule.fromJson(e as Map<String, dynamic>);
          }
        }).toList();
      } catch (e) {
        _allSubjects = [];
      }
    }

    if (docId.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse(
            'http://10.0.2.2/api/controllers/api_endpoints/get_doctors_profile.php?uni_id=$docId',
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['data'] != null) {
            final doctorData = data['data'];

            name = doctorData['full_name'] ?? name;
            phone = doctorData['phone'] ?? phone;
            department = doctorData['department'] ?? department;
            year = doctorData['year']?.toString() ?? year;
            profileImage = doctorData['profile_image'] ?? ''; // ✅ جديد

            if (doctorData['doctor_subjects'] != null) {
              try {
                dynamic subjectsRaw = doctorData['doctor_subjects'];
                List<dynamic> decoded = [];

                if (subjectsRaw is String) {
                  decoded = jsonDecode(subjectsRaw);
                } else if (subjectsRaw is List) {
                  decoded = subjectsRaw;
                }

                _allSubjects = decoded.map((e) {
                  if (e is String) {
                    return SubjectSchedule(e, day: null, time: null);
                  } else {
                    return SubjectSchedule.fromJson(e as Map<String, dynamic>);
                  }
                }).toList();
              } catch (e) {
                _allSubjects = [];
              }
            }

            await saveDoctorData();
            notifyListeners();
          }
        }
      } catch (e) {
        print('Error refreshing doctor data: $e');
      }
    }

    await loadApprovedSubjects();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveDoctorData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('doc_name', name);
    await prefs.setString('doc_phone', phone);
    await prefs.setString('doc_id', docId);
    await prefs.setString('doc_year', year);
    await prefs.setString('doc_department', department);
    await prefs.setString('doc_profile_image', profileImage); // ✅ جديد

    if (_allSubjects.isNotEmpty) {
      try {
        final jsonList = _allSubjects.map((s) => s.toJson()).toList();
        await prefs.setString('doc_subjects_json', jsonEncode(jsonList));
      } catch (e) {}
    } else {
      await prefs.remove('doc_subjects_json');
    }
  }

  /// ✅ دالة رفع الصورة
  Future<void> updateProfileImage(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/api/controllers/api_endpoints/upload_profile_image.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uni_id': docId, 'image_base64': base64Image}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        profileImage = data['image_url'] ?? '';
        await saveDoctorData();
        notifyListeners();
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // باقي الدوال كما هي...
  void setDoctorInfo(List<SubjectSchedule> subjects) {
    _allSubjects = List.from(subjects);
    saveDoctorData();
    saveSubjectsToDatabase();
    notifyListeners();
  }

  Future<void> saveSubjectsToDatabase() async {
    try {
      List<Map<String, dynamic>> subjectsWithIds = [];

      for (var subject in _allSubjects) {
        int? courseId = subject.courseId;
        if (courseId == null || courseId == 0) {
          courseId = await getCourseIdByName(subject.subject);
        }
        subjectsWithIds.add({
          'subject': subject.subject,
          'day': subject.day,
          'time': subject.time,
          'selected': subject.selected,
          'courseId': courseId,
        });
      }

      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/api/controllers/api_endpoints/save_doctor_subjects.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uni_id': docId, 'subjects': subjectsWithIds}),
      );

      if (response.statusCode == 200) {
        print('✅ تم حفظ مواد الدكتور في قاعدة البيانات');
      }
    } catch (e) {
      print('❌ خطأ في حفظ المواد: $e');
    }
  }

  Future<void> loadApprovedSubjects() async {
    if (docId.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2/api/controllers/api_endpoints/get_doctor_schedule.php?uni_id=$docId',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> subjectsJson = data['subjects'] ?? [];
          _approvedSubjects = subjectsJson
              .map((e) => SubjectSchedule.fromJson(e as Map<String, dynamic>))
              .toList();
          notifyListeners();
        } else {
          _approvedSubjects.clear();
          notifyListeners();
        }
      }
    } catch (e) {
      print('خطأ في تحميل المواد من قاعدة البيانات: $e');
    }
  }

  Future<int?> getCourseIdByName(String courseName) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2/api/controllers/api_endpoints/get_courses_id_by_name.php?course_name=${Uri.encodeComponent(courseName)}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['course_id'] != null) {
          return data['course_id'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> setStudyInfo(String newYear, String newDepartment) async {
    year = newYear;
    department = newDepartment;
    try {
      await http.post(
        Uri.parse(
          'http://10.0.2.2/api/controllers/api_endpoints/update_doctor_profile.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uni_id': docId,
          'year': newYear,
          'department': newDepartment,
        }),
      );
    } catch (e) {
      print('❌ خطأ في تحديث السنة والقسم: $e');
    }
    await saveDoctorData();
    notifyListeners();
  }

  Future<void> updateSubject(int index, String day, String time) async {
    if (index >= 0 && index < _allSubjects.length) {
      _allSubjects[index].day = day;
      _allSubjects[index].time = time;
      await saveDoctorData();
      notifyListeners();
    }
  }

  Future<void> signUpDoctor({
    required String newName,
    required String newId,
    required String newPhone,
  }) async {
    name = newName;
    docId = newId;
    phone = newPhone;
    await saveDoctorData();
    notifyListeners();
  }

  Future<void> setLoginDoctor(
    String newName,
    String newId,
    String newPhone,
  ) async {
    name = newName;
    docId = newId;
    phone = newPhone;
    await saveDoctorData();
    await loadDoctorData();
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    name = '';
    phone = '';
    docId = '';
    year = '';
    department = '';
    profileImage = '';
    _allSubjects.clear();
    _approvedSubjects.clear();
    notifyListeners();
  }
}
