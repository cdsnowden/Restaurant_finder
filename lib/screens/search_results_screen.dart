import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/search_filters.dart';
import '../models/restaurant.dart';
import '../models/restaurant_with_route_info.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_card.dart';
import 'dart:math';

class SearchResultsScreen extends StatefulWidget {
  final SearchFilters filters;

  const SearchResultsScreen({
    super.key,
    required this.filters,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool _isLoading = true;
  List<Restaurant> _restaurants = [];
  List<RestaurantWithRouteInfo> _routeRestaurants = [];
  String? _error;
  String? _sortBy = 'distance';

  @override
  void initState() {
    super.initState();
    // Perform search after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    try {
      final provider = Provider.of<RestaurantProvider>(context, listen: false);

      if (widget.filters.searchType == SearchType.route) {
        // Route-based search
        await provider.searchRestaurantsAlongRoute(widget.filters);
        if (mounted) {
          setState(() {
            _routeRestaurants = provider.routeRestaurants;
            _isLoading = false;
          });
        }
      } else {
        // Regular search
        await provider.searchRestaurants(widget.filters);
        if (mounted) {
          setState(() {
            _restaurants = provider.restaurants;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _feelingLucky() {
    if (widget.filters.searchType == SearchType.route) {
      if (_routeRestaurants.isEmpty) return;
      final random = Random();
      final selected = _routeRestaurants[random.nextInt(_routeRestaurants.length)];
      _showRestaurantDetails(selected.restaurant);
    } else {
      if (_restaurants.isEmpty) return;
      final random = Random();
      final selected = _restaurants[random.nextInt(_restaurants.length)];
      _showRestaurantDetails(selected);
    }
  }

  void _showRestaurantDetails(Restaurant restaurant) {
    // Show bottom sheet with restaurant details (similar to current app)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: RestaurantCard(
                    restaurant: restaurant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sortResults() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.sort, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
            _buildSortOption('Distance', 'distance'),
            _buildSortOption('Rating', 'rating'),
            _buildSortOption('Name', 'name'),
            _buildSortOption('Price (Low to High)', 'price_low'),
            _buildSortOption('Price (High to Low)', 'price_high'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: _sortBy,
        onChanged: (newValue) {
          setState(() {
            _sortBy = newValue;
            _applySorting();
          });
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          _sortBy = value;
          _applySorting();
        });
        Navigator.pop(context);
      },
    );
  }

  void _applySorting() {
    if (widget.filters.searchType == SearchType.route) {
      // Route restaurants are already sorted by position
      if (_sortBy == 'rating') {
        _routeRestaurants.sort((a, b) => (b.restaurant.rating ?? 0).compareTo(a.restaurant.rating ?? 0));
      } else if (_sortBy == 'name') {
        _routeRestaurants.sort((a, b) => a.restaurant.name.compareTo(b.restaurant.name));
      }
      // For route search, distance means detour distance
      else if (_sortBy == 'distance') {
        _routeRestaurants.sort((a, b) => a.distanceFromRouteMeters.compareTo(b.distanceFromRouteMeters));
      }
    } else {
      final provider = Provider.of<RestaurantProvider>(context, listen: false);
      provider.sortRestaurants(_sortBy ?? 'distance');
      setState(() {
        _restaurants = provider.restaurants;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildResultsList(),
    );
  }

  Widget _buildResultsList() {
    final resultCount = widget.filters.searchType == SearchType.route
        ? _routeRestaurants.length
        : _restaurants.length;

    if (resultCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No restaurants found',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Modify Search'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with count and buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blue.shade50],
            ),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.restaurant, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    '$resultCount restaurants found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _feelingLucky,
                      icon: const Icon(Icons.casino),
                      label: const Text('I\'m Feeling Lucky'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonalIcon(
                    onPressed: _sortResults,
                    icon: const Icon(Icons.sort),
                    label: const Text('Sort'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: resultCount,
            itemBuilder: (context, index) {
              if (widget.filters.searchType == SearchType.route) {
                return _buildRouteRestaurantCard(_routeRestaurants[index], index);
              } else {
                return _buildRegularRestaurantCard(_restaurants[index]);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegularRestaurantCard(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRestaurantDetails(restaurant),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (restaurant.rating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                restaurant.address,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (restaurant.priceLevel != null) ...[
                    Text(
                      restaurant.priceLevel!,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (restaurant.isOpenNow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Open Now',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteRestaurantCard(RestaurantWithRouteInfo routeInfo, int index) {
    final restaurant = routeInfo.restaurant;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRestaurantDetails(restaurant),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        color: Colors.purple[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (restaurant.rating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                restaurant.address,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              // Route-specific info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.straighten, size: 16, color: Colors.purple[700]),
                              const SizedBox(width: 4),
                              Text(
                                '${routeInfo.distanceAlongRouteMiles.toStringAsFixed(1)} mi ahead',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.alt_route, size: 16, color: Colors.purple[700]),
                              const SizedBox(width: 4),
                              Text(
                                '${routeInfo.detourMiles.toStringAsFixed(1)} mi detour',
                                style: TextStyle(color: Colors.purple[800]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '~${routeInfo.estimatedDetourMinutes.round()} min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (restaurant.priceLevel != null) ...[
                    Text(
                      restaurant.priceLevel!,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (restaurant.isOpenNow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Open Now',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
