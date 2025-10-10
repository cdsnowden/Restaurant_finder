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
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  SearchFilters _filters = SearchFilters();
  String? _selectedState;

  // List of all U.S. states with abbreviations
  final List<Map<String, String>> _usStates = [
    {'name': 'Alabama', 'abbr': 'AL'},
    {'name': 'Alaska', 'abbr': 'AK'},
    {'name': 'Arizona', 'abbr': 'AZ'},
    {'name': 'Arkansas', 'abbr': 'AR'},
    {'name': 'California', 'abbr': 'CA'},
    {'name': 'Colorado', 'abbr': 'CO'},
    {'name': 'Connecticut', 'abbr': 'CT'},
    {'name': 'Delaware', 'abbr': 'DE'},
    {'name': 'Florida', 'abbr': 'FL'},
    {'name': 'Georgia', 'abbr': 'GA'},
    {'name': 'Hawaii', 'abbr': 'HI'},
    {'name': 'Idaho', 'abbr': 'ID'},
    {'name': 'Illinois', 'abbr': 'IL'},
    {'name': 'Indiana', 'abbr': 'IN'},
    {'name': 'Iowa', 'abbr': 'IA'},
    {'name': 'Kansas', 'abbr': 'KS'},
    {'name': 'Kentucky', 'abbr': 'KY'},
    {'name': 'Louisiana', 'abbr': 'LA'},
    {'name': 'Maine', 'abbr': 'ME'},
    {'name': 'Maryland', 'abbr': 'MD'},
    {'name': 'Massachusetts', 'abbr': 'MA'},
    {'name': 'Michigan', 'abbr': 'MI'},
    {'name': 'Minnesota', 'abbr': 'MN'},
    {'name': 'Mississippi', 'abbr': 'MS'},
    {'name': 'Missouri', 'abbr': 'MO'},
    {'name': 'Montana', 'abbr': 'MT'},
    {'name': 'Nebraska', 'abbr': 'NE'},
    {'name': 'Nevada', 'abbr': 'NV'},
    {'name': 'New Hampshire', 'abbr': 'NH'},
    {'name': 'New Jersey', 'abbr': 'NJ'},
    {'name': 'New Mexico', 'abbr': 'NM'},
    {'name': 'New York', 'abbr': 'NY'},
    {'name': 'North Carolina', 'abbr': 'NC'},
    {'name': 'North Dakota', 'abbr': 'ND'},
    {'name': 'Ohio', 'abbr': 'OH'},
    {'name': 'Oklahoma', 'abbr': 'OK'},
    {'name': 'Oregon', 'abbr': 'OR'},
    {'name': 'Pennsylvania', 'abbr': 'PA'},
    {'name': 'Rhode Island', 'abbr': 'RI'},
    {'name': 'South Carolina', 'abbr': 'SC'},
    {'name': 'South Dakota', 'abbr': 'SD'},
    {'name': 'Tennessee', 'abbr': 'TN'},
    {'name': 'Texas', 'abbr': 'TX'},
    {'name': 'Utah', 'abbr': 'UT'},
    {'name': 'Vermont', 'abbr': 'VT'},
    {'name': 'Virginia', 'abbr': 'VA'},
    {'name': 'Washington', 'abbr': 'WA'},
    {'name': 'West Virginia', 'abbr': 'WV'},
    {'name': 'Wisconsin', 'abbr': 'WI'},
    {'name': 'Wyoming', 'abbr': 'WY'},
  ];

  @override
  void dispose() {
    _zipCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final zipCode = _zipCodeController.text.trim();
    final city = _cityController.text.trim();
    final state = _selectedState ?? '';

    // Validate that either zip code OR (city AND state) is provided
    if (zipCode.isEmpty && (city.isEmpty || state.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a zip code OR both city and state'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final filters = _filters.copyWith(
      zipCode: zipCode,
      city: city,
      state: state,
    );

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

    final randomRestaurant = restaurantProvider.getRandomRestaurant();

    if (randomRestaurant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All restaurants have been removed. Please uncheck some to use this feature.'),
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

  Widget _buildResultsArea(BuildContext context, RestaurantProvider provider) {
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

    return const RestaurantListWidget();
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
                  const SizedBox(height: 12),

                  // OR divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // City Input
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'Enter city name',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _performSearch(),
                  ),
                  const SizedBox(height: 16),

                  // State Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      hintText: 'Select a state',
                      prefixIcon: Icon(Icons.map),
                      border: OutlineInputBorder(),
                    ),
                    items: _usStates.map((state) {
                      return DropdownMenuItem<String>(
                        value: state['abbr'],
                        child: Text('${state['name']} (${state['abbr']})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                      });
                    },
                    isExpanded: true,
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

                  // Minimum Star Rating
                  Text(
                    'Minimum Rating: ${_filters.minRating == 0 ? 'Any' : '${_filters.minRating.toStringAsFixed(1)} ★'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _filters.minRating,
                    min: 0.0,
                    max: 5.0,
                    divisions: 10,
                    label: _filters.minRating == 0 ? 'Any' : '${_filters.minRating.toStringAsFixed(1)} ★',
                    onChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(minRating: value);
                      });
                    },
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
          Consumer<RestaurantProvider>(
            builder: (context, provider, child) {
              // When we have results or are loading, use Expanded to fill remaining space
              if (provider.hasResults || provider.isLoading || provider.errorMessage != null) {
                return Expanded(
                  child: _buildResultsArea(context, provider),
                );
              }

              // Empty state - no message, just empty space
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}