import 'package:flutter/material.dart';
import '../shared/base/base_detail_screen.dart';
import '../shared/widgets/update_dialog.dart';
import '../shared/services/firestore_service.dart';

/// Refactored Zone Detail Screen
/// Follows Single Responsibility Principle - only handles zone-specific logic
class ZoneDetailScreen extends BaseDetailScreen {
  final String zoneId;

  const ZoneDetailScreen({
    super.key,
    required super.eventId,
    required this.zoneId,
    required super.initialData,
  });

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends BaseDetailScreenState<ZoneDetailScreen> {
  Map<String, dynamic> _currentData = {};

  @override
  String get screenTitle => 'Zone Details';

  @override
  IconData get screenIcon => Icons.map;

  @override
  Color get screenIconColor => Colors.deepPurple;

  @override
  String get itemName => _currentData['title'] ?? 'Untitled Zone';

  @override
  String get itemDescription => _currentData['description'] ?? 'No description provided';

  @override
  List<UpdateDialogField> get updateFields => [
    UpdateDialogField(
      key: 'title',
      label: 'Zone Name',
      initialValue: itemName,
      isRequired: true,
    ),
    UpdateDialogField(
      key: 'description',
      label: 'Description',
      initialValue: itemDescription,
      maxLines: 3,
    ),
  ];

  @override
  Future<void> refreshData() async {
    try {
      final data = await EventDataService.getZone(widget.eventId, widget.zoneId);
      if (data != null && mounted) {
        setState(() {
          _currentData = data;
        });
      }
    } catch (e) {
      // Handle error silently or show message if needed
    }
  }

  @override
  Future<void> updateData(Map<String, String> values) async {
    await EventDataService.updateZone(
      widget.eventId,
      widget.zoneId,
      {
        'title': values['title']!,
        'description': values['description']!,
      },
    );
  }

  @override
  Future<void> deleteData() async {
    await FirestoreService.deleteDocument(
      'events/${widget.eventId}/zones/${widget.zoneId}',
    );
  }

  @override
  List<Widget> get additionalInfoWidgets => [
    if (_currentData['createdAt'] != null)
      Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Created: ${_formatDate(_currentData['createdAt'])}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    if (_currentData['updatedAt'] != null) ...[
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.update, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Updated: ${_formatDate(_currentData['updatedAt'])}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ],
  ];

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
