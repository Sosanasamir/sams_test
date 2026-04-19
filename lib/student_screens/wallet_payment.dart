import 'package:flutter/material.dart';

// ignore: must_be_immutable
class WalletPaymentPage extends StatelessWidget {
  WalletPaymentPage({super.key, this.phoneNumber});

  int? phoneNumber;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'E-Wallet Payment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 11,
                validator: (value) => (value?.isEmpty ?? true) ? 'Phone number is required' : value!.length < 11
                    ? 'Invalid phone number'
                    : value.length > 11
                    ? 'Invalid phone number'
                    : null,
                onChanged: (val) => phoneNumber = int.tryParse(val) ?? 0,
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Future.delayed(const Duration(seconds: 2), () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment Successful!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/', // ← اسم route الـ home page
                      (route) => false,
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  'Pay Now - 5410 EGP',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
