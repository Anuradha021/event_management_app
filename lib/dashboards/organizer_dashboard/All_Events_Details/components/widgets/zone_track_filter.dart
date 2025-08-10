import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

/// Compact zone and track dropdown filtering with modern styling
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: selectedZoneId,
              hint: const Text('Select Zone', style: TextStyle(fontSize: 13)),
              isExpanded: true,
              underline: const SizedBox(),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
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
          Container(
            width: 1,
            height: 16,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: selectedTrackId,
              hint: const Text('Select Track', style: TextStyle(fontSize: 13)),
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
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
      ),
    );
  }
}
