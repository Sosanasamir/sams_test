import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sams/provider/user_provider.dart';
import 'package:sams/provider/doctor_provider.dart';
import 'package:sams/provider/admin_provider.dart';
import 'package:sams/tools/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _sendPost(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('http://10.0.2.2/api/controllers/$endpoint');
    print('📡 Calling API: $uri');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('خطأ ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Connection error: $e');
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'images/logo.png',
                width: 180,
                height: 180,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 180),
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Welcome back',
              style: TextStyle(
                color: Color.fromARGB(255, 6, 34, 78),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Create your account...',
              style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Form(
              key: formKey,
              child: Column(
                children: [
                  Customtextfield(
                    type: TextInputType.name,
                    controller: nameController,
                    label: 'Name',
                    maxLength: 40,
                    obscureText: false,
                  ),
                  const SizedBox(height: 15),
                  Customtextfield(
                    type: TextInputType.phone,
                    controller: phoneController,
                    label: 'Phone Number',
                    obscureText: false,
                    maxLength: 11,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required!';
                      }
                      if (value.length > 11) {
                        return 'Must be at most 11 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  Customtextfield(
                    type: TextInputType.text,
                    controller: idController,
                    label: 'Uni ID',
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required!';
                      }
                      if (value.length > 6 || value.length < 6) {
                        return 'Must be exactly 6 characters';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text(
                  'Already have an account? LogIn',
                  style: TextStyle(
                    color: Color.fromARGB(255, 6, 34, 78),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) return;

                    final enteredId = idController.text.trim().toLowerCase();
                    final name = nameController.text.trim();
                    final phone = phoneController.text.trim();

                    setState(() => isLoading = true);

                    try {
                      Map<String, dynamic> result;

                      if (enteredId.startsWith('st')) {
                        result = await _sendPost('auth/register_student.php', {
                          'full_name': name,
                          'uni_id': enteredId,
                          'phone': phone,
                        });
                        if (result['success'] == true) {
                          await context.read<UserProvider>().signUpInfo(
                            name: name,
                            phone: phone,
                            uniId: enteredId,
                          );
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/studentinfo');
                          }
                        }
                      } else if (enteredId.startsWith('dr')) {
                        result = await _sendPost('auth/register_doctor.php', {
                          'full_name': name,
                          'uni_id': enteredId,
                          'phone': phone,
                        });
                        if (result['success'] == true) {
                          await context.read<DoctorProvider>().signUpDoctor(
                            newName: name,
                            newId: enteredId,
                            newPhone: phone,
                          );
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/docinfo');
                          }
                        }
                      } else if (enteredId.startsWith('ad')) {
                        result = await _sendPost('auth/register_admin.php', {
                          'full_name': name,
                          'uni_id': enteredId,
                          'phone': phone,
                        });
                        if (result['success'] == true) {
                          await context.read<AdminProvider>().signUpAdmin(
                            newName: name,
                            newId: enteredId,
                            newPhone: phone,
                          );
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/adminhome');
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Uni ID يجب أن يبدأ بـ st أو dr أو ad')),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message'] ?? 'تم التسجيل بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('فشل التسجيل: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
                  child: const Text(
                    'SignUp',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}