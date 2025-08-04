import 'package:event_management_app1/dashboards/organizer_dashboard/services/session_firestore_service.dart';
import 'package:flutter/material.dart';

class SessionDropdowns extends StatelessWidget {
  final String eventId;
  final String? selectedZoneId;
  final String? selectedTrackId;
  final List<Map<String, dynamic>> zones;
  final List<Map<String, dynamic>> tracks;
  final void Function(String?, List<Map<String, dynamic>>) onZoneChanged;
  final void Function(String?) onTrackChanged;

  const SessionDropdowns({
    super.key,
    required this.eventId,
    required this.selectedZoneId,
    required this.selectedTrackId,
    required this.zones,
    required this.tracks,
    required this.onZoneChanged,
    required this.onTrackChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select Zone'),
          value: zones.any((z) => z['id'] == selectedZoneId) ? selectedZoneId : null,
          items: zones.map((zone) {
            return DropdownMenuItem<String>(
              value: zone['id'] as String,
              child: Text(zone['title'] as String),
            );
          }).toList(),
          onChanged: (val) async {
            if (val == 'new') {
              Navigator.pushNamed(context, '/create-zone');
            } else {
              List<Map<String, dynamic>> updatedTracks = await fetchTracksForZone(eventId, val!);
              onZoneChanged(val, updatedTracks);
            }
          },
          validator: (val) => val == null || val == 'new' ? 'Please select a Zone' : null,
        ),
        const SizedBox(height: 12),
        if (selectedZoneId != null && selectedZoneId != 'new')
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Track'),
            value: tracks.any((t) => t['id'] == selectedTrackId) ? selectedTrackId : null,
            items: tracks.map((track) {
              return DropdownMenuItem<String>(
                value: track['id'] as String,
                child: Text(track['title'] as String),
              );
            }).toList(),
            onChanged: (val) async {
              if (val == 'new') {
                Navigator.pushNamed(context, '/create-track');
              } else {
                onTrackChanged(val);
              }
            },
            validator: (val) => val == null || val == 'new' ? 'Please select a Track' : null,
          ),
      ],
    );
  }
}
