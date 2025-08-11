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
      value: selectedZoneId,
      hint: Text(hintText),
      isExpanded: true,
      items: zones.map((zone) {
        return DropdownMenuItem<String>(
          value: zone['id'],
          child: Text(zone['title']),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
