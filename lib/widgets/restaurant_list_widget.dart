import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../models/restaurant.dart';
import 'restaurant_card.dart';

class RestaurantListWidget extends StatefulWidget {
  const RestaurantListWidget({super.key});

  @override
  State<RestaurantListWidget> createState() => _RestaurantListWidgetState();
}

class _RestaurantListWidgetState extends State<RestaurantListWidget> {
  RestaurantSortOption _sortOption = RestaurantSortOption.distance;

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.75,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.orange.shade50, Colors.white],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.orange.shade50],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                    bottom: BorderSide(color: Colors.orange.shade300, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sort, color: Colors.orange.shade700, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Sort by',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.near_me),
                title: const Text('Distance'),
                trailing: _sortOption == RestaurantSortOption.distance
                    ? const Icon(Icons.check, color: Colors.orange)
                    : null,
                onTap: () {
                  _setSortOption(RestaurantSortOption.distance);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rating'),
                trailing: _sortOption == RestaurantSortOption.rating
                    ? const Icon(Icons.check, color: Colors.orange)
                    : null,
                onTap: () {
                  _setSortOption(RestaurantSortOption.rating);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name'),
                trailing: _sortOption == RestaurantSortOption.name
                    ? const Icon(Icons.check, color: Colors.orange)
                    : null,
                onTap: () {
                  _setSortOption(RestaurantSortOption.name);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Price (Low to High)'),
                trailing: _sortOption == RestaurantSortOption.priceAscending
                    ? const Icon(Icons.check, color: Colors.orange)
                    : null,
                onTap: () {
                  _setSortOption(RestaurantSortOption.priceAscending);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.money_off),
                title: const Text('Price (High to Low)'),
                trailing: _sortOption == RestaurantSortOption.priceDescending
                    ? const Icon(Icons.check, color: Colors.orange)
                    : null,
                onTap: () {
                  _setSortOption(RestaurantSortOption.priceDescending);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _setSortOption(RestaurantSortOption option) {
    setState(() {
      _sortOption = option;
    });
    Provider.of<RestaurantProvider>(context, listen: false).sortRestaurants(option);
  }

  String _getSortOptionText(RestaurantSortOption option) {
    switch (option) {
      case RestaurantSortOption.distance:
        return 'Distance';
      case RestaurantSortOption.rating:
        return 'Rating';
      case RestaurantSortOption.name:
        return 'Name';
      case RestaurantSortOption.priceAscending:
        return 'Price ↑';
      case RestaurantSortOption.priceDescending:
        return 'Price ↓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, provider, child) {
        final restaurants = provider.restaurants;

        if (restaurants.isEmpty) {
          return const Center(
            child: Text('No restaurants found'),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blue.shade300,
                    width: 2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restaurant, color: Colors.blue.shade700, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '${restaurants.length} restaurants found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _showSortOptions,
                    icon: const Icon(Icons.sort, size: 18),
                    label: Text(_getSortOptionText(_sortOption)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: Colors.orange.shade100,
                      foregroundColor: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: restaurants.length + (provider.hasMoreResults ? 1 : 0),
                itemBuilder: (context, index) {
                  // If this is the last item and there are more results, show Load More button
                  if (index == restaurants.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FilledButton.icon(
                        onPressed: provider.isLoadingMore ? null : () async {
                          await provider.loadMoreRestaurants();
                        },
                        icon: provider.isLoadingMore
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add),
                        label: Text(provider.isLoadingMore ? 'Loading...' : 'Load More'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    );
                  }

                  final restaurant = restaurants[index];
                  return RestaurantCard(
                    restaurant: restaurant,
                    onTap: () => _navigateToDetail(restaurant),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetail(Restaurant restaurant) {
    Navigator.pushNamed(
      context,
      '/restaurant_detail',
      arguments: restaurant,
    );
  }
}