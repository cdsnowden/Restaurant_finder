import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../models/search_filters.dart';
import '../../widgets/restaurant_list_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _restaurantNameController = TextEditingController();
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
    _restaurantNameController.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final restaurantName = _restaurantNameController.text.trim();
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
      restaurantName: restaurantName,
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
    } else if (restaurantProvider.hasResults && mounted) {
      // Show results in a modal
      _showResultsModal();
    }
  }

  void _showResultsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header with drag handle and close button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Results',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),
              // Drag handle
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // I'm Feeling Lucky button at top
              Consumer<RestaurantProvider>(
                builder: (context, provider, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: FilledButton.icon(
                      onPressed: _feelingLucky,
                      icon: const Icon(Icons.casino, size: 20),
                      label: const Text('I\'m Feeling Lucky'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  );
                },
              ),
              // Results list
              Expanded(
                child: Consumer<RestaurantProvider>(
                  builder: (context, provider, child) {
                    return const RestaurantListWidget();
                  },
                ),
              ),
            ],
          ),
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

  String _getDistanceLabel(double miles) {
    // Show yards for distances under 0.2 miles (350 yards)
    if (miles < 0.2) {
      final yards = (miles * 1760).round();
      return '$yards yards';
    }
    return '${miles.toStringAsFixed(1)} miles';
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
              child: Column(
                children: [
                  // LOCATION SECTION
                  Card(
                    elevation: 4,
                    shadowColor: Colors.orange.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade50, Colors.orange.shade100],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.orange.shade700, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Location',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Restaurant Name Input (Optional)
                              TextField(
                                controller: _restaurantNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Restaurant Name (Optional)',
                                  hintText: 'e.g., Sawmill Grill',
                                  prefixIcon: Icon(Icons.restaurant),
                                  border: OutlineInputBorder(),
                                ),
                                textCapitalization: TextCapitalization.words,
                                onSubmitted: (_) => _performSearch(),
                              ),
                              const SizedBox(height: 16),

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
                                initialValue: _selectedState,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // FILTERS SECTION
                  Card(
                    elevation: 4,
                    shadowColor: Colors.blue.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade50, Colors.blue.shade100],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.tune, color: Colors.blue.shade700, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Filters',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Distance Selector
                              Text(
                                'Distance: ${_getDistanceLabel(_filters.radiusInMiles)} from center',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Slider(
                                value: _filters.radiusInMiles,
                                min: 0.06, // 100 yards
                                max: 25.0,
                                divisions: 100,
                                label: _getDistanceLabel(_filters.radiusInMiles),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CUISINE TYPES SECTION
                  Card(
                    elevation: 4,
                    shadowColor: Colors.orange.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade50, Colors.orange.shade100],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.restaurant_menu, color: Colors.orange.shade700, size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Cuisine Types',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select multiple cuisines (optional)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange.shade200, width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.orange.shade50.withValues(alpha: 0.3),
                            ),
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
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Search Button
                  Consumer<RestaurantProvider>(
                    builder: (context, provider, child) {
                      return FilledButton(
                        onPressed: provider.isLoading ? null : _performSearch,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}