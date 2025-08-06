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
        _buildZoneDropdown(context),
        const SizedBox(height: 16),
        if (selectedZoneId != null && selectedZoneId != 'new')
          _buildTrackDropdown(context),
      ],
    );
  }

  Widget _buildZoneDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Zone',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: zones.any((z) => z['id'] == selectedZoneId) ? selectedZoneId : null,
      items: [
        ...zones.map((zone) {
          return DropdownMenuItem<String>(
            value: zone['id'] as String,
            child: Text(
              zone['title'] as String,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }),
        const DropdownMenuItem<String>(
          value: 'new',
          child: Text(
            '+ Create New Zone',
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
      ],
      onChanged: (val) async {
        if (val == 'new') {
          Navigator.pushNamed(context, '/create-zone');
        } else {
          List<Map<String, dynamic>> updatedTracks = 
              await fetchTracksForZone(eventId, val!);
          onZoneChanged(val, updatedTracks);
        }
      },
      validator: (val) => val == null || val == 'new' 
          ? 'Please select a Zone' 
          : null,
    );
  }

  Widget _buildTrackDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Track',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      value: tracks.any((t) => t['id'] == selectedTrackId) ? selectedTrackId : null,
      items: [
        ...tracks.map((track) {
          return DropdownMenuItem<String>(
            value: track['id'] as String,
            child: Text(
              track['title'] as String,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }),
        const DropdownMenuItem<String>(
          value: 'new',
          child: Text(
            '+ Create New Track',
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
      ],
      onChanged: (val) async {
        if (val == 'new') {
          Navigator.pushNamed(context, '/create-track');
        } else {
          onTrackChanged(val);
        }
      },
      validator: (val) => val == null || val == 'new' 
          ? 'Please select a Track' 
          : null,
    );
  }
}