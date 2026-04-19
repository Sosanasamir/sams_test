import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type; // 'accept' أو 'reject'
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['is_read'] == 1 || json['isRead'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ✅ أضف هذا الـ getter
  int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  /// جلب الإشعارات للمستخدم
  Future<void> loadNotifications(String uniId) async {
    if (uniId.isEmpty) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/api/controllers/api_endpoints/get_notifications.php?uni_id=$uniId'),
        headers: {'Accept': 'application/json'},
      );

      print('📥 Notifications response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List<dynamic> notifs = data['notifications'] ?? [];
          _notifications = notifs.map((e) => NotificationModel.fromJson(e)).toList();
          print('✅ تم جلب ${_notifications.length} إشعار');
        } else {
          _errorMessage = data['message'] ?? 'فشل جلب الإشعارات';
        }
      } else {
        _errorMessage = 'خطأ في السيرفر: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'خطأ في الاتصال: $e';
      debugPrint('Error loading notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تحديث حالة إشعار معين
  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      // تحديث الحالة محلياً
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        isRead: true,
        createdAt: _notifications[index].createdAt,
      );
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}