import 'package:flutter/material.dart';
import '../models/search_filters.dart';

class SearchFiltersWidget extends StatefulWidget {
  final SearchFilters filters;
  final Function(SearchFilters) onFiltersChanged;

  const SearchFiltersWidget({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget> {
  late double _radiusInMiles;
  late List<String> _selectedCuisines;
  late List<int> _priceRanges;
  late bool _openNow;

  final List<String> _availableCuisines = [
    'american_restaurant',
    'chinese_restaurant',
    'italian_restaurant',
    'mexican_restaurant',
    'japanese_restaurant',
    'indian_restaurant',
    'thai_restaurant',
    'french_restaurant',
    'greek_restaurant',
    'korean_restaurant',
    'mediterranean_restaurant',
    'middle_eastern_restaurant',
    'pizza_restaurant',
    'seafood_restaurant',
    'steak_house',
    'sushi_restaurant',
    'vegetarian_restaurant',
    'fast_food_restaurant',
    'cafe',
    'bakery',
    'bar',
  ];

  @override
  void initState() {
    super.initState();
    _radiusInMiles = widget.filters.radiusInMiles;
    _selectedCuisines = List.from(widget.filters.cuisineTypes);
    _priceRanges = List.from(widget.filters.priceRanges);
    _openNow = widget.filters.openNow;
  }

  String _formatCuisineType(String type) {
    return type
        .replaceAll('_', ' ')
        .replaceAll('restaurant', '')
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  String _getPriceDescription(int level) {
    switch (level) {
      case 1:
        return 'Budget';
      case 2:
        return 'Mid-range';
      case 3:
        return 'Expensive';
      case 4:
        return 'Very Expensive';
      default:
        return '';
    }
  }

  void _applyFilters() {
    final newFilters = widget.filters.copyWith(
      radiusInMiles: _radiusInMiles,
      cuisineTypes: _selectedCuisines,
      priceRanges: _priceRanges,
      openNow: _openNow,
    );
    widget.onFiltersChanged(newFilters);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _radiusInMiles = 5.0;
      _selectedCuisines.clear();
      _priceRanges.clear();
      _openNow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Filters',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Distance: ${_radiusInMiles.toStringAsFixed(1)} miles',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _radiusInMiles,
            min: 1.0,
            max: 25.0,
            divisions: 24,
            onChanged: (value) {
              setState(() {
                _radiusInMiles = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Price Range (select multiple)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (int i = 1; i <= 4; i++)
                FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$' * i),
                      const SizedBox(width: 4),
                      Text(_getPriceDescription(i), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  selected: _priceRanges.contains(i),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _priceRanges.add(i);
                      } else {
                        _priceRanges.remove(i);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Open Now'),
            value: _openNow,
            onChanged: (value) {
              setState(() {
                _openNow = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Cuisine Types',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView(
              children: _availableCuisines.map((cuisine) {
                final isSelected = _selectedCuisines.contains(cuisine);
                return CheckboxListTile(
                  title: Text(_formatCuisineType(cuisine)),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedCuisines.add(cuisine);
                      } else {
                        _selectedCuisines.remove(cuisine);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _applyFilters,
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}