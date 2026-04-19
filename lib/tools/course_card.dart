import 'package:flutter/material.dart';
import 'package:sams/tools/courses_data.dart';

class CourseCard extends StatelessWidget {
  final CoursesData course;
  final String name;
  final IconData icon;

  const CourseCard({super.key, required this.course, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.black26,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Color.fromARGB(255, 6, 34, 78),
            ),
            SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color.fromARGB(255, 6, 34, 78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
