import 'dart:convert';

class Doctor {
  final String uni_id;
  final String full_name;
  final int year;
  final List<String> subjects;
  final String? department;
  final String? phone; 

  Doctor({
    required this.uni_id,
    required this.full_name,
    required this.year,
    required this.subjects,
    this.department,
    this.phone, 
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      uni_id: json['uni_id']?.toString() ?? '',
      full_name: json['full_name']?.toString() ?? '',
      year:
          int.tryParse(
            json['year']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
          ) ??
          0,
     subjects: json['doctor_subjects'] != null 
    ? (jsonDecode(json['doctor_subjects']) as List<dynamic>)
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item['subject'] as String? ?? '';
          } else if (item is String) {
            return item; 
          } else {
            return '';
          }
        })
        .where((s) => s.isNotEmpty)
        .toList()
    : [],
      department: json['department']?.toString(),
      phone: json['phone']?.toString(), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uni_id': uni_id,
      'full_name': full_name,
      'year': year,
      'subjects': subjects,
      if (department != null) 'department': department,
      if (phone != null) 'phone': phone, 
    };
  }
}
