import 'package:flutter/material.dart';
import '../../../shared/models/notification_model.dart';
import 'notification_item.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final bool hasMore;
  final Function(String) onMarkAsRead;
  final Function(String) onDelete;
  final Function(NotificationModel) onTap;

  const NotificationList({
    super.key,
    required this.notifications,
    required this.hasMore,
    required this.onMarkAsRead,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == notifications.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
          );
        }

        final notification = notifications[index];
        return NotificationItem(
          notification: notification,
          onTap: () {
            // Mark as read when tapped
            if (!notification.isRead) {
              onMarkAsRead(notification.id);
            }
            onTap(notification);
          },
        );
      },
    );
  }
}
