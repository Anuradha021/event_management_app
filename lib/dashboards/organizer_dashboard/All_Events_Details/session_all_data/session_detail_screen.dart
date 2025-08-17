import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/session_all_data/session_widget/session_info_card.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/session_all_data/session_widget/update_session_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/core/theme/app_theme.dart';


class SessionDetailScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final String sessionId;
  final Map<String, dynamic> sessionData;
  final DateTime startTime;
  final DateTime endTime;

  const SessionDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.sessionId,
    required this.sessionData,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  Map<String, dynamic> _currentSessionData = {};

  @override
  void initState() {
    super.initState();
    _currentSessionData = Map<String, dynamic>.from(widget.sessionData);
  }

  Future<void> _refreshSessionData() async {
    final doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('zones')
        .doc(widget.zoneId)
        .collection('tracks')
        .doc(widget.trackId)
        .collection('sessions')
        .doc(widget.sessionId)
        .get();

    if (doc.exists && mounted) {
      setState(() => _currentSessionData = doc.data() ?? {});
    }
  }

  Future<void> _updateSession(String title, String desc, String speaker) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc(widget.zoneId)
          .collection('tracks')
          .doc(widget.trackId)
          .collection('sessions')
          .doc(widget.sessionId)
          .update({
        'title': title,
        'description': desc,
        'speaker': speaker,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _refreshSessionData();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating session: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _currentSessionData['title'] ?? 'No Title';
    final description = _currentSessionData['description'] ?? 'No Description';
    final speaker = _currentSessionData['speaker'] ?? 'Not specified';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: const Text('Session Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SessionInfoCard(
              title: title,
              description: description,
              speaker: speaker,
              startTime: widget.startTime,
              endTime: widget.endTime,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => UpdateSessionDialog(
                    currentTitle: title,
                    currentDescription: description,
                    currentSpeaker: speaker,
                    onUpdate: _updateSession,
                  ),
                ),
                icon: const Icon(Icons.edit),
                label: const Text('Update Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
