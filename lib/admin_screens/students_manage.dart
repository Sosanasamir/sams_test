import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/provider/admin_students_provider.dart';
import 'edit_students.dart';

class StudentsManageScreen extends StatefulWidget {
  const StudentsManageScreen({super.key});

  @override
  State<StudentsManageScreen> createState() => _StudentsManageScreenState();
}

class _StudentsManageScreenState extends State<StudentsManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    await context.read<AdminStudentsProvider>().loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminStudentsProvider>(
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
                    onPressed: _loadStudents,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final students = provider.students;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 6, 34, 78),
            title: const Text(
              "Students",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadStudents,
              ),
            ],
          ),
          body: students.isEmpty
              ? const Center(
                  child: Text(
                    'No students registered yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStudents,
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      // حماية مهمة جدًا: لو الـ index طلع خارج النطاق بعد حذف → ارجع حاجة فاضية
                      if (index >= students.length) {
                        return const SizedBox.shrink();
                      }

                      final student = students[index];

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
                              student.full_name.isNotEmpty
                                  ? student.full_name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(student.full_name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Uni ID: ${student.uni_id}"),
                              Text("Year: ${student.year}"),
                              Text("Subjects: ${student.subjects.join(", ")}"),
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
                                      builder: (_) => EditStudentScreen(
                                        student: student,
                                        index: index,
                                      ),
                                    ),
                                  ).then((result) {
                                    if (result != null &&
                                        result['student'] != null &&
                                        result['index'] != null) {
                                      // حماية إضافية: تأكد إن الـ index لسه صالح بعد الرجوع
                                      if (result['index'] <
                                          provider.students.length) {
                                        provider.updateStudent(
                                          result['index'],
                                          result['student'],
                                        );
                                      }
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
                                      title: const Text('Delete Student'),
                                      content: const Text(
                                        'Are you sure you want to delete this student?',
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
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
                                            backgroundColor:
                                                const Color.fromARGB(
                                                  255,
                                                  6,
                                                  34,
                                                  78,
                                                ),
                                          ),
                                          onPressed: () async {
                                            final success = await provider
                                                .deleteStudent(index);
                                            if (success) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'تم حذف الطالب بنجاح',
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
                MaterialPageRoute(builder: (_) => const EditStudentScreen()),
              ).then((result) {
                if (result != null && result['student'] != null) {
                  provider.addStudent(result['student']);
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
