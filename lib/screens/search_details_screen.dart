import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/search_filters.dart';

class SearchDetailsScreen extends StatefulWidget {
  final SearchType searchType;

  const SearchDetailsScreen({
    super.key,
    required this.searchType,
  });

  @override
  State<SearchDetailsScreen> createState() => _SearchDetailsScreenState();
}

class _SearchDetailsScreenState extends State<SearchDetailsScreen> {
  late SearchFilters _filters;
  bool _isLoading = false;

  // Controllers for text inputs
  final _restaurantNameController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _destinationController = TextEditingController();

  String _selectedState = '';
  List<String> _selectedCuisines = [];
  List<int> _selectedPriceRanges = [];
  double _radius = 5.0;
  double _maxDetour = 5.0;
  double _minRating = 0.0;
  bool _openNow = false;

  // For route search
  double? _currentLat;
  double? _currentLng;

  @override
  void initState() {
    super.initState();
    _filters = SearchFilters(searchType: widget.searchType);
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location obtained successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _search() {
    // Build filters based on search type
    SearchFilters filters;

    switch (widget.searchType) {
      case SearchType.restaurantName:
        if (_restaurantNameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a restaurant name')),
          );
          return;
        }
        if (_zipCodeController.text.trim().isEmpty &&
            (_cityController.text.trim().isEmpty || _selectedState.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a location (zip code or city/state)')),
          );
          return;
        }

        filters = SearchFilters(
          searchType: SearchType.restaurantName,
          restaurantName: _restaurantNameController.text.trim(),
          zipCode: _zipCodeController.text.trim(),
          city: _cityController.text.trim(),
          state: _selectedState,
          radiusInMiles: _radius,
          cuisineTypes: _selectedCuisines,
          priceRanges: _selectedPriceRanges,
          openNow: _openNow,
          minRating: _minRating,
        );
        break;

      case SearchType.zipCode:
        if (_zipCodeController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a zip code')),
          );
          return;
        }

        filters = SearchFilters(
          searchType: SearchType.zipCode,
          zipCode: _zipCodeController.text.trim(),
          radiusInMiles: _radius,
          cuisineTypes: _selectedCuisines,
          priceRanges: _selectedPriceRanges,
          openNow: _openNow,
          minRating: _minRating,
        );
        break;

      case SearchType.cityState:
        if (_cityController.text.trim().isEmpty || _selectedState.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter city and state')),
          );
          return;
        }

        filters = SearchFilters(
          searchType: SearchType.cityState,
          city: _cityController.text.trim(),
          state: _selectedState,
          radiusInMiles: _radius,
          cuisineTypes: _selectedCuisines,
          priceRanges: _selectedPriceRanges,
          openNow: _openNow,
          minRating: _minRating,
        );
        break;

