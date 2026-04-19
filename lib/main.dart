import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sams/admin_screens/admin_homepage.dart';
import 'package:sams/admin_screens/admin_profile.dart';
import 'package:sams/admin_screens/admin_student_approval.dart';
import 'package:sams/admin_screens/doctor_manage.dart';
import 'package:sams/admin_screens/students_manage.dart';
import 'package:sams/doctor_screens/docotor_home_screen.dart';
import 'package:sams/doctor_screens/doctor_courses_screen.dart';
import 'package:sams/doctor_screens/doctor_profile_screen.dart';
import 'package:sams/doctor_screens/doctor_schedule_screen.dart';
import 'package:sams/login_screen.dart';
import 'package:sams/provider/admin_doctors_provider.dart';
import 'package:sams/provider/admin_provider.dart';
import 'package:sams/provider/admin_students_provider.dart';
import 'package:sams/provider/doctor_provider.dart';
import 'package:sams/provider/notification_provider.dart';
import 'package:sams/provider/user_provider.dart';
import 'package:sams/signup_screen.dart';
import 'package:sams/student_screens/card_payment.dart';
import 'package:sams/student_screens/profile_screen.dart';
import 'package:sams/provider/subjects_provider.dart';
import 'package:sams/student_screens/home_screen.dart';
import 'package:sams/student_screens/student_info_screen.dart';
import 'package:sams/logo_screen.dart';
import 'package:sams/student_screens/wallet_payment.dart';
import 'admin_screens/admin_doctor_approval_time.dart';
import 'doctor_screens/Notification_Screen.dart';
import 'doctor_screens/doctor_info.dart';
import 'otp_screens/forget_uni_id_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userProvider = UserProvider();
  final doctorProvider = DoctorProvider();
  final subjectsProvider = SubjectsProvider();
  final adminProvider = AdminProvider();
  await subjectsProvider.loadFromPrefs();

  await userProvider.loadUserData();
  await doctorProvider.loadDoctorData();
  await adminProvider.loadAdminData();

  String initialRoute = '/logo';

  if (doctorProvider.name.isNotEmpty && doctorProvider.docId.isNotEmpty) {
    initialRoute = '/dochome';
  } else if (userProvider.name.isNotEmpty && userProvider.uniId.isNotEmpty) {
    if (userProvider.year.isNotEmpty && userProvider.department.isNotEmpty) {
      initialRoute = '/home';
    } else {
      initialRoute = '/logo';
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubjectsProvider()),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider<DoctorProvider>.value(value: doctorProvider),
        ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AdminDoctorsProvider()),
        ChangeNotifierProvider<AdminStudentsProvider>(
          create: (_) => AdminStudentsProvider(),
        ),
        ChangeNotifierProvider<SubjectsProvider>(
          create: (context) {
            final provider = SubjectsProvider();
            provider.loadFromPrefs();
            return provider;
          },
        ),
                ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/logo': (context) => LogoScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        //////////////////////////////////////
        '/studentinfo': (context) => StudentInfoScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/cardpayment': (context) => CardPaymentPage(),
        '/walletpayment': (context) => WalletPaymentPage(),
        ///////////////////////////////////////////
        '/doctorcourse': (context) => DoctorcourseScreen(),
        '/dochome': (context) => DocotorHomeScreen(),
        '/docschedule': (context) => DoctorScheduleScreen(),
        '/docprofile': (context) => DoctorProfileScreen(),
        '/docinfo': (context) => DoctorInfoScreen(),
        '/doctorNotifications': (context) => const NotificationsScreen(),
///////////////////////////////////////////////////
        '/forgot_uni_id': (context) => const ForgotUniIdScreen(),
        ///////////////////////////////////////////////////
        '/adminhome': (context) => AdminHomePage(),
        '/adminprofile': (context) => AdminProfileScreen(),
        '/manageStudents': (context) => StudentsManageScreen(),
        '/manageDoctors': (context) => DoctorsManageScreen(),
        '/approveStudents': (context) => AdminStudentApprovalScreen(),
        '/approveAppointments': (context) => AdminAppointmentsScreen(),
        ///////////////////////////////////////////////////'
      },
    );
  }
}
