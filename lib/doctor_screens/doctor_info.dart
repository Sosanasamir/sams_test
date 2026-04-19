import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/doctor_provider.dart';

class DoctorInfoScreen extends StatefulWidget {
  const DoctorInfoScreen({super.key});

  @override
  DoctorInfoScreenState createState() => DoctorInfoScreenState();
}

class DoctorInfoScreenState extends State<DoctorInfoScreen> {
  String? selectedYear;
  String? selectedDepartment;


  final List<String> years = ['1', '2', '3', '4'];

  final List<String> departments = [
    'Marketing',
    'Accounting',
    'Human Resources',
    'MIS',
    'Finance',
    'Bank Management',
    'IT',
  ];

  final formKey = GlobalKey<FormState>();

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
              DropdownButtonFormField<String>(
                validator: (value) {
                  if (value == null) {
                    return 'Please select your year!';
                  }
                  return null;
                },
                hint: const Text('Select year'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                ),
                value: selectedYear,
                items: years.map((year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Department',
                style: TextStyle(
                  color: Color.fromARGB(255, 19, 53, 105),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                validator: (value) {
                  if (value == null) {
                    return 'Please select your department!';
                  }
                  return null;
                },
                hint: const Text('Select your department'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                ),
                value: selectedDepartment,
                items: departments.map((dep) {
                  return DropdownMenuItem<String>(
                    value: dep,
                    child: Text(dep),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                },
              ),
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
                  onPressed: (selectedDepartment == null || selectedYear == null)
                      ? null
                      : () {
                    if (formKey.currentState!.validate()) {
                      context.read<DoctorProvider>().setStudyInfo(
                        selectedYear!,
                        selectedDepartment!,
                      );
                      Navigator.pushNamed(context, '/doctorcourse');
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