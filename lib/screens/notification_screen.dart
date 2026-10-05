import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationService.getNotifications();
  }

  void _refresh() {
    setState(() {
      _future = NotificationService.getNotifications();
    });
  }

  Future<void> _open(int index, List<dynamic> notifications) async {
    final n = notifications[index];
    if (n['read_at'] == null) {
      await NotificationService.markAsRead(n['id']);
      _refresh();
    }
  }

  IconData _icon(String? type) {
    switch (type) {
      case 'booking':
        return Icons.home_work_outlined;
      case 'booking_status':
        return Icons.event_available;
      case 'purchase':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            final notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(child: Text('Belum ada notifikasi.', style: TextStyle(color: Colors.grey.shade500))),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                final unread = n['read_at'] == null;
                return Card(
                  color: unread ? Colors.indigo.shade50 : null,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _open(index, notifications),
                    leading: CircleAvatar(
                      backgroundColor: unread ? Colors.indigo : Colors.grey.shade300,
                      child: Icon(_icon(n['type']), color: unread ? Colors.white : Colors.grey.shade700),
                    ),
                    title: Text(
                      n['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n['body'] ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          n['created_at'] != null ? n['created_at'].toString().substring(0, 16) : '',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    trailing: unread ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle)) : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}