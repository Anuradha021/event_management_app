import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/session_panel.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/stall_panel.dart';
import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/screens/ticket_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'zone_panel.dart';
import 'track_panel.dart';


class EventManagementScreen extends StatefulWidget {
  final String eventId;
  
  EventManagementScreen({
    super.key,
    required this.eventId,
  }) : assert(eventId.isNotEmpty);

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  int _activeTabIndex = 0;
  final PageController _pageController = PageController();
  Key _refreshKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Event Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _refreshAllData,
            tooltip: 'Refresh All Data',
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.publish_outlined),
              onPressed: _publishEvent,
              tooltip: 'Publish Event',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
                foregroundColor: AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Event Summary Card
          _buildEventSummaryCard(),
          
          // Tab Navigation
          _buildTabNavigation(),
          
          // Content Area
          Expanded(
            child: PageView(
              key: _refreshKey,
              controller: _pageController,
              onPageChanged: (index) => setState(() => _activeTabIndex = index),
              children: [
                ZonePanel(eventId: widget.eventId),
                TrackPanel(eventId: widget.eventId),
                SessionPanel(eventId: widget.eventId),
                StallPanel(eventId: widget.eventId),
                _buildTicketsPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildEventSummaryCard() {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get(),
    builder: (context, snapshot) {
      // Handle loading state
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
        );
      }

      // Handle error state
      if (snapshot.hasError) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: ${snapshot.error}'),
          ),
        );
      }

      // Handle no data state
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Event not found'),
          ),
        );
      }

      final event = snapshot.data!.data() as Map<String, dynamic>;
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row with Status Chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event['eventTitle'] ?? 'Untitled Event',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Chip(
                    label: Text(
                      (event['status'] ?? 'draft').toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: event['status'] == 'published'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                event['eventDescription'] ?? 'No description provided',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              // Location and Date
              Wrap(
                spacing: 16,
                children: [
                  if (event['location'] != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(event['location']!),
                      ],
                    ),
                  if (event['eventDate'] != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(event['eventDate']),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Add this helper method to your class
String _formatDate(dynamic timestamp) {
  if (timestamp == null) return 'N/A';
  final date = (timestamp as Timestamp).toDate();
  return DateFormat('MMM d, yyyy').format(date);
}

  Widget _buildTabNavigation() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          _buildTabButton(0, Icons.map_outlined, 'Zones'),
          _buildTabButton(1, Icons.timeline_outlined, 'Tracks'),
          _buildTabButton(2, Icons.schedule_outlined, 'Sessions'),
          _buildTabButton(3, Icons.store_outlined, 'Stalls'),
          _buildTabButton(4, Icons.confirmation_number, 'Tickets'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    final isActive = _activeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _activeTabIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? AppTheme.primaryGradient
                : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: isActive ? [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildTicketsPanel() {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final eventData = snapshot.data?.data() as Map<String, dynamic>?;
      final eventTitle = eventData?['eventTitle'] ?? 'Event';

      return TicketManagementScreen(
        eventId: widget.eventId,
        eventTitle: eventTitle,
      );
    },
  );
}

  void _refreshAllData() {
    setState(() {
      _refreshKey = UniqueKey();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing all data...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _publishEvent() async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update({'status': 'published'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event published successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error publishing event: ${e.toString()}')),
        );
      }
    }
  }
}