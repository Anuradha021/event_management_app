import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Quick search bar for the user dashboard
class QuickSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback? onTap;
  final String hintText;
  final bool enabled;

  const QuickSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onTap,
    this.hintText = 'Search events, sessions, stalls...',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        onTap: onTap,
        onSubmitted: onSearch,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textTertiary,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_outlined,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    controller.clear();
                    onSearch('');
                  },
                  color: AppTheme.textTertiary,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            borderSide: BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: AppTheme.bodyMedium,
      ),
    );
  }
}

/// Search suggestions widget
class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const SearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: suggestions.map((suggestion) {
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.search_outlined,
              size: 18,
              color: AppTheme.textTertiary,
            ),
            title: Text(
              suggestion,
              style: AppTheme.bodyMedium,
            ),
            onTap: () => onSuggestionTap(suggestion),
          );
        }).toList(),
      ),
    );
  }
}

/// Advanced search filters
class SearchFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final Map<String, dynamic> initialFilters;

  const SearchFilters({
    super.key,
    required this.onFiltersChanged,
    this.initialFilters = const {},
  });

  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: AppTheme.labelLarge,
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Date filter
          _buildDateFilter(),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Location filter
          _buildLocationFilter(),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Category filter
          _buildCategoryFilter(),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Apply/Clear buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onFiltersChanged(_filters),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date Range', style: AppTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFilterChip(
                'Today',
                _filters['dateRange'] == 'today',
                () => _updateFilter('dateRange', 'today'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterChip(
                'This Week',
                _filters['dateRange'] == 'week',
                () => _updateFilter('dateRange', 'week'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterChip(
                'This Month',
                _filters['dateRange'] == 'month',
                () => _updateFilter('dateRange', 'month'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: AppTheme.bodyMedium),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter location',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
          ),
          onChanged: (value) => _updateFilter('location', value),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Conference', 'Workshop', 'Exhibition', 'Festival', 'Sports'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = (_filters['categories'] as List<String>?)?.contains(category) ?? false;
            return _buildFilterChip(
              category,
              isSelected,
              () => _toggleCategory(category),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiary,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _updateFilter(String key, dynamic value) {
    setState(() {
      if (value == null || (value is String && value.isEmpty)) {
        _filters.remove(key);
      } else {
        _filters[key] = value;
      }
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      final categories = (_filters['categories'] as List<String>?) ?? <String>[];
      if (categories.contains(category)) {
        categories.remove(category);
      } else {
        categories.add(category);
      }
      _filters['categories'] = categories;
    });
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
    });
    widget.onFiltersChanged(_filters);
  }
}
