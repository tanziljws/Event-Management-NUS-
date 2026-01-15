import 'package:flutter/material.dart';
import '../../../shared/models/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor();
    final isUnread = !notification.isRead;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? iconColor.withOpacity(0.3) : Colors.grey[200]!,
          width: isUnread ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon with background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isUnread 
                              ? FontWeight.bold 
                              : FontWeight.w600,
                          color: isUnread 
                              ? Colors.black 
                              : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      
                      // Message with enhanced details
                      _buildEnhancedMessage(),
                      
                      const SizedBox(height: 8),
                      
                      // Time and Actions
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          if (isUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'New',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: iconColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      // Additional Data (if available)
                      if (notification.data != null) ...[
                        const SizedBox(height: 8),
                        _buildAdditionalInfo(),
                      ],
                    ],
                  ),
                ),
                
                // Unread Indicator
                if (isUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMessage() {
    final data = notification.data;
    final baseMessage = notification.message;
    final isUnread = !notification.isRead;
    
    // Build enhanced message based on notification type
    String enhancedMessage = baseMessage;
    
    // Registration confirmed
    if (notification.type == 'REGISTRATION_CONFIRMED' || 
        notification.type == 'event_registration') {
      if (data != null) {
        final eventTitle = data['eventTitle'] ?? data['eventName'];
        final eventDate = data['eventDate'];
        final eventLocation = data['eventLocation'] ?? data['location'];
        
        if (eventTitle != null) {
          enhancedMessage = 'Pendaftaran berhasil untuk event "$eventTitle"';
          if (eventDate != null) {
            enhancedMessage += '\nTanggal: ${_formatDate(eventDate)}';
          }
          if (eventLocation != null) {
            enhancedMessage += '\nLokasi: $eventLocation';
          }
        }
      }
    }
    
    // Payment success
    else if (notification.type == 'PAYMENT_SUCCESS' || 
             (notification.type == 'payment_confirmation' && data?['status'] == 'success')) {
      if (data != null) {
        final amount = data['amount'];
        final eventTitle = data['eventTitle'] ?? data['eventName'];
        final paymentMethod = data['paymentMethod'] ?? data['method'];
        
        enhancedMessage = 'Pembayaran berhasil';
        if (amount != null) {
          enhancedMessage += ' sebesar Rp ${_formatCurrency(amount)}';
        }
        if (eventTitle != null) {
          enhancedMessage += '\nUntuk event: $eventTitle';
        }
        if (paymentMethod != null) {
          enhancedMessage += '\nMetode: $paymentMethod';
        }
      }
    }
    
    // Payment failed
    else if (notification.type == 'PAYMENT_FAILED' || 
             (notification.type == 'payment_confirmation' && data?['status'] == 'failed')) {
      if (data != null) {
        final amount = data['amount'];
        final reason = data['reason'] ?? data['error'];
        
        enhancedMessage = 'Pembayaran gagal';
        if (amount != null) {
          enhancedMessage += ' untuk Rp ${_formatCurrency(amount)}';
        }
        if (reason != null) {
          enhancedMessage += '\nAlasan: $reason';
        }
      }
    }
    
    // Event reminder
    else if (notification.type == 'EVENT_REMINDER_H1' || 
             notification.type == 'EVENT_REMINDER_H0' ||
             notification.type == 'event_reminder') {
      if (data != null) {
        final eventTitle = data['eventTitle'] ?? data['eventName'];
        final eventDate = data['eventDate'];
        final hoursBefore = data['hoursBefore'] ?? 1;
        
        enhancedMessage = 'Event akan dimulai dalam $hoursBefore jam';
        if (eventTitle != null) {
          enhancedMessage += '\nEvent: $eventTitle';
        }
        if (eventDate != null) {
          enhancedMessage += '\nTanggal: ${_formatDate(eventDate)}';
        }
      }
    }
    
    // Certificate ready
    else if (notification.type == 'CERTIFICATE_READY' || 
             notification.type == 'certificate_ready') {
      if (data != null) {
        final eventTitle = data['eventTitle'] ?? data['eventName'];
        enhancedMessage = 'Sertifikat Anda sudah siap';
        if (eventTitle != null) {
          enhancedMessage += '\nUntuk event: $eventTitle';
        }
      }
    }
    
    // Event cancelled
    else if (notification.type == 'EVENT_CANCELLED' || 
             notification.type == 'event_cancellation') {
      if (data != null) {
        final eventTitle = data['eventTitle'] ?? data['eventName'];
        final reason = data['reason'];
        
        enhancedMessage = 'Event dibatalkan';
        if (eventTitle != null) {
          enhancedMessage += '\nEvent: $eventTitle';
        }
        if (reason != null) {
          enhancedMessage += '\nAlasan: $reason';
        }
      }
    }
    
    // Event updated
    else if (notification.type == 'EVENT_UPDATED' || 
             notification.type == 'event_update') {
      if (data != null) {
        final eventTitle = data['eventTitle'] ?? data['eventName'];
        final changes = data['changes'];
        
        enhancedMessage = 'Event telah diperbarui';
        if (eventTitle != null) {
          enhancedMessage += '\nEvent: $eventTitle';
        }
        if (changes != null && changes is List && changes.isNotEmpty) {
          enhancedMessage += '\nPerubahan: ${changes.join(', ')}';
        }
      }
    }
    
    // New registration (for organizers)
    else if (notification.type == 'NEW_REGISTRATION') {
      if (data != null) {
        final participantName = data['participantName'] ?? data['participant'];
        final eventTitle = data['eventTitle'] ?? data['eventName'];
        
        enhancedMessage = 'Pendaftaran baru diterima';
        if (participantName != null) {
          enhancedMessage += '\nDari: $participantName';
        }
        if (eventTitle != null) {
          enhancedMessage += '\nEvent: $eventTitle';
        }
      }
    }
    
    return Text(
      enhancedMessage,
      style: TextStyle(
        fontSize: 14,
        color: isUnread 
            ? Colors.grey[700] 
            : Colors.grey[600],
        height: 1.4,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsed = DateTime.parse(date);
        return '${parsed.day}/${parsed.month}/${parsed.year}';
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }
  
  String _formatCurrency(dynamic amount) {
    try {
      if (amount is num) {
        return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
      }
      return amount.toString();
    } catch (e) {
      return amount.toString();
    }
  }

  Widget _buildAdditionalInfo() {
    final data = notification.data;
    if (data == null) return const SizedBox.shrink();
    
    // Event-related notifications
    if (notification.isEventReminderH1 || 
        notification.isEventReminderH0 || 
        notification.isRegistrationConfirmed ||
        notification.isEventCancelled ||
        notification.isEventUpdated ||
        notification.isNewRegistration) {
      final eventTitle = data['eventTitle'] ?? data['eventName'];
      if (eventTitle != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event,
              size: 12,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                eventTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }
    }
    
    // Payment-related notifications
    if (notification.isPaymentSuccess || notification.isPaymentFailed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            notification.isPaymentSuccess 
                ? Icons.check_circle 
                : Icons.error,
            size: 12,
            color: notification.isPaymentSuccess 
                ? Colors.green[600] 
                : Colors.red[600],
          ),
          const SizedBox(width: 4),
          Text(
            'Rp ${data['amount']?.toString() ?? '0'}',
            style: TextStyle(
              fontSize: 12,
              color: notification.isPaymentSuccess 
                  ? Colors.green[600] 
                  : Colors.red[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    
    // Certificate notifications
    if (notification.isCertificateReady) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 12,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 4),
          Text(
            'Sertifikat Siap',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    // New registration notifications (for organizers)
    if (notification.isNewRegistration) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_add,
            size: 12,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 4),
          Text(
            data['participantName'] ?? 'Peserta Baru',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  IconData _getIcon() {
    switch (notification.type) {
      case 'EVENT_REMINDER_H1':
      case 'EVENT_REMINDER_H0':
        return Icons.schedule;
      case 'REGISTRATION_CONFIRMED':
        return Icons.check_circle;
      case 'PAYMENT_SUCCESS':
        return Icons.payment;
      case 'PAYMENT_FAILED':
        return Icons.error;
      case 'CERTIFICATE_READY':
        return Icons.verified;
      case 'EVENT_CANCELLED':
        return Icons.cancel;
      case 'EVENT_UPDATED':
        return Icons.update;
      case 'UPGRADE_APPROVED':
        return Icons.upgrade;
      case 'UPGRADE_REJECTED':
        return Icons.block;
      case 'NEW_REGISTRATION':
        return Icons.person_add;
      case 'GENERAL':
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case 'EVENT_REMINDER_H1':
      case 'EVENT_REMINDER_H0':
        return const Color(0xFFF59E0B); // Orange
      case 'REGISTRATION_CONFIRMED':
      case 'PAYMENT_SUCCESS':
      case 'CERTIFICATE_READY':
      case 'UPGRADE_APPROVED':
        return const Color(0xFF10B981); // Green
      case 'PAYMENT_FAILED':
      case 'EVENT_CANCELLED':
      case 'UPGRADE_REJECTED':
        return const Color(0xFFEF4444); // Red
      case 'EVENT_UPDATED':
      case 'NEW_REGISTRATION':
        return const Color(0xFF2563EB); // Blue
      case 'GENERAL':
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
