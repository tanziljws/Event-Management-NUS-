import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/event_model.dart';

class DashboardUpcomingSection extends StatelessWidget {
  final List<EventModel> events;
  final String title;
  final String badgeText;
  final VoidCallback? onSeeAll;
  final String? seeAllRoute;

  const DashboardUpcomingSection({
    super.key,
    required this.events,
    required this.title,
    required this.badgeText,
    this.onSeeAll,
    this.seeAllRoute,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
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
                Text(
                  title,
                  style: const TextStyle(
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
                    badgeText,
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
              onPressed: onSeeAll ?? (seeAllRoute != null ? () => context.go(seeAllRoute!) : null),
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
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Container(
                width: 260,
                margin: EdgeInsets.only(right: index < events.length - 1 ? 12 : 0),
                child: _buildUpcomingCard(context, event),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingCard(BuildContext context, EventModel event) {
    final daysUntil = _getDaysUntil(event);
    final isExpiring = daysUntil != null && daysUntil <= 7;
    
    return GestureDetector(
      onTap: () => context.go('/events/detail/${event.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpiring ? Colors.orange[200]! : Colors.grey[200]!,
            width: isExpiring ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Type / Event Type
            Row(
              children: [
                Icon(
                  Icons.description,
                  size: 16,
                  color: isExpiring ? Colors.orange[700] : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  'Event',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isExpiring ? Colors.orange[700] : Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Event Title
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
            // Valid Till / Event Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Event Date: ${_formatDate(event.eventDate)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (daysUntil != null && daysUntil <= 7) ...[
              const SizedBox(height: 4),
              Text(
                daysUntil == 0 
                    ? 'Expiring today'
                    : daysUntil == 1
                        ? 'Expiring in 1 day'
                        : 'Expiring in $daysUntil days',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
            ] else if (daysUntil != null) ...[
              const SizedBox(height: 4),
              Text(
                daysUntil == 1
                    ? 'In 1 day'
                    : 'In $daysUntil days',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int? _getDaysUntil(EventModel event) {
    try {
      final now = DateTime.now();
      final eventDate = event.eventDate;
      final difference = eventDate.difference(now).inDays;
      return difference >= 0 ? difference : null;
    } catch (e) {
      return null;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'TBA';
    try {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
    } catch (e) {
      return 'TBA';
    }
  }
}

