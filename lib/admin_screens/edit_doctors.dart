import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sams/models/doctor_model.dart';

class EditDoctorScreen extends StatefulWidget {
  final Doctor? doctor;
  final int? index;

  const EditDoctorScreen({super.key, this.doctor, this.index});

  @override
  State<EditDoctorScreen> createState() => _EditDoctorScreenState();
}

class _EditDoctorScreenState extends State<EditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameC;
  late TextEditingController uniIdC;
  late TextEditingController yearC;
  late TextEditingController departmentC;
  late TextEditingController subjectsC;
  late TextEditingController phoneC;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    print('فتح تعديل دكتور: ${widget.doctor?.toJson() ?? "null"}');

    nameC = TextEditingController(text: widget.doctor?.full_name ?? "");
    uniIdC = TextEditingController(text: widget.doctor?.uni_id ?? "");
    yearC = TextEditingController(text: widget.doctor?.year.toString() ?? "");
    departmentC = TextEditingController(
      text: widget.doctor?.department ?? "",
    ); // ← أضف ده
    subjectsC = TextEditingController(
      text: widget.doctor?.subjects.join(", ") ?? "",
    );
    phoneC = TextEditingController(text: widget.doctor?.phone ?? "");
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final subjectsList = subjectsC.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final updatedDoctor = Doctor(
      uni_id: uniIdC.text.trim(),
      full_name: nameC.text.trim(),
      year: int.tryParse(yearC.text.trim()) ?? widget.doctor!.year,
      subjects: subjectsList,
      department: departmentC.text.trim().isNotEmpty
          ? departmentC.text.trim()
          : null,
      phone: phoneC.text.trim().isNotEmpty ? phoneC.text.trim() : null,
    );

    print('محاولة تعديل دكتور: ${updatedDoctor.toJson()}');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/data/update_doctor.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedDoctor.toJson()),
      );

      print('رد السيرفر: ${response.statusCode} → ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Update succesfuly'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, {
            'doctor': updatedDoctor,
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
        title: const Text("Edit Doctor", style: TextStyle(color: Colors.white)),
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
                    buildField("Department", departmentC),
                    buildField("Subjects (separated by commas)", subjectsC),
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
        validator: (v) => v?.isEmpty ?? true ? "Field is required" : null,
      ),
    );
  }
}
