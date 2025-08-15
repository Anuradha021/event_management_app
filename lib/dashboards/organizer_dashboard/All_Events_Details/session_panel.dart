import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/session_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'components/services/session_data_service.dart';
import 'components/widgets/panel_header.dart';
import 'components/widgets/zone_track_filter.dart';
import 'components/widgets/session_list_widget.dart';
import 'components/widgets/delete_confirmation_dialog.dart';
import 'components/widgets/create_session_dialog.dart';
import 'components/state/session_filter_state.dart';


class SessionPanel extends StatefulWidget {
  final String eventId;
  
  const SessionPanel({
    super.key,
    required this.eventId,
  });

  @override
  State<SessionPanel> createState() => _SessionPanelState();
}

class _SessionPanelState extends State<SessionPanel> {
  late final SessionFilterState _filterState;

  @override
  void initState() {
    super.initState();
    _filterState = SessionFilterState();
    _initializeFilters();
  }

  @override
  void dispose() {
    _filterState.dispose();
    super.dispose();
  }

  Future<void> _initializeFilters() async {
    try {
      await _filterState.initialize(widget.eventId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Stream<QuerySnapshot> _getSessionsStream() {
    if (_filterState.selectedZoneId == 'default' || _filterState.selectedTrackId == 'default') {
      return SessionPanelService.getDefaultSessionsStream(widget.eventId);
    }
    
    return SessionPanelService.getSessionsStream(
      widget.eventId,
      _filterState.selectedZoneId!,
      _filterState.selectedTrackId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _filterState,
      builder: (context, child) {
        return Column(
          children: [
           
            Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PanelHeader(
                    title: 'Event Sessions',
                    onCreatePressed: _filterState.canCreateSession
                        ? () => _showCreateSessionDialog()
                        : null,
                    createTooltip: 'Create Session',
                    canCreate: _filterState.canCreateSession,
                  ),
                  const SizedBox(height: 4),
                  ZoneTrackFilter(
                    selectedZoneId: _filterState.selectedZoneId,
                    selectedTrackId: _filterState.selectedTrackId,
                    zones: _filterState.zones,
                    tracks: _filterState.tracks,
                    onZoneChanged: (zoneId) => _filterState.onZoneChanged(widget.eventId, zoneId),
                    onTrackChanged: _filterState.onTrackChanged,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filterState.canCreateSession
                  ? SessionListWidget(
                      sessionsStream: _getSessionsStream(),
                      onSessionTap: _navigateToSessionDetail,
                      onSessionEdit: _navigateToSessionDetail,
                      onSessionDelete: _handleDeleteSession,
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Select zone & track to view sessions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSessionDetail(String sessionId, Map<String, dynamic> sessionData, DateTime startTime, DateTime endTime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailScreen(
          eventId: widget.eventId,
          zoneId: _filterState.selectedZoneId!,
          trackId: _filterState.selectedTrackId!,
          sessionId: sessionId,
          sessionData: sessionData,
          startTime: startTime,
          endTime: endTime,
        ),
      ),
    );
  }

  void _handleDeleteSession(String sessionId) {
    DeleteConfirmationDialog.show(
      context,
      itemType: 'Session',
      itemName: 'Session',
      onConfirm: () => _deleteSession(sessionId),
    );
  }

  Future<void> _deleteSession(String sessionId) async {
    if (_filterState.selectedZoneId == 'default' || _filterState.selectedTrackId == 'default') {
      await SessionPanelService.deleteDefaultSession(widget.eventId, sessionId);
    } else {
      await SessionPanelService.deleteSession(
        widget.eventId,
        _filterState.selectedZoneId!,
        _filterState.selectedTrackId!,
        sessionId,
      );
    }
  }

  void _showCreateSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateSessionDialog(
        onCreate: _handleCreateSession,
      ),
    );
  }

  Future<void> _handleCreateSession(
    String title,
    String description,
    String speaker,
    DateTime startTime,
    DateTime endTime,
  ) async {
    if (_filterState.selectedZoneId == 'default' || _filterState.selectedTrackId == 'default') {
      await SessionPanelService.createDefaultSession(
        widget.eventId,
        title,
        description,
        speaker,
        startTime,
        endTime,
      );
    } else {
      await SessionPanelService.createSession(
        widget.eventId,
        _filterState.selectedZoneId!,
        _filterState.selectedTrackId!,
        title,
        description,
        speaker,
        startTime,
        endTime,
      );
    }
  }
}
