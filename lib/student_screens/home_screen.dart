import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sams/provider/notification_provider.dart';
import 'package:sams/provider/user_provider.dart';
import 'package:sams/student_screens/payment_page.dart';
import 'package:sams/student_screens/profile_screen.dart';
import 'package:sams/provider/subjects_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  int selectedIndex = 0;

  List<dynamic> enrolledCourses = [];
  List<dynamic> passedCourses = [];
  List<dynamic> availableCourses = [];
  List<dynamic> lockedCourses = [];

  bool isLoading = true;
  String errorMessage = '';
  bool _subjectsChanged = false;
  bool isCleanStudent = false;
  bool isApproved = false; // ✅ متغير جديد

  @override
  void initState() {
    super.initState();
    fetchStudentCoursesStatus();

    // ✅ PERFORMANCE FIX: Load notifications only once per session, not per screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false);
      final notifProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      // Only load if not already loaded
      if (notifProvider.notifications.isEmpty) {
        notifProvider.loadNotifications(user.uniId);
      }
    });
  }

  @override
  void dispose() {
    _saveSubjects();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _enrollCourse(int courseId, String courseName) async {
    // ✅ منع التسجيل إذا لم يوافق الأدمن
    if (!isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your account is pending approval. Please wait for admin approval.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = context.read<UserProvider>();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enrolling in $courseName...'),
        backgroundColor: Colors.blue,
      ),
    );

    try {
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/api/controllers/api_endpoints/enroll_course.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uni_id': user.uniId, 'course_id': courseId}),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Successfully enrolled in $courseName'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await fetchStudentCoursesStatus();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Enrollment failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> fetchStudentCoursesStatus() async {
    final user = Provider.of<UserProvider>(context, listen: false);
    final url =
        'http://10.0.2.2/api/controllers/api_endpoints/get_student_courses.php?uni_id=${user.uniId}';

    if (!mounted) return;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            enrolledCourses = data['enrolled_courses'] ?? [];
            passedCourses = data['passed_courses'] ?? [];
            availableCourses = data['available_courses'] ?? [];
            lockedCourses = data['locked_courses'] ?? [];
            isCleanStudent = data['is_clean_student'] ?? false;
            isApproved = data['is_approved'] ?? false; // ✅ تحديث حالة الموافقة
            isLoading = false;
            errorMessage = '';
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'فشل جلب حالة المواد';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'خطأ في السيرفر: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في الاتصال: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _saveSubjects() async {
    if (!_subjectsChanged) return;

    final user = Provider.of<UserProvider>(context, listen: false);
    final subjectsProvider = Provider.of<SubjectsProvider>(
      context,
      listen: false,
    );

    await subjectsProvider.saveSelectedSubjects(user.uniId);
    _subjectsChanged = false;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ المواد بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ PERFORMANCE FIX: Use select() instead of watch() to minimize rebuilds
    final userName = context.select<UserProvider, String>((user) => user.name);
    final userYear = context.select<UserProvider, String>((user) => user.year);
    final userDept = context.select<UserProvider, String>(
      (user) => user.department,
    );

    // Only rebuild when notifications list changes, not entire provider
    final notifications = context.select<NotificationProvider, List>(
      (provider) => provider.notifications,
    );

    late Widget currentScreen;

    if (selectedIndex == 0) {
      if (isLoading) {
        currentScreen = const Center(child: CircularProgressIndicator());
      } else if (errorMessage.isNotEmpty) {
        currentScreen = Center(
          child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
        );
      } else {
        currentScreen = CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 6, 34, 78),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${userName.isEmpty ? 'Student' : userName}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Year: ${userYear.isEmpty ? 'Not specified' : userYear} | Department: ${userDept.isEmpty ? 'Not specified' : userDept}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    // ✅ إظهار حالة الموافقة
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isApproved ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isApproved
                            ? '✓ Account Approved'
                            : '⏳ Pending Approval',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (notifications.isNotEmpty)
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.amber[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Latest Notifications',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        ...notifications
                            .take(3)
                            .map(
                              (notif) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      notif.type == 'accept' ||
                                              notif.type == 'accepted'
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 18,
                                      color:
                                          notif.type == 'accept' ||
                                              notif.type == 'accepted'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notif.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            notif.message,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  isCleanStudent
                      ? 'Available Courses (${availableCourses.length})'
                      : 'Available Courses (${availableCourses.length})',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ),

            if (availableCourses.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No Courses Available Now',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final course = availableCourses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(course['course_name'] ?? 'Unknown'),
                      subtitle: Text(
                        'Code: ${course['course_code']} | Hours: ${course['credit_hours']}',
                      ),
                      trailing: ElevatedButton(
                        // ✅ زر Enroll مقفول إذا لم يوافق الأدمن
                        onPressed: isApproved
                            ? () => _enrollCourse(
                                course['course_id'],
                                course['course_name'],
                              )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApproved
                              ? Colors.green
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Enroll',
                          style: TextStyle(
                            color: isApproved ? Colors.white : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: availableCourses.length),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Locked Courses (${lockedCourses.length})',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
              ),
            ),

            if (lockedCourses.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No Courses Locked Now',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = lockedCourses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    color: Colors.red[50],
                    child: ListTile(
                      title: Text(item['course_name'] ?? 'Unknown'),
                      subtitle: Text(item['course_code'] ?? 'N/A'),
                      trailing: Text(
                        item['prerequisite_name'] ?? 'Missing prerequisite',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }, childCount: lockedCourses.length),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      }
    } else if (selectedIndex == 1) {
      currentScreen = const ProfileScreen();
    } else if (selectedIndex == 2) {
      currentScreen = const PaymentPage();
    } else {
      currentScreen = Container();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        selectedItemColor: const Color.fromARGB(255, 6, 34, 78),
        unselectedItemColor: Colors.grey[500],
        currentIndex: selectedIndex,
        onTap: (value) async {
          await _saveSubjects();
          if (mounted) {
            setState(() => selectedIndex = value);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payment'),
        ],
      ),
    );
  }
}
