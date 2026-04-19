// lib/tools/subject_doc.dart

class SubjectSchedule {
  String subject;
  String? day;
  String? time;
  bool selected;
  int? courseId;

  SubjectSchedule(
    this.subject, {
    this.day,
    this.time,
    this.selected = false,
    this.courseId,
  });

  // ✅ دالة لتحويل JSON إلى كائن
  factory SubjectSchedule.fromJson(Map<String, dynamic> json) {
    return SubjectSchedule(
      json['subject'] as String,
      day: json['day'] as String?,
      time: json['time'] as String?,
      selected: json['selected'] as bool? ?? false,
      courseId: json['courseId'] as int?,
    );
  }

  // ✅ دالة لتحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'day': day,
      'time': time,
      'selected': selected,
      'courseId': courseId,
    };
  }
}