      case SearchType.route:
        if (_currentLat == null || _currentLng == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please get your current location first')),
          );
          return;
        }
        if (_destinationController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a destination')),
          );
          return;
        }

        filters = SearchFilters(
          searchType: SearchType.route,
          originLat: _currentLat,
          originLng: _currentLng,
          destinationAddress: _destinationController.text.trim(),
          maxDetourMiles: _maxDetour,
          cuisineTypes: _selectedCuisines,
          priceRanges: _selectedPriceRanges,
          openNow: _openNow,
          minRating: _minRating,
        );
        break;
    }

    // Navigate to results page with filters
    Navigator.pushNamed(
      context,
      '/search-results',
      arguments: filters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildFiltersSection(),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _search,
                    icon: const Icon(Icons.search),
                    label: const Text('Search Restaurants'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getTitle() {
    switch (widget.searchType) {
      case SearchType.restaurantName:
        return 'Search by Name';
      case SearchType.zipCode:
        return 'Search by Zip Code';
      case SearchType.cityState:
        return 'Search by City & State';
      case SearchType.route:
        return 'Search Along Route';
    }
  }

  Widget _buildLocationSection() {
    switch (widget.searchType) {
      case SearchType.restaurantName:
        return _buildRestaurantNameInputs();
      case SearchType.zipCode:
        return _buildZipCodeInput();
      case SearchType.cityState:
        return _buildCityStateInputs();
      case SearchType.route:
        return _buildRouteInputs();
    }
  }

  Widget _buildRestaurantNameInputs() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Restaurant Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _restaurantNameController,
              decoration: const InputDecoration(
                labelText: 'Restaurant Name',
                hintText: 'e.g., Olive Garden',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Search near:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _zipCodeController,
              decoration: const InputDecoration(
                labelText: 'Zip Code (optional)',
                hintText: '12345',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin_drop),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const Center(child: Text('OR')),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City (optional)',
                hintText: 'Columbus',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 8),
            _buildStateDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildZipCodeInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pin_drop, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _zipCodeController,
              decoration: const InputDecoration(
                labelText: 'Zip Code',
                hintText: '12345',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin_drop),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityStateInputs() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_city, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                hintText: 'Columbus',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),
            _buildStateDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInputs() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Route Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: Text(_currentLat != null && _currentLng != null
                  ? 'Location Obtained ✓'
                  : 'Get Current Location'),
              style: FilledButton.styleFrom(
                backgroundColor: _currentLat != null && _currentLng != null
                    ? Colors.green
                    : Colors.purple,
              ),
            ),
            if (_currentLat != null && _currentLng != null) ...[
              const SizedBox(height: 8),
              Text(
                'Starting from: ${_currentLat!.toStringAsFixed(4)}, ${_currentLng!.toStringAsFixed(4)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                hintText: 'Address, city, or zip code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 16),
            Text('Max Detour: ${_maxDetour.toStringAsFixed(1)} miles'),
            Slider(
              value: _maxDetour,
              min: 1.0,
              max: 25.0,
              divisions: 24,
              label: '${_maxDetour.toStringAsFixed(1)} mi',
              onChanged: (value) => setState(() => _maxDetour = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Distance/Radius slider (not for route search)
            if (widget.searchType != SearchType.route) ...[
              Text('Search Radius: ${_radius.toStringAsFixed(1)} miles'),
              Slider(
                value: _radius,
                min: 0.06, // 100 yards
                max: 25.0,
                divisions: 100,
                label: _radius < 0.2
                    ? '${(_radius * 1760).round()} yards'
                    : '${_radius.toStringAsFixed(1)} mi',
                onChanged: (value) => setState(() => _radius = value),
              ),
              const SizedBox(height: 16),
            ],

            // Minimum rating
            Text('Minimum Rating: ${_minRating.toStringAsFixed(1)} stars'),
            Slider(
              value: _minRating,
              min: 0.0,
              max: 5.0,
              divisions: 10,
              label: '${_minRating.toStringAsFixed(1)} ★',
              onChanged: (value) => setState(() => _minRating = value),
            ),
            const SizedBox(height: 16),

            // Open now toggle
            SwitchListTile(
              title: const Text('Open Now'),
              value: _openNow,
              onChanged: (value) => setState(() => _openNow = value),
            ),
            const SizedBox(height: 16),

            // Price ranges
            _buildPriceRangeSelector(),
            const SizedBox(height: 16),

            // Cuisine types
            _buildCuisineSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildStateDropdown() {
    final states = [
      '', 'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
      'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
      'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
      'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
      'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
    ];

    return DropdownButtonFormField<String>(
      value: _selectedState.isEmpty ? '' : _selectedState,
      decoration: const InputDecoration(
        labelText: 'State',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.map),
      ),
      items: states.map((state) {
        return DropdownMenuItem(
          value: state,
          child: Text(state.isEmpty ? 'Select State' : state),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedState = value ?? ''),
    );
  }

  Widget _buildPriceRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price Range:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (int i = 1; i <= 4; i++)
              FilterChip(
                label: Text('\$' * i),
                selected: _selectedPriceRanges.contains(i),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPriceRanges.add(i);
                    } else {
                      _selectedPriceRanges.remove(i);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCuisineSelector() {
    final cuisines = [
      'American', 'Asian', 'Bakery', 'Bar', 'Breakfast', 'Cafe',
      'Chinese', 'Fast Food', 'French', 'Greek', 'Indian',
      'Italian', 'Japanese', 'Korean', 'Kosher', 'Mediterranean',
      'Mexican', 'Middle Eastern', 'Pizza', 'Seafood',
      'Steak', 'Sushi', 'Thai', 'Vegetarian',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cuisine Types:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: cuisines.map((cuisine) {
            return FilterChip(
              label: Text(cuisine),
              selected: _selectedCuisines.contains(cuisine),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCuisines.add(cuisine);
                  } else {
                    _selectedCuisines.remove(cuisine);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
