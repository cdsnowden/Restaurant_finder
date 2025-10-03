import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/search_filters.dart';
import '../../widgets/search_filters_widget.dart';
import '../../widgets/restaurant_list_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _zipCodeController = TextEditingController();
  SearchFilters _filters = SearchFilters(zipCode: '');

  @override
  void dispose() {
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_zipCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a zip code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final filters = _filters.copyWith(zipCode: _zipCodeController.text.trim());

    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    await restaurantProvider.searchRestaurants(filters);

    if (restaurantProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(restaurantProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onFiltersChanged(SearchFilters filters) {
    setState(() {
      _filters = filters;
    });
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SearchFiltersWidget(
          filters: _filters,
          onFiltersChanged: _onFiltersChanged,
        ),
      ),
    );
  }

  void _feelingLucky() async {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);

    if (!restaurantProvider.hasResults) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search for restaurants first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    restaurantProvider.showRandomRestaurantOnly();
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

  List<String> _getAvailableCuisines() {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    return restaurantProvider.getSupportedCuisineTypes();
  }

  String _formatCuisineType(String type) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    return restaurantProvider.formatCuisineType(type);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Zip Code Input
                  TextField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Zip Code',
                      hintText: 'Enter zip code',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _performSearch(),
                  ),
                  const SizedBox(height: 16),

                  // Distance Selector
                  Text(
                    'Distance: ${_filters.radiusInMiles.toStringAsFixed(1)} miles from center',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _filters.radiusInMiles,
                    min: 1.0,
                    max: 25.0,
                    divisions: 24,
                    label: '${_filters.radiusInMiles.toStringAsFixed(1)} miles',
                    onChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(radiusInMiles: value);
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price Range Selector (Multiple Selection)
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
                          selected: _filters.priceRanges.contains(i),
                          onSelected: (selected) {
                            setState(() {
                              final newPriceRanges = List<int>.from(_filters.priceRanges);
                              if (selected) {
                                newPriceRanges.add(i);
                              } else {
                                newPriceRanges.remove(i);
                              }
                              _filters = _filters.copyWith(priceRanges: newPriceRanges);
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Open Now Toggle
                  SwitchListTile(
                    title: const Text('Show only restaurants open now'),
                    value: _filters.openNow,
                    onChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(openNow: value);
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cuisine Types
                  Text(
                    'Cuisine Types (select multiple)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      children: _getAvailableCuisines().map((cuisine) {
                        final isSelected = _filters.cuisineTypes.contains(cuisine);
                        return CheckboxListTile(
                          dense: true,
                          title: Text(_formatCuisineType(cuisine)),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              final newCuisines = List<String>.from(_filters.cuisineTypes);
                              if (value == true) {
                                newCuisines.add(cuisine);
                              } else {
                                newCuisines.remove(cuisine);
                              }
                              _filters = _filters.copyWith(cuisineTypes: newCuisines);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Consumer<RestaurantProvider>(
                          builder: (context, provider, child) {
                            return FilledButton(
                              onPressed: provider.isLoading ? null : _performSearch,
                              child: provider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Search Restaurants'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer<RestaurantProvider>(
                        builder: (context, provider, child) {
                          return FilledButton.tonal(
                            onPressed: provider.hasResults ? _feelingLucky : null,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.casino, size: 18),
                                SizedBox(width: 4),
                                Text('I\'m Feeling Lucky'),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<RestaurantProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search Error',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            provider.clearError();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (!provider.hasResults) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Find Great Restaurants',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your zip code and search for restaurants near you',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return const RestaurantListWidget();
              },
            ),
          ),
        ],
      ),
    );
  }
}