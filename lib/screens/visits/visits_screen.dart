import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/visits_provider.dart';
import '../../models/restaurant_visit.dart';
import '../../widgets/visit_card.dart';
import '../visit_notes_screen.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  final _searchController = TextEditingController();
  List<RestaurantVisit> _filteredVisits = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchVisits(String query) async {
    if (query.isEmpty) {
      final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
      setState(() {
        _filteredVisits = visitsProvider.visits;
      });
      return;
    }

    final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
    final results = await visitsProvider.searchVisits(query);

    setState(() {
      _filteredVisits = results;
    });
  }

  void _showStatsDialog() async {
    final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
    final stats = await visitsProvider.getVisitStats();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Stats'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total Visits', '${stats['totalVisits']}'),
            const SizedBox(height: 8),
            _buildStatRow(
              'Average Rating',
              stats['averageRating'] > 0
                  ? '${stats['averageRating'].toStringAsFixed(1)} ⭐'
                  : 'No ratings yet',
            ),
            const SizedBox(height: 8),
            _buildStatRow('Favorite Cuisine', stats['favoritesCuisine']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search your visits...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _searchVisits,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _showStatsDialog,
                icon: const Icon(Icons.analytics),
                tooltip: 'View Stats',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<VisitsProvider>(
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
                          'Error Loading Visits',
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
                            provider.loadUserVisits();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final visits = _searchController.text.isEmpty
                    ? provider.visits
                    : _filteredVisits;

                if (visits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No Visits Yet'
                              : 'No Results Found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Start exploring restaurants and save your visits here'
                              : 'Try adjusting your search terms',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${visits.length} visit${visits.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: visits.length,
                        itemBuilder: (context, index) {
                          final visit = visits[index];
                          return VisitCard(
                            visit: visit,
                            onTap: () => _navigateToVisitDetail(visit),
                            onDelete: () => _deleteVisit(visit),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToVisitDetail(RestaurantVisit visit) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitNotesScreen(
          restaurant: visit.restaurant,
          existingVisit: visit,
        ),
      ),
    );

    // The provider already updates its internal state, no need to reload
    // Just refresh the search results if there's a search term
    if (mounted && _searchController.text.isNotEmpty) {
      _searchVisits(_searchController.text);
    }
  }

  Future<void> _deleteVisit(RestaurantVisit visit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Visit'),
        content: Text('Are you sure you want to delete your visit to ${visit.restaurant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
      final success = await visitsProvider.deleteRestaurantVisit(visit.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visit deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _searchVisits(_searchController.text);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(visitsProvider.errorMessage ?? 'Failed to delete visit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}