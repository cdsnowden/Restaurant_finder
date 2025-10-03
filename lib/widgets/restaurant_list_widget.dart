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
  RestaurantSortOption _sortOption = RestaurantSortOption.rating;

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sort by',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
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
          ],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${restaurants.length} restaurants found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: _showSortOptions,
                    icon: const Icon(Icons.sort),
                    label: Text(_getSortOptionText(_sortOption)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
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