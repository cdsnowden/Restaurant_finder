import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_update/in_app_update.dart';
import '../../providers/visits_provider.dart';
import 'search_screen.dart';
import '../visits/visits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SearchScreen(),
    const VisitsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VisitsProvider>(context, listen: false).loadUserVisits();
      _checkForUpdate();
    });
  }

  // Check for app updates
  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // Show flexible update (user can continue using app while downloading)
        await InAppUpdate.startFlexibleUpdate();
        // Once download completes, show install prompt
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      // Silently fail if update check fails (e.g., not on Play Store, no internet)
      debugPrint('Update check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Restaurant Finder' : 'My Visits'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.orange,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'My Visits',
          ),
        ],
      ),
    );
  }

}