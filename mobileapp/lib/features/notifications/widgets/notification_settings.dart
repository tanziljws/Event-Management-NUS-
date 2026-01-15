import 'package:flutter/material.dart';

class NotificationSettings extends StatelessWidget {
  final Map<String, bool> settings;
  final Function(Map<String, bool>) onSettingsChanged;

  const NotificationSettings({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notification Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Settings
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSettingItem(
                  context,
                  'Event Notifications',
                  'Get notified about new events and updates',
                  'event_notifications',
                  Icons.event,
                ),
                _buildSettingItem(
                  context,
                  'Payment Notifications',
                  'Get notified about payment confirmations',
                  'payment_notifications',
                  Icons.payment,
                ),
                _buildSettingItem(
                  context,
                  'Reminder Notifications',
                  'Get reminded about upcoming events',
                  'reminder_notifications',
                  Icons.schedule,
                ),
                _buildSettingItem(
                  context,
                  'Organizer Notifications',
                  'Get notified about organizer status updates',
                  'organizer_notifications',
                  Icons.business,
                ),
                _buildSettingItem(
                  context,
                  'System Announcements',
                  'Get notified about system updates and announcements',
                  'system_notifications',
                  Icons.announcement,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    String key,
    IconData icon,
  ) {
    final isEnabled = settings[key] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          
          // Toggle
          Switch(
            value: isEnabled,
            onChanged: (value) {
              final newSettings = Map<String, bool>.from(settings);
              newSettings[key] = value;
              onSettingsChanged(newSettings);
            },
            activeColor: const Color(0xFF2563EB),
            activeTrackColor: const Color(0xFF2563EB).withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
