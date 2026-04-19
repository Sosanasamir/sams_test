import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/doctor_provider.dart';
import 'package:sams/tools/subject_doc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorcourseScreen extends StatefulWidget {
  const DoctorcourseScreen({super.key});

  @override
  State<DoctorcourseScreen> createState() => _DoctorcourseScreenState();
}

class _DoctorcourseScreenState extends State<DoctorcourseScreen> {
  late List<SubjectSchedule> subjects;
  bool isLoadingCourses = true;
  Map<String, int> courseIds = {};


  final List<String> subjectNames = [
    'Artificial Intelligence',
    'English 7',
    'Operating Systems',
    'Information Management System',
    'Communication&Reporting',
    'Software Engineering',
  ];


  final List<String> dayOptions = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
  ];
  final List<String> timeOptions = ['9 - 11', '11 - 1', '1 - 3', '3 - 5'];

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchCourseIds();
  }

  Future<void> _fetchCourseIds() async {
    setState(() {
      isLoadingCourses = true;
    });

    for (var subjectName in subjectNames) {
      try {
        final response = await http.get(
          Uri.parse('http://10.0.2.2/api/controllers/api_endpoints/get_course_id_by_name.php?course_name=${Uri.encodeComponent(subjectName)}'),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['course_id'] != null) {
            courseIds[subjectName] = data['course_id'];
            print('✅ Found courseId for $subjectName: ${data['course_id']}');
          }
        }
      } catch (e) {
        print('❌ Error fetching courseId for $subjectName: $e');
      }
    }

    // إنشاء المواد مع courseId
    subjects = subjectNames.map((e) {
      return SubjectSchedule(
        e,
        day: null,
        time: null,
        courseId: courseIds[e],
      );
    }).toList();

    setState(() {
      isLoadingCourses = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Tell us about your teaching info',
                  style: TextStyle(
                    color: Color.fromARGB(255, 6, 34, 78),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Subjects',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 6, 34, 78),
                ),
              ),
              SizedBox(height: 10),
              if (isLoadingCourses)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final item = subjects[index];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                value: item.selected,
                                title: Text(item.subject),
                                onChanged: (value) {
                                  setState(() {
                                    item.selected = value ?? false;
                                    if (!item.selected) {
                                      item.day = null;
                                      item.time = null;
                                    }
                                  });
                                },
                              ),
                              if (item.selected) ...[
                                DropdownButtonFormField<String>(
                                  hint: Text('Select day'),
                                  value: dayOptions.contains(item.day)
                                      ? item.day
                                      : null,
                                  items: dayOptions
                                      .map(
                                        (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(d),
                                    ),
                                  )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      item.day = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 18),
                                DropdownButtonFormField<String>(
                                  hint: Text('Select time'),
                                  value: timeOptions.contains(item.time)
                                      ? item.time
                                      : null,
                                  items: timeOptions
                                      .map(
                                        (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ),
                                  )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      item.time = value;
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoadingCourses
                      ? null
                      : () async {
                    final selected = subjects
                        .where(
                          (s) => s.selected && s.day != null && s.time != null,
                    )
                        .toList();

                    if (selected.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select subject, day and time'),
                        ),
                      );
                      return;
                    }

                    // التحقق من تعارض المواعيد
                    final conflicts = <String>{};
                    bool hasConflict = false;
                    for (var s in selected) {
                      final key = '${s.day}-${s.time}';
                      if (conflicts.contains(key)) {
                        hasConflict = true;
                        break;
                      }
                      conflicts.add(key);
                    }

                    if (hasConflict) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You cannot select two subjects at the same day and time',
                          ),
                        ),
                      );
                      return;
                    }

                    // حفظ البيانات في Provider
                    context.read<DoctorProvider>().setDoctorInfo(selected);

                    // الانتقال للشاشة الرئيسية للدكتور
                    Navigator.pushReplacementNamed(context, '/dochome');
                  },
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}