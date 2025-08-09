import 'package:flutter/material.dart';

/// Single Responsibility: Handle zone and track dropdown filtering
class ZoneTrackFilter extends StatelessWidget {
  final String? selectedZoneId;
  final String? selectedTrackId;
  final List<Map<String, dynamic>> zones;
  final List<Map<String, dynamic>> tracks;
  final Function(String?) onZoneChanged;
  final Function(String?) onTrackChanged;

  const ZoneTrackFilter({
    super.key,
    required this.selectedZoneId,
    required this.selectedTrackId,
    required this.zones,
    required this.tracks,
    required this.onZoneChanged,
    required this.onTrackChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            value: selectedZoneId,
            hint: const Text('Select Zone'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: 'default',
                child: Text('Default Zone'),
              ),
              ...zones.map((zone) {
                return DropdownMenuItem<String>(
                  value: zone['id'],
                  child: Text(zone['title']),
                );
              }),
            ],
            onChanged: onZoneChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButton<String>(
            value: selectedTrackId,
            hint: const Text('Select Track'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: 'default',
                child: Text('Default Track'),
              ),
              ...tracks.map((track) {
                return DropdownMenuItem<String>(
                  value: track['id'],
                  child: Text(track['title']),
                );
              }),
            ],
            onChanged: onTrackChanged,
          ),
        ),
      ],
    );
  }
}
