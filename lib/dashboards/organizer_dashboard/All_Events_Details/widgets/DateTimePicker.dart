import 'package:flutter/material.dart';

class DateTimePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedTime;
  final void Function(DateTime) onSelect;

  const DateTimePicker({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onSelect,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTime ?? DateTime.now()),
    );

    if (time == null) return;

    onSelect(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    final text = selectedTime != null
        ? '${selectedTime!.toLocal()}'.split('.')[0]
        : 'Pick $label';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _pickDateTime(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
