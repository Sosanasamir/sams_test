import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sams/otp_screens/verify_otp.dart';

class ForgotUniIdScreen extends StatefulWidget {
  const ForgotUniIdScreen({super.key});

  @override
  State<ForgotUniIdScreen> createState() => _ForgotUniIdScreenState();
}

class _ForgotUniIdScreenState extends State<ForgotUniIdScreen> {
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() => errorMessage = 'Please enter your phone number');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/controllers/auth/send_otp.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      final data = jsonDecode(response.body);

      print('📥 Response data: $data'); // ✅ طباعة البيانات

      if (data['success'] == true) {
        // ✅ التحقق من نوع البيانات
        String otpCode = '';
        if (data['debug_otp'] is int) {
          otpCode = (data['debug_otp'] as int).toString();
        } else if (data['debug_otp'] is String) {
          otpCode = data['debug_otp'] as String;
        } else {
          otpCode = 'XXXXXX';
        }

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.security, color: Colors.green),
                  SizedBox(width: 10),
                  Text('OTP Code'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your verification code is:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      otpCode,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please use this code to verify your identity',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerifyOtpScreen(phone: phone),
                      ),
                    );
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() => errorMessage = data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => errorMessage = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Uni ID'),
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered phone number',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : sendOtp,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Send OTP',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}