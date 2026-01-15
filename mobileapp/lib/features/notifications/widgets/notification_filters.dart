import 'package:flutter/material.dart';

class NotificationFilters extends StatelessWidget {
  final String? selectedFilter;
  final Function(String?) onFilterChanged;

  const NotificationFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': null, 'label': 'All', 'icon': Icons.all_inclusive},
      {'key': 'event_registration', 'label': 'Events', 'icon': Icons.event},
      {'key': 'payment_confirmation', 'label': 'Payments', 'icon': Icons.payment},
      {'key': 'organizer_approval', 'label': 'Organizer', 'icon': Icons.business},
      {'key': 'system_announcement', 'label': 'System', 'icon': Icons.announcement},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['key'];

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label'] as String),
              avatar: Icon(
                filter['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              selected: isSelected,
              onSelected: (selected) {
                onFilterChanged(selected ? filter['key'] as String? : null);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF2563EB), // Primary blue
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}
