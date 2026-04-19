import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notifications.isEmpty
          ? const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          final notif = provider.notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                notif.type == 'approved' || notif.type == 'accept'
                    ? Icons.check_circle
                    : notif.type == 'rejected' || notif.type == 'reject'
                    ? Icons.cancel
                    : Icons.notifications,
                color: notif.type == 'approved' || notif.type == 'accept'
                    ? Colors.green
                    : notif.type == 'rejected' || notif.type == 'reject'
                    ? Colors.red
                    : Colors.orange,
                size: 30,
              ),
              title: Text(
                notif.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(notif.message),
              trailing: notif.isRead
                  ? null
                  : Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () {
                provider.markAsRead(notif.id);
              },
            ),
          );
        },
      ),
    );
  }
}