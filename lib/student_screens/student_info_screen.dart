import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sams/provider/user_provider.dart';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  String? selectedYear;
  String? selectedDepartment;

  final List<String> years = ['1', '2', '3', '4'];

  final List<String> departments = [
    'Marketing',
    'Accounting',
    'Human Resources',
    'IT',
    'Finance',
    'Bank Management',
  ];

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Tell us about your study information..',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 6, 34, 78),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Year',
                style: TextStyle(
                  color: Color.fromARGB(255, 19, 53, 105),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: selectedYear,
                validator: (value) =>
                    value == null ? 'please select your year!' : null,
                items: years
                    .map(
                      (year) =>
                          DropdownMenuItem(value: year, child: Text(year)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedYear = value),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Department',
                style: TextStyle(
                  color: Color.fromARGB(255, 19, 53, 105),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: selectedDepartment,
                validator: (value) =>
                    value == null ? 'please select your department!' : null,
                items: departments
                    .map(
                      (dep) => DropdownMenuItem(value: dep, child: Text(dep)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedDepartment = value),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                ),
              ),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      (selectedYear == null || selectedDepartment == null)
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final userProvider = context.read<UserProvider>();
                            setState(() => isLoading = true);

                            try {
                              // ✅ تعديل المسار
                              final response = await http.post(
                                Uri.parse(
                                  'http://10.0.2.2/api/controllers/api_endpoints/save_info.php',
                                ),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Accept': 'application/json',
                                },
                                body: jsonEncode({
                                  'uni_id': userProvider.uniId,
                                  'year': selectedYear,
                                  'department': selectedDepartment,
                                }),
                              );

                              print(
                                '📥 Save study info response: ${response.statusCode} - ${response.body}',
                              );

                              if (response.statusCode == 200) {
                                final data = jsonDecode(response.body);
                                if (data['success'] == true) {
                                  userProvider.setStudyInfo(
                                    selectedYear!,
                                    selectedDepartment!,
                                  );
                                  Navigator.pushNamed(context, '/home');
                                } else {
                                  setState(
                                    () => errorMessage =
                                        data['message'] ?? 'فشل الحفظ',
                                  );
                                }
                              } else {
                                setState(
                                  () => errorMessage =
                                      'خطأ في السيرفر: ${response.statusCode}',
                                );
                              }
                            } catch (e) {
                              setState(() => errorMessage = 'خطأ: $e');
                              print('❌ Save study info error: $e');
                            } finally {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
