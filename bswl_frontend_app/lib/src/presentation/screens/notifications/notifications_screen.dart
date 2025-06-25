import 'package:flutter/material.dart';
import '../../widgets/header.dart';
import '../../widgets/notification_card.dart';
import '../../widgets/page_header.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'New Lesson Available',
        'description': 'Check out the new lesson on Mathematics',
        'time': '2 hours ago',
        'read': false
      },
      {
        'title': 'Practice Reminder',
        'description': 'You have unfinished practice questions',
        'time': 'Yesterday',
        'read': true
      },
      {
        'title': 'Weekly Progress',
        'description': 'You\'ve completed 5 lessons this week!',
        'time': '2 days ago',
        'read': true
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: "Notifications",
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) => NotificationCard(
                    title: notifications[index]['title'],
                    description: notifications[index]['description'],
                    time: notifications[index]['time'],
                    unread: !notifications[index]['read'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
