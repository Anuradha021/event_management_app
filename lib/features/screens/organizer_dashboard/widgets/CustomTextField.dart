import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }
}
