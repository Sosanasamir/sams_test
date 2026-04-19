import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/admin_students_provider.dart';
import 'package:sams/models/student_model.dart';

class AdminStudentApprovalScreen extends StatefulWidget {
  const AdminStudentApprovalScreen({super.key});

  @override
  State<AdminStudentApprovalScreen> createState() =>
      _AdminStudentApprovalScreenState();
}

class _AdminStudentApprovalScreenState
    extends State<AdminStudentApprovalScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل الطلاب لما الصفحة تفتح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStudentsProvider>().loadStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '  Approve Student Registrations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AdminStudentsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => provider.loadStudents(),
                    child: const Text('try again'),
                  ),
                ],
              ),
            );
          }

          // فلتر الطلاب اللي حالتهم pending فقط
          final pendingStudents = provider.students
              .where(
                (student) =>
                    student.status == 'pending' || student.status == null,
              )
              .toList();

          if (pendingStudents.isEmpty) {
            return const Center(
              child: Text(
                'No pending student registration requests currently',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadStudents(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pendingStudents.length,
              itemBuilder: (context, index) {
                final student = pendingStudents[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color.fromARGB(
                                255,
                                6,
                                34,
                                78,
                              ),
                              child: Text(
                                student.full_name.isNotEmpty
                                    ? student.full_name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.full_name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Uni ID: ${student.uni_id}'),
                                  Text('Year: ${student.year}'),
                                  Text(
                                    'Department: ${student.department ?? 'Not specified'}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _confirmAction(
                                context,
                                student,
                                'accepted',
                                provider,
                                index,
                              ),
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              label: const Text('Accept'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _confirmAction(
                                context,
                                student,
                                'rejected',
                                provider,
                                index,
                              ),
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
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
          );
        },
      ),
    );
  }

  /// دالة تأكيد القبول أو الرفض + إرسال إشعار
  void _confirmAction(
    BuildContext context,
    Student student,
    String action,
    AdminStudentsProvider provider,
    int index,
  ) {
    final isAccept = action == 'accepted';
    final title = isAccept
        ? 'Accept Student Registration'
        : 'Reject Student Registration';
    final content = isAccept
        ? 'Are you sure you want to accept the registration request for ${student.full_name}?'
        : 'Are you sure you want to reject the registration request for ${student.full_name}?';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          // ✅ زر Cancel باللون المطلوب
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 6, 34, 78),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          // ✅ زر Accept / Reject
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept ? Colors.green : Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(ctx);

              final updatedStudent = Student(
                full_name: student.full_name,
                uni_id: student.uni_id,
                phone: student.phone,
                year: student.year,
                department: student.department,
                subjects: student.subjects,
                status: action,
              );

              final success = await provider.updateStudent(
                index,
                updatedStudent,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAccept
                          ? 'Student accepted and notification sent'
                          : 'Student rejected and notification sent',
                    ),
                    backgroundColor: isAccept
                        ? const Color.fromARGB(255, 6, 34, 78)
                        : Colors.red,
                  ),
                );
                await provider.loadStudents();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              isAccept ? 'Accept' : 'Reject',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

extension on int {}
