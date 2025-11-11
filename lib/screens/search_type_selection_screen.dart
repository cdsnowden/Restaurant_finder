import 'package:flutter/material.dart';
import '../models/search_filters.dart';

class SearchTypeSelectionScreen extends StatelessWidget {
  const SearchTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Restaurants'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'How would you like to search?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _SearchTypeCard(
                    icon: Icons.restaurant,
                    title: 'Restaurant\nName',
                    subtitle: 'Find a specific restaurant',
                    color: Colors.orange,
                    onTap: () => _navigateToFilters(context, SearchType.restaurantName),
                  ),
                  _SearchTypeCard(
                    icon: Icons.pin_drop,
                    title: 'Zip Code',
                    subtitle: 'Search by zip code',
                    color: Colors.blue,
                    onTap: () => _navigateToFilters(context, SearchType.zipCode),
                  ),
                  _SearchTypeCard(
                    icon: Icons.location_city,
                    title: 'City & State',
                    subtitle: 'Search by city',
                    color: Colors.green,
                    onTap: () => _navigateToFilters(context, SearchType.cityState),
                  ),
                  _SearchTypeCard(
                    icon: Icons.route,
                    title: 'Along\nRoute',
                    subtitle: 'Restaurants on your path',
                    color: Colors.purple,
                    onTap: () => _navigateToFilters(context, SearchType.route),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFilters(BuildContext context, SearchType searchType) {
    // TODO: Navigate to filters screen with selected search type
    Navigator.pushNamed(
      context,
      '/search-filters',
      arguments: searchType,
    );
  }
}

class _SearchTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SearchTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
