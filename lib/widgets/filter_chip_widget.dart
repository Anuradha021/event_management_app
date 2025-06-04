import 'package:flutter/material.dart';

class FilterChipsRow extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterChipsRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  Widget _buildChip(String label, String value) {
    final isSelected = selectedFilter == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(value),
      selectedColor: const Color.fromARGB(255, 88, 98, 107),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.grey.shade200,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildChip('All', 'all'),
        _buildChip('Pending', 'pending'),
        _buildChip('Approved', 'approved'),
        _buildChip('Rejected', 'rejected'),
      ],
    );
  }
}
