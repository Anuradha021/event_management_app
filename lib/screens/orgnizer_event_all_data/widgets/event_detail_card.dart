import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'detail_row.dart';

class EventDetailCard extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailCard({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    eventData['eventTitle'] ?? 'Event Title',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(eventData['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (eventData['status'] ?? 'draft').toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DetailRow(
              icon: Icons.description,
              label: "Description",
              value: eventData['eventDescription'] ?? 'No description available',
            ),
            const SizedBox(height: 12),
            DetailRow(
              icon: Icons.location_on,
              label: "Location",
              value: eventData['location'] ?? 'Location TBD',
            ),
            const SizedBox(height: 12),
            DetailRow(
              icon: Icons.calendar_today,
              label: "Date",
              value: _formatEventDate(eventData['eventDate']),
            ),
            const SizedBox(height: 12),
            DetailRow(
              icon: Icons.access_time,
              label: "Time",
              value: _formatEventTime(eventData['eventTime']),
            ),
            // if (eventData['eventType'] != null) ...[
            //   const SizedBox(height: 12),
            //   // DetailRow(
            //   //   icon: Icons.category,
            //   //   label: "Category",
            //   //   value: eventData['eventType'],
            //   // ),
            // ]
          ],
        ),
      ),
    );
  }

  String _formatEventDate(dynamic eventDate) {
    if (eventDate == null) return 'Date TBD';

    try {
      DateTime date;
      if (eventDate is String) {
        // Try to parse string date
        date = DateTime.parse(eventDate);
      } else if (eventDate.runtimeType.toString().contains('Timestamp')) {
        // Handle Firestore Timestamp
        date = (eventDate as Timestamp).toDate();
      } else if (eventDate is DateTime) {
        date = eventDate;
      } else {
        return 'Date TBD';
      }

      return DateFormat('EEEE, MMMM dd, yyyy').format(date);
    } catch (e) {
      return 'Date TBD';
    }
  }

  String _formatEventTime(dynamic eventTime) {
    if (eventTime == null) return 'Time TBD';

    try {
      DateTime time;
      if (eventTime is String) {
        // Try to parse string time
        time = DateTime.parse(eventTime);
      } else if (eventTime.runtimeType.toString().contains('Timestamp')) {
        // Handle Firestore Timestamp
        time = (eventTime as Timestamp).toDate();
      } else if (eventTime is DateTime) {
        time = eventTime;
      } else {
        return 'Time TBD';
      }

      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return 'Time TBD';
    }
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
}
