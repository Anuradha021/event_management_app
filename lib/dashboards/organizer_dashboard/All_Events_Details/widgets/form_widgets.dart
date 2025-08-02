import 'package:flutter/material.dart';

class ZoneDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> zones;
  final String? selectedZoneId;
  final Function(String?) onChanged;

  const ZoneDropdown({
    required this.zones,
    required this.selectedZoneId,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Select Zone'),
      value: zones.any((z) => z['id'] == selectedZoneId) ? selectedZoneId : null,
      items: zones.map((zone) {
        return DropdownMenuItem<String>(
          value: zone['id'] as String,
          child: Text(zone['title'] as String),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (val) => val == null || val == 'new' ? 'Please select a Zone' : null,
    );
  }
}

class TrackDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> tracks;
  final String? selectedTrackId;
  final Function(String?) onChanged;

  const TrackDropdown({
    required this.tracks,
    required this.selectedTrackId,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Select Track'),
      value: tracks.any((t) => t['id'] == selectedTrackId) ? selectedTrackId : null,
      items: tracks.map((track) {
        return DropdownMenuItem<String>(
          value: track['id'] as String,
          child: Text(track['title'] as String),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (val) => val == null || val == 'new' ? 'Please select a Track' : null,
    );
  }
}

class TimePickerTile extends StatelessWidget {
  final TimeOfDay? time;
  final String label;
  final VoidCallback onTap;

  const TimePickerTile({
    super.key,
    required this.time,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(time == null ? label : '$label: ${time!.format(context)}'),
      trailing: const Icon(Icons.access_time),
      onTap: onTap,
    );
  }
}
