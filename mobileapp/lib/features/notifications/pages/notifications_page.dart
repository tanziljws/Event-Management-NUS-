import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_list.dart';
import '../widgets/notification_filters.dart';
import '../widgets/notification_settings.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  
  String? _selectedFilter;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load notifications after a short delay to ensure bloc is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final bloc = context.read<NotificationBloc>();
          print('NotificationBloc state before load: ${bloc.state}');
          bloc.add(const LoadNotifications());
          bloc.add(const LoadNotificationSettings());
        } catch (e, stackTrace) {
          print('Error loading notifications: $e');
          print('Stack trace: $stackTrace');
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationBloc>().add(const LoadMoreNotifications());
    }
  }

  void _onFilterChanged(String? filter) {
    setState(() {
      _selectedFilter = filter;
    });
    context.read<NotificationBloc>().add(FilterNotificationsByType(filter));
  }

  void _onRefresh() {
    context.read<NotificationBloc>().add(const RefreshNotifications());
  }

  void _onMarkAllAsRead() {
    context.read<NotificationBloc>().add(const MarkAllNotificationsAsRead());
  }

  void _onClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationBloc>().add(const ClearAllNotifications());
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _onSettingsToggle() {
    setState(() {
      _showSettings = !_showSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header - same style as tickets and certificates
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 20,
              right: 20,
              bottom: 8,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Title
                const Expanded(
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, state) {
                        final unreadCount = state is NotificationLoaded ? state.unreadCount : 0;
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: unreadCount > 0 ? const Color(0xFF2563EB).withOpacity(0.1) : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: unreadCount > 0 ? _onMarkAllAsRead : null,
                                icon: Icon(
                                  Icons.done_all_rounded,
                                  color: unreadCount > 0 ? const Color(0xFF2563EB) : Colors.grey[400],
                                  size: 22,
                                ),
                                tooltip: 'Mark all as read',
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Center(
                                    child: Text(
                                      unreadCount > 9 ? '9+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _onClearAll,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.black87,
                          size: 22,
                        ),
                        tooltip: 'Clear all',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _showSettings ? const Color(0xFF2563EB).withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _onSettingsToggle,
                        icon: Icon(
                          _showSettings ? Icons.close_rounded : Icons.settings_rounded,
                          color: _showSettings ? const Color(0xFF2563EB) : Colors.black87,
                          size: 22,
                        ),
                        tooltip: 'Settings',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AllNotificationsMarkedAsRead) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All notifications marked as read'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AllNotificationsCleared) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All notifications cleared'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          print('NotificationState: ${state.runtimeType}');
          
          // Show loading only on initial load
          if (state is NotificationInitial || state is NotificationLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading notifications...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            final unreadCount = state.unreadCount;
            final notifications = state.notifications;
            
            return Column(
              children: [
                // Unread Count Badge
                if (unreadCount > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: const Color(0xFF2563EB),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Filters
                NotificationFilters(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: _onFilterChanged,
                ),
                
                // Settings Panel
                if (_showSettings)
                  NotificationSettings(
                    settings: state.settings,
                    onSettingsChanged: (settings) {
                      context.read<NotificationBloc>().add(UpdateNotificationSettings(settings));
                    },
                  ),
                
                // Notifications List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: notifications.isEmpty
                        ? _buildEmptyState(context)
                        : NotificationList(
                            notifications: notifications,
                            hasMore: state.hasMore,
                            onMarkAsRead: (notificationId) {
                              context.read<NotificationBloc>().add(MarkNotificationAsRead(notificationId));
                            },
                            onDelete: (notificationId) {
                              context.read<NotificationBloc>().add(DeleteNotification(notificationId));
                            },
                            onTap: (notification) {
                              _handleNotificationTap(notification);
                            },
                          ),
                  ),
                ),
              ],
            );
          }

          if (state is NotificationFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load notifications',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Fallback: show empty state if we're stuck
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'State: ${state.runtimeType}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _onRefresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(MarkNotificationAsRead(notification.id));
    }
    
    // Handle notification tap based on type
    final data = notification.data;
    
    if (data != null) {
      switch (notification.type) {
        case 'event_registration':
        case 'event_reminder':
        case 'event_update':
        case 'event_cancellation':
        case 'registration_deadline':
        case 'event_starting':
          if (data['eventId'] != null) {
            context.go('/events/detail/${data['eventId']}');
          }
          break;
        case 'payment_confirmation':
          context.go('/payments');
          break;
        case 'organizer_approval':
        case 'organizer_rejection':
        case 'UPGRADE_APPROVED':
        case 'UPGRADE_REJECTED':
          context.go('/profile');
          break;
        case 'certificate_ready':
        case 'CERTIFICATE_READY':
          context.go('/certificates');
          break;
        default:
          // Stay on notifications page
          break;
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 64,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'You\'ll see notifications about events, payments, and updates here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}