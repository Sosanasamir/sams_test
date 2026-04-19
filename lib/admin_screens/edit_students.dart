import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sams/models/student_model.dart';

class EditStudentScreen extends StatefulWidget {
  final Student? student;
  final int? index;

  const EditStudentScreen({super.key, this.student, this.index});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameC;
  late TextEditingController uniIdC;
  late TextEditingController yearC;
  late TextEditingController subjectsC;
  late TextEditingController phoneC;
  late TextEditingController departmentC;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    print('فتح تعديل طالب: ${widget.student?.toJson() ?? "null"}');

    nameC = TextEditingController(text: widget.student?.full_name ?? "");
    uniIdC = TextEditingController(text: widget.student?.uni_id ?? "");
    yearC = TextEditingController(text: widget.student?.year.toString() ?? "");
    subjectsC = TextEditingController(
      text: widget.student?.subjects.join(", ") ?? "",
    );
    phoneC = TextEditingController(text: widget.student?.phone ?? "");
    departmentC = TextEditingController(
      text: widget.student?.department ?? "",
    );
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final subjectsList = subjectsC.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final updatedStudent = Student(
      status: widget.student?.status ?? 'pending',
      uni_id: uniIdC.text.trim(),
      full_name: nameC.text.trim(),
      year: int.tryParse(yearC.text.trim()) ?? widget.student!.year,
      subjects: subjectsList,
      department: departmentC.text.trim().isNotEmpty
          ? departmentC.text.trim()
          : null,
      phone: phoneC.text.trim().isNotEmpty ? phoneC.text.trim() : null,
    );
       


    print('محاولة تعديل: ${updatedStudent.toJson()}');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/data/update_student.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedStudent.toJson()),
      );

      print('رد السيرفر: ${response.statusCode} → ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('  edited successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, {
            'student': updatedStudent,
            'index': widget.index,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'فشل التعديل')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ سيرفر: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('خطأ محلي: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Student",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
      ),
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildField("Name", nameC),
                    buildField("Uni ID", uniIdC),
                    buildField("Year", yearC, TextInputType.number),
                    buildField("Subjects (separated by commas)", subjectsC),
                    buildField("Department", departmentC),
                    buildField("Phone", phoneC),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSaving ? null : saveChanges,
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildField(
    String label,
    TextEditingController controller, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: (v) => v?.isEmpty ?? true ? "Field is required  " : null,
      ),
    );
  }
}
