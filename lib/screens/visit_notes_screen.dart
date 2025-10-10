import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/restaurant.dart';
import '../models/restaurant_visit.dart';
import '../providers/visits_provider.dart';

class VisitNotesScreen extends StatefulWidget {
  final Restaurant restaurant;
  final RestaurantVisit? existingVisit;

  const VisitNotesScreen({
    super.key,
    required this.restaurant,
    this.existingVisit,
  });

  @override
  State<VisitNotesScreen> createState() => _VisitNotesScreenState();
}

class _VisitNotesScreenState extends State<VisitNotesScreen> {
  final _foodOrderedController = TextEditingController();
  final _notesController = TextEditingController();
  double _rating = 3.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingVisit != null) {
      _foodOrderedController.text = widget.existingVisit!.orderNotes ?? '';
      _notesController.text = widget.existingVisit!.userReview ?? '';
      _rating = widget.existingVisit!.userRating ?? 3.0;
    }
  }

  @override
  void dispose() {
    _foodOrderedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVisit() async {
    print('===== VisitNotesScreen._saveVisit START =====');
    setState(() {
      _isLoading = true;
    });

    try {
      print('Getting VisitsProvider...');
      final visitsProvider = Provider.of<VisitsProvider>(context, listen: false);
      print('VisitsProvider obtained');

      bool success;
      if (widget.existingVisit != null) {
        print('MODE: Updating existing visit');
        print('Existing visit ID: ${widget.existingVisit!.id}');
        print('Restaurant: ${widget.restaurant.name}');

        // Update existing visit
        final updatedVisit = RestaurantVisit(
          id: widget.existingVisit!.id,
          userId: widget.existingVisit!.userId,
          restaurant: widget.restaurant,
          visitDate: widget.existingVisit!.visitDate,
          orderNotes: _foodOrderedController.text.trim().isEmpty
              ? null
              : _foodOrderedController.text.trim(),
          userRating: _rating,
          userReview: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        print('Updated visit object created');
        print('Order notes: ${updatedVisit.orderNotes}');
        print('User rating: ${updatedVisit.userRating}');
        print('User review: ${updatedVisit.userReview}');
        print('Calling updateRestaurantVisit...');

        success = await visitsProvider.updateRestaurantVisit(updatedVisit);
        print('updateRestaurantVisit returned: $success');
      } else {
        // Create new visit
        print('MODE: Creating new visit for ${widget.restaurant.name}');
        success = await visitsProvider.saveRestaurantVisit(
          restaurant: widget.restaurant,
          visitDate: DateTime.now(),
          orderNotes: _foodOrderedController.text.trim().isEmpty
              ? null
              : _foodOrderedController.text.trim(),
          userRating: _rating,
          userReview: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        print('saveRestaurantVisit returned: $success');
      }

      print('Final success status: $success');

      if (mounted && success) {
        print('Showing success message and popping navigation');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingVisit != null
                  ? 'Visit updated successfully!'
                  : 'Visit saved successfully!'
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
        print('Navigation popped');
      } else if (mounted) {
        print('Showing failure message');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save visit'),
            backgroundColor: Colors.red,
          ),
        );
      }

      print('===== VisitNotesScreen._saveVisit END (success=$success) =====');
    } catch (e, stackTrace) {
      print('===== VisitNotesScreen._saveVisit ERROR =====');
      print('Error: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving visit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openWebsite() async {
    if (widget.restaurant.website != null && widget.restaurant.website!.isNotEmpty) {
      try {
        final Uri url = Uri.parse(widget.restaurant.website!);
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening website: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No website available for this restaurant'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingVisit != null ? 'Edit Visit' : 'Add Visit Notes',
        ),
        actions: [
          if (widget.restaurant.website != null && widget.restaurant.website!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.launch),
              onPressed: _openWebsite,
              tooltip: 'Visit Website',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.restaurant.address,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (widget.restaurant.rating != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.restaurant.rating!.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Your Rating',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _rating,
                            min: 1.0,
                            max: 5.0,
                            divisions: 8,
                            label: _rating.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _rating = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            Text(
                              _rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'What did you order?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _foodOrderedController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Margherita Pizza, Caesar Salad...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Review',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Share your thoughts about the food, service, atmosphere...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoading ? null : _saveVisit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.existingVisit != null 
                                  ? 'Update Visit' 
                                  : 'Save Visit'
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}