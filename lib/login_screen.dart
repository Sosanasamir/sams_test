import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sams/provider/doctor_provider.dart';
import 'package:sams/provider/user_provider.dart';
import 'package:sams/provider/admin_provider.dart';

import 'package:sams/tools/custom_textfield.dart';

import 'otp_screens/forget_uni_id_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final idController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  @override
  void dispose() {
    idController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final enteredId = idController.text.trim().toLowerCase();
    final phone = phoneController.text.trim();

    if (enteredId.isEmpty || phone.isEmpty) {
      setState(() {
        errorMessage = 'Please fill Uni ID and Phone';
      });
      return;
    }

    String role = '';
    if (enteredId.startsWith('st')) {
      role = 'student';
    } else if (enteredId.startsWith('dr')) {
      role = 'advisor';
    } else if (enteredId.startsWith('ad')) {
      role = 'admin';
    } else {
      setState(() {
        errorMessage = 'صيغة Uni ID غير صحيحة';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // استخدام ApiHelper عشان يختار Emulator أو Real Device تلقائياً
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/controllers/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uni_id': enteredId, 'phone': phone}),
      );

      print('📥 Login response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final userData = data['data'] ?? {};

          if (role == 'student') {
            await context.read<UserProvider>().setLoginUser(
              userData['name'] ?? '',
              enteredId,
            );
            Navigator.pushReplacementNamed(context, '/home');
          } else if (role == 'advisor') {
            await context.read<DoctorProvider>().setLoginDoctor(
              userData['name'] ?? '',
              enteredId,
              userData['phone'] ?? phone,
            );
            Navigator.pushReplacementNamed(context, '/dochome');
          } else if (role == 'admin') {
            await context.read<AdminProvider>().setLoginAdmin(
              userData['name'] ?? '',
              enteredId,
              userData['phone'] ?? phone,
            );
            await context.read<AdminProvider>().loadAdminData();
            Navigator.pushReplacementNamed(context, '/adminhome');
          }
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'بيانات خاطئة';
          });
        }
      } else {
        setState(() {
          errorMessage = 'خطأ في السيرفر: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ: $e';
      });
      print('❌ Login error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('images/logo.png', width: 180, height: 180),
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
              'LogIn into your account...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Form(
              key: formKey,
              child: Column(
                children: [
                  Customtextfield(
                    type: TextInputType.text,
                    controller: idController,
                    label: 'Uni ID',
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  Customtextfield(
                    type: TextInputType.phone,
                    controller: phoneController,
                    label: 'Phone Number',
                    obscureText: false,
                  ),
                ],
              ),
            ),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/signup'),
                child: const Text(
                  'Don\'t have an account? SignUp',
                  style: TextStyle(
                    color: Color.fromARGB(255, 6, 34, 78),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child:
              TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotUniIdScreen()),
                );
              },
              child: const Text(
                'Forgot Uni ID?',
                style: TextStyle(
                  color: Color.fromARGB(255, 6, 34, 78),
                  fontSize: 14,
                ),
              ),
            ),),

            const SizedBox(height: 25),
            Center(
              child: SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoading ? null : login,
                  child: const Text(
                    'LogIn',
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
