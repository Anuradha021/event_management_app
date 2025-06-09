import 'package:flutter/material.dart';

class FilterChips extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  _FilterChipsState createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Pending'),
            selected: widget.selectedFilter == 'pending',
            onSelected: (_) => widget.onFilterSelected('pending'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Approved'),
            selected: widget.selectedFilter == 'approved',
            onSelected: (_) => widget.onFilterSelected('approved'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Rejected'),
            selected: widget.selectedFilter == 'rejected',
            onSelected: (_) => widget.onFilterSelected('rejected'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('All'),
            selected: widget.selectedFilter == 'all',
            onSelected: (_) => widget.onFilterSelected('all'),
          ),
        ],
      ),
    );
  }
}
