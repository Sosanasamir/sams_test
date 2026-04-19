import 'package:flutter/material.dart';
import 'package:sams/provider/subjects_provider.dart';

class CoursesData {
  final String name;
  final Icon? icon;

  CoursesData({required this.name, this.icon, Object? IconData});

  factory CoursesData.fromSubjectsProvider(SubjectsProvider subject) {
    return CoursesData(
      name: SubjectsProvider().selectedSubjects.firstWhere((s) => s == subject.selectedSubjects.first, orElse: () => 'Unknown Course'),
      // Add other fields as needed, e.g., description: subject.description, etc.
    );
  }
}

final List<CoursesData> courses = [
  CoursesData(
    name: 'Information Management System',
    icon: Icon(Icons.info_outline_rounded),
  ),
  CoursesData(
    name: 'Artificial Intelligence',
    icon: Icon(Icons.smart_toy_outlined),
  ),
  CoursesData(name: 'Operating System', icon: Icon(Icons.memory_outlined)),
  CoursesData(name: 'English Language', icon: Icon(Icons.language_outlined)),
  CoursesData(name: 'Research Methods', icon: Icon(Icons.search_outlined)),
  CoursesData(
    name: 'Software Engineering',
    icon: Icon(Icons.engineering_outlined),
  ),
  CoursesData(
    name: 'Communication & Report Writing',
    icon: Icon(Icons.forum_outlined),
  ),
];
