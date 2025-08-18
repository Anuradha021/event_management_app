import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/zone_all_data/zone_panel.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/session_all_data/session_panel.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/stall_all_data/stall_panel.dart';
import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/screens/orgnizer_tickit_all_data/organizer_tickets_screen.dart';
import 'package:flutter/material.dart';
import '../track_all_data/track_panel.dart';

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
          _buildTabNavigation(),
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
                OrganizerTicketsScreen(
                  eventId: widget.eventId,
                  eventTitle: 'Event Tickets',
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          _buildTabButton(4, Icons.confirmation_number_outlined, 'Tickets'),
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
            gradient: isActive ? AppTheme.primaryGradient : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
    
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event published successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error publishing event: ${e.toString()}')),
      );
    }
  }
}
