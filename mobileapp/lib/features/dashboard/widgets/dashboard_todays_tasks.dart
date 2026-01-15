import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/event_model.dart';

class DashboardTodaysTasks extends StatelessWidget {
  final List<EventModel> upcomingEvents;
  final bool isOrganizer;
  final VoidCallback? onSeeAll;

  const DashboardTodaysTasks({
    super.key,
    required this.upcomingEvents,
    this.isOrganizer = false,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final todayTasks = _getTodayTasks();
    
    if (todayTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Today's Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${todayTasks.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onSeeAll ?? () => context.go('/my-registrations'),
              child: const Text(
                'SEE ALL',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: todayTasks.length,
            itemBuilder: (context, index) {
              final task = todayTasks[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(right: index < todayTasks.length - 1 ? 12 : 0),
                child: _buildTaskCard(context, task),
              );
            },
          ),
        ),
      ],
    );
  }

  List<EventModel> _getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return upcomingEvents.where((event) {
      try {
        final eventDate = event.eventDate;
        
        final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
        return eventDay.isAtSameMomentAs(today) || 
               (eventDay.isAfter(today) && eventDay.isBefore(tomorrow));
      } catch (e) {
        return false;
      }
    }).take(5).toList();
  }

  Widget _buildTaskCard(BuildContext context, EventModel event) {
    final taskType = _getTaskType(event);
    final taskColor = _getTaskColor(taskType);
    
    return GestureDetector(
      onTap: () => context.go('/events/detail/${event.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200] ?? Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: taskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                taskType,
                style: TextStyle(
                  color: taskColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Task Title
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Time
              Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[600] ?? Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatEventTime(event),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600] ?? Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Organizer/Attendees
            Row(
              children: [
                _buildAvatarStack(event),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isOrganizer 
                        ? '${event.registrationCount ?? 0} participants'
                        : event.creator?.fullName ?? 'Event',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600] ?? Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTaskType(EventModel event) {
    if (isOrganizer) {
      return 'EVENT';
    }
    // For participants, determine based on event status
    final now = DateTime.now();
    if (event.eventDate != null && now.isAfter(event.eventDate!)) {
      return 'ONGOING';
    }
    return 'UPCOMING';
  }

  Color _getTaskColor(String taskType) {
    switch (taskType) {
      case 'EVENT':
        return const Color(0xFF2563EB);
      case 'UPCOMING':
        return const Color(0xFF10B981);
      case 'ONGOING':
        return const Color(0xFFF59E0B);
      case 'APPOINTMENT':
        return const Color(0xFFF59E0B);
      case 'COURT':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatEventTime(EventModel event) {
    try {
      if (event.eventTime != null) {
        return event.eventTime!;
      }
      if (event.eventDate != null) {
        final time = event.eventDate!;
        final hour = time.hour;
        final minute = time.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
      return 'TBA';
    } catch (e) {
      return 'TBA';
    }
  }

  Widget _buildAvatarStack(EventModel event) {
    // For organizer: show participant avatars
    // For participant: show organizer avatar or event icon
    if (isOrganizer) {
      final registrationCount = event.registrationCount ?? 0;
      if (registrationCount > 0) {
        final count = registrationCount.clamp(0, 3);
        return SizedBox(
          width: (count * 16.0) + 24,
          height: 24,
          child: Stack(
            children: List.generate(count, (index) {
              return Positioned(
                left: index * 16.0,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }
    }
    
    // Default: show event icon
    return CircleAvatar(
      radius: 12,
      backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
      child: const Icon(
        Icons.event,
        size: 14,
        color: Color(0xFF2563EB),
      ),
    );
  }
}

