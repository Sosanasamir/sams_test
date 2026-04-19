import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/admin_provider.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
        title: const Text(
          'Admin Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 60,
                bottom: 25,
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 6, 34, 78),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${admin.name} ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome to your dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 20),
                  buildCard('Manage Students', Icons.people, () {
                    Navigator.pushNamed(context, '/manageStudents');
                  }),
                  buildCard('Manage Doctors', Icons.people, () {
                    Navigator.pushNamed(context, '/manageDoctors');
                  }),
                  buildCard('verify students', Icons.check_circle_outline, () {
                    Navigator.pushNamed(context, '/approveStudents');
                  }),
                  buildCard('Doctor Appointments', Icons.calendar_today, () {
                    Navigator.pushNamed(context, '/approveAppointments');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        selectedItemColor: Color.fromARGB(255, 6, 34, 78),
        unselectedItemColor: Colors.grey[500],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/adminhome');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/adminprofile');
          }
        },
      ),
    );
  }
  Widget buildCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
