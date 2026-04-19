import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:sams/provider/doctor_provider.dart';
import 'package:sams/provider/notification_provider.dart';
import 'package:sams/doctor_screens/doctor_profile_screen.dart';
import 'package:sams/doctor_screens/doctor_schedule_screen.dart';
import 'package:sams/doctor_screens/course_student_registered.dart';
import 'package:sams/doctor_screens/Notification_Screen.dart';

class DocotorHomeScreen extends StatefulWidget {
  const DocotorHomeScreen({super.key});

  @override
  DocotorHomeScreenState createState() => DocotorHomeScreenState();
}

class DocotorHomeScreenState extends State<DocotorHomeScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctor = context.read<DoctorProvider>();
      if (doctor.docId.isNotEmpty) {
        context.read<NotificationProvider>().loadNotifications(doctor.docId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ PERFORMANCE FIX: Use select() instead of watch() to minimize rebuilds
    final docName = context.select<DoctorProvider, String>((p) => p.name);
    final docDept = context.select<DoctorProvider, String>((p) => p.department);
    final docYear = context.select<DoctorProvider, String>((p) => p.year);
    final mySubjects = context.select<DoctorProvider, List>(
      (p) => p.mySubjects,
    );

    final notifCount = context.select<NotificationProvider, int>(
      (p) => p.unreadCount,
    );
    late Widget currentScreen;

    if (selectedIndex == 0) {
      currentScreen = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header زي الطالب بالضبط
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 6, 34, 78),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Dr. ${docName.isEmpty ? 'Doctor' : docName}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Department: ${docDept.isEmpty ? 'Not specified' : docDept} | Year: ${docYear.isEmpty ? 'Not specified' : docYear}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Subjects',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          Expanded(
            child: mySubjects.isEmpty
                ? const Center(
                    child: Text(
                      'No subjects assigned yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemExtent: 80,
                    padding: const EdgeInsets.all(16),
                    itemCount: mySubjects.length,
                    itemBuilder: (context, index) {
                      final subject = mySubjects[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.book, color: Colors.blue),
                          title: Text(subject.subject),
                          subtitle: Text(
                            subject.day != null && subject.time != null
                                ? 'Day: ${subject.day} | Time: ${subject.time}'
                                : 'No schedule yet',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            String courseName = subject.subject;
                            int? courseId = subject.courseId;

                            if (courseId == null || courseId == 0) {
                              courseId = await context
                                  .read<DoctorProvider>()
                                  .getCourseIdByName(courseName);
                            }

                            if (courseId == null || courseId == 0) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Course ID not found for this subject',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }

                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseStudentsScreen(
                                    courseName: courseName,
                                    courseId: courseId,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    } else if (selectedIndex == 1) {
      currentScreen = DoctorScheduleScreen();
    } else {
      currentScreen = const DoctorProfileScreen();
    }

    return Scaffold(
      // ✅ حذف الـ AppBar وخلي الإشعارات في الـ Header
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        selectedItemColor: const Color.fromARGB(255, 6, 34, 78),
        unselectedItemColor: Colors.grey[500],
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart_outlined),
            label: 'My Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      // ✅ أضف FloatingActionButton للإشعارات (زي الطالب)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
        child: Stack(
          children: [
            const Icon(Icons.notifications, color: Colors.white),
            if (notifCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '$notifCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
