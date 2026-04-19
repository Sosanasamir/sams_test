import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/doctor_provider.dart';

class DoctorScheduleScreen extends StatelessWidget {
  DoctorScheduleScreen({super.key});

  final List<String> days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
  ];

  int maxSubjects(Map<String, List<Map<String, String>>> scheduleMap) {
    int max = 0;
    for (var subjects in scheduleMap.values) {
      if (subjects.length > max) {
        max = subjects.length;
      }
    }
    return max;
  }

  Color getSubjectColor(String subject) {
    return const Color.fromARGB(255, 6, 34, 78);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DoctorProvider>();
    final double headerHeight = MediaQuery.of(context).size.height * 0.15;

    // ✅ استخدام المواعيد المقبولة فقط للجدول
    final approvedSubjects = provider.approvedSubjects;

    Map<String, List<Map<String, String>>> scheduleMap = {};
    for (var day in days) {
      scheduleMap[day] = approvedSubjects
          .where((s) => s.day == day && s.time != null)
          .map((s) => {'subject': s.subject, 'time': s.time!})
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: headerHeight,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 6, 34, 78),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(200),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 80,
                left: 50,
                child: Text(
                  'My Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: approvedSubjects.isEmpty
                ? const Center(
              child: Text(
                'No approved subjects yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  defaultColumnWidth: const FixedColumnWidth(140),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'Day',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        for (int i = 0; i < maxSubjects(scheduleMap); i++)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                'Subject ${i + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 6, 34, 78),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (var day in days)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 6, 34, 78),
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(maxSubjects(scheduleMap), (
                              index,
                              ) {
                            final subjects = scheduleMap[day]!;

                            if (subjects.length <= index) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox.shrink(),
                              );
                            }

                            final subjectName =
                            subjects[index]['subject']!;
                            final time = subjects[index]['time']!;

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: getSubjectColor(subjectName),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      subjectName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      time,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}