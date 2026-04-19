

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/doctor_provider.dart';


class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.20;
    final doc = context.watch<DoctorProvider>();

    if (doc.docId.isNotEmpty && doc.name.isEmpty && !doc.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        doc.loadDoctorData();
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: headerHeight,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 6, 34, 78),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(200),
                  ),
                ),
              ),
              const Positioned(
                top: 50,
                left: 22,
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ProfileRow(
                    title: 'Name',
                    value: doc.name.isEmpty ? 'Not specified' : doc.name,
                  ),
                  const SizedBox(height: 10),
                  ProfileRow(title: 'Phone Number', value: doc.phone),
                  const SizedBox(height: 10),
                  ProfileRow(title: 'ID', value: doc.docId),
                  const SizedBox(height: 10),
                  ProfileRow(
                    title: 'Year',
                    value: (doc.year.isEmpty || doc.year == 'null')
                        ? 'Not specified'
                        : doc.year,
                  ),
                  const SizedBox(height: 10),
                  ProfileRow(title: 'Department', value: doc.department),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color.fromARGB(255, 6, 34, 78),
              ),
              onPressed: () async {
                await doc.logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signup',
                    (route) => false,
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 16),
                    SizedBox(width: 15),
                    Text(
                      'LogOut',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final String title;
  final String value;

  const ProfileRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 6, 34, 78),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
