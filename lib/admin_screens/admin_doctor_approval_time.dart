import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  List<dynamic> appointments = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/api/controllers/api_endpoints/get_pending_appointment.php'),
      );

      print('📥 Appointments response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            appointments = data['appointments'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            error = data['message'] ?? 'Failed to load';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _approveAppointment(int id, String status, String doctorName, String subject) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/controllers/api_endpoints/approve_appointment.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appointment_id': id,
          'status': status,
        }),
      );

      print('📥 Approve response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            appointments.removeWhere((a) => a['id'] == id);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${status == 'approved' ? 'Approved' : 'Rejected'} appointment for $doctorName - $subject'),
              backgroundColor: status == 'approved' ? Colors.green : Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Action failed'), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Appointments', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchAppointments, child: const Text('Retry')),
          ],
        ),
      )
          : appointments.isEmpty
          ? const Center(child: Text('No pending appointments', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : RefreshIndicator(
        onRefresh: _fetchAppointments,
        child: ListView.builder(
          // ✅ إضافة itemExtent لتحسين الأداء
          itemExtent: 180,
          padding: const EdgeInsets.all(12),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                          child: Text(
                            (appointment['doctor_name'] ?? 'D')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment['doctor_name'] ?? 'Unknown',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text('ID: ${appointment['doctor_uni_id'] ?? 'N/A'}'),
                              Text('Subject: ${appointment['subject_name'] ?? 'N/A'}'),
                              Text('Day: ${appointment['day'] ?? 'N/A'} | Time: ${appointment['time_slot'] ?? 'N/A'}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _approveAppointment(
                            appointment['id'],
                            'approved',
                            appointment['doctor_name'],
                            appointment['subject_name'],
                          ),
                          icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                          label: const Text('Approve', style: TextStyle(color: Colors.white, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _approveAppointment(
                            appointment['id'],
                            'rejected',
                            appointment['doctor_name'],
                            appointment['subject_name'],
                          ),
                          icon: const Icon(Icons.cancel, color: Colors.white, size: 18),
                          label: const Text('Reject', style: TextStyle(color: Colors.white, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}