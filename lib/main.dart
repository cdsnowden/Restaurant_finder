import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/visits_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/search_type_selection_screen.dart';
import 'screens/search_details_screen.dart';
import 'screens/search_results_screen.dart';
import 'models/search_filters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => VisitsProvider()),
      ],
      child: MaterialApp(
        title: 'Restaurant Finder',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.orange,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/search-type-selection': (context) => const SearchTypeSelectionScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/search-filters') {
            final searchType = settings.arguments as SearchType;
            return MaterialPageRoute(
              builder: (context) => SearchDetailsScreen(searchType: searchType),
            );
          }
          if (settings.name == '/search-results') {
            final filters = settings.arguments as SearchFilters;
            return MaterialPageRoute(
              builder: (context) => SearchResultsScreen(filters: filters),
            );
          }
          return null;
        },
      ),
    );
  }
}
