import 'dart:io';
import 'package:sams/services/api_devices.dart';
import 'package:sams/services/api_emulator.dart';
class ApiHelper {
  static dynamic get authService {
    if (Platform.isAndroid && !Platform.environment.containsKey('FLUTTER_TEST')) {
      // Android حقيقي
      return AuthServiceRealDevice();
    } else {
      // Emulator أو iOS
      return AuthServiceEmulator();
    }
  }
}