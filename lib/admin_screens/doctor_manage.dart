import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/admin_doctors_provider.dart';
import 'edit_doctors.dart';

class DoctorsManageScreen extends StatefulWidget {
  const DoctorsManageScreen({super.key});

  @override
  State<DoctorsManageScreen> createState() => _DoctorsManageScreenState();
}

class _DoctorsManageScreenState extends State<DoctorsManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDoctors();
    });
  }

  Future<void> _loadDoctors() async {
    await context.read<AdminDoctorsProvider>().loadDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDoctorsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.errorMessage.isNotEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadDoctors,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final doctors = provider.doctors;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 6, 34, 78),
            title: const Text("Doctors", style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadDoctors,
              ),
            ],
          ),
          body: doctors.isEmpty
              ? const Center(
                  child: Text(
                    'No doctors registered yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDoctors,
                  child: ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color.fromARGB(
                              255,
                              6,
                              34,
                              78,
                            ),
                            child: Text(
                              doctor.full_name.isNotEmpty
                                  ? doctor.full_name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(doctor.full_name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Uni ID: ${doctor.uni_id}"),
                              Text("Year: ${doctor.year}"),
                              Text("Subjects: ${doctor.subjects.join(", ")}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color.fromARGB(255, 6, 34, 78),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditDoctorScreen(
                                        doctor: doctor,
                                        index: index,
                                      ),
                                    ),
                                  ).then((result) {
                                    if (result != null &&
                                        result['doctor'] != null &&
                                        result['index'] != null) {
                                      provider.updateDoctor(
                                        result['index'],
                                        result['doctor'],
                                      );
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color.fromARGB(255, 6, 34, 78),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Doctor'),
                                      content: const Text(
                                        'Are you sure you want to delete this doctor?',
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                              255,
                                              6,
                                              34,
                                              78,
                                            ),
                                          ),
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                              255,
                                              6,
                                              34,
                                              78,
                                            ),
                                          ),
                                          onPressed: () async {
                                            final success = await provider
                                                .deleteDoctor(index);
                                            Navigator.pop(ctx);
                                            if (success) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'تم حذف الدكتور بنجاح',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    provider.errorMessage,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 6, 34, 78),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditDoctorScreen()),
              ).then((result) {
                if (result != null && result['doctor'] != null) {
                  provider.addDoctor(result['doctor']);
                }
              });
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}
