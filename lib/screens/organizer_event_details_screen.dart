import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_theme.dart';
import '../dashboards/organizer_dashboard/All_Events_Details/event_management_screen.dart';
import 'moderator_management_screen.dart';

class OrganizerEventDetailsScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const OrganizerEventDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  State<OrganizerEventDetailsScreen> createState() => _OrganizerEventDetailsScreenState();
}

class _OrganizerEventDetailsScreenState extends State<OrganizerEventDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventData['eventTitle'] ?? 'Event Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.eventData['eventTitle'] ?? 'Event Title',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.eventData['status']),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (widget.eventData['status'] ?? 'draft').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.description,
                      'Description',
                      widget.eventData['eventDescription'] ?? 'No description available',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.location_on,
                      'Location',
                      widget.eventData['location'] ?? 'Location TBD',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Date',
                      _formatEventDate(widget.eventData['eventDate']),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.access_time,
                      'Time',
                      _formatEventTime(widget.eventData['eventTime']),
                    ),
                    if (widget.eventData['eventType'] != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.category,
                        'Category',
                        widget.eventData['eventType'],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventManagementScreen(
                            eventId: widget.eventId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Configure'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModeratorManagementScreen(
                            eventId: widget.eventId,
                            eventTitle: widget.eventData['eventTitle'] ?? 'Event',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('Moderators'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatEventDate(dynamic eventDate) {
    if (eventDate == null) return 'Date TBD';
    try {
      DateTime date;
      if (eventDate is String) {
        return eventDate;
      } else if (eventDate.runtimeType.toString().contains('Timestamp')) {
        date = eventDate.toDate();
        return '${date.day}/${date.month}/${date.year}';
      } else {
        return eventDate.toString();
      }
    } catch (e) {
      return 'Date TBD';
    }
  }

  String _formatEventTime(dynamic eventTime) {
    if (eventTime == null) return 'Time TBD';
    try {
      if (eventTime is String) {
        return eventTime;
      } else if (eventTime.runtimeType.toString().contains('Timestamp')) {
        DateTime time = eventTime.toDate();
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else {
        return eventTime.toString();
      }
    } catch (e) {
      return 'Time TBD';
    }
  }
}
