import 'dart:convert';
class Student {
  final String uni_id; 
  final String full_name; 
  final int year;
  final List<String> subjects;
  final String? phone;
  final String? department;
  final String? status;  
  Student({
    required this.uni_id,
    required this.full_name,
    required this.year,
    required this.subjects,
    this.phone,
    this.department, 
    required this.status,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      uni_id: json['uni_id']?.toString() ?? '',
      full_name: json['full_name']?.toString() ?? '',
      year:
          int.tryParse(
            json['level']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ??
                '0', 
          ) ??
          0,
      subjects: List<String>.from(json['subjects'] ?? []),
      phone: json['phone']?.toString(),
      department: json['department']?.toString(),
      status: json['status']?.toString() ?? 'pending', 
    );
  }
  // ignore: recursive_getters
  Map<String, dynamic> toJson() {
    return {
      'uni_id': uni_id,
      'full_name': full_name,
      'year': year.toString(), 
      'phone': phone,
      'department': department,
      'status': status,
      'selected_subjects': jsonEncode(subjects), 
    };
  }
}
