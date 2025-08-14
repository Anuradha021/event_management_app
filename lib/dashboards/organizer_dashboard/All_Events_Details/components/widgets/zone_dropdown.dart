import 'package:flutter/material.dart';

class ZoneDropdown extends StatelessWidget {
  final String? selectedZoneId;
  final List<Map<String, dynamic>> zones;
  final Function(String?) onChanged;
  final String hintText;

  const ZoneDropdown({
    super.key,
    required this.selectedZoneId,
    required this.zones,
    required this.onChanged,
    this.hintText = 'Select Zone',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedZoneId?.isEmpty == true ? null : selectedZoneId,
      hint: Text(hintText),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(
          value: 'default',
          child: Text('Select Zone'),
        ),
        ...zones.map((zone) {
          final id = zone['id']?.toString() ?? '';
          final name = zone['title']?.toString() ?? zone['name']?.toString() ?? 'Unnamed Zone';

          return DropdownMenuItem<String>(
            value: id.isEmpty ? null : id,
            child: Text(name),
          );
        }).toList(),
      ],
      onChanged: onChanged,
    );
  }
}
