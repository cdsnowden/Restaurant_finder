# Restaurant Finder App

A comprehensive Flutter application that helps users discover restaurants using Google Places API and save their dining experiences with Firebase integration.

## Features

### Core Functionality
- **Restaurant Search**: Search restaurants by zipcode, distance radius, cuisine type, and price range
- **Smart Filtering**: Advanced filters including distance, price range, cuisine types, and open hours
- **"I'm Feeling Lucky"**: Random restaurant selection from search results
- **Visit Tracking**: Save restaurants you've visited with personal notes and reviews
- **Firebase Integration**: Secure data storage with Firestore and user authentication

### User Experience
- **Clean UI**: Modern Material Design 3 interface
- **Authentication**: Email/password or anonymous sign-in options
- **Search History**: Track and review your past restaurant visits
- **Personal Stats**: View your dining statistics and favorite cuisines
- **Restaurant Details**: Comprehensive information including ratings, photos, and hours

## Setup Instructions

### Prerequisites
1. **Flutter SDK**: Install Flutter from [flutter.dev](https://flutter.dev)
2. **Firebase Account**: Create a project at [console.firebase.google.com](https://console.firebase.google.com)
3. **Google Places API Key**: Get an API key from [Google Cloud Console](https://console.cloud.google.com)

### Firebase Configuration

1. **Create Firebase Project**:
   - Go to Firebase Console
   - Create a new project or use existing one
   - Enable Authentication and Firestore Database

2. **Configure Authentication**:
   - In Firebase Console, go to Authentication > Sign-in method
   - Enable "Email/Password" and "Anonymous" providers

3. **Set up Firestore**:
   - Go to Firestore Database
   - Create database in production mode
   - Set security rules as needed

4. **Update Firebase Configuration**:
   - Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration
   - You can get these values from Firebase Console > Project Settings > General tab

### Google Places API Setup

1. **Enable APIs**:
   - Go to Google Cloud Console
   - Enable the following APIs:
     - Places API
     - Geocoding API
     - Maps JavaScript API (optional, for enhanced features)

2. **Create API Key**:
   - Go to Credentials section
   - Create a new API key
   - Restrict the key to the enabled APIs for security

3. **Update API Key**:
   - Open `lib/services/places_service.dart`
   - Replace `YOUR_GOOGLE_PLACES_API_KEY` with your actual API key

### Installation Steps

1. **Clone and Setup**:
   ```bash
   cd restaurant_finder
   flutter pub get
   ```

2. **Configure Platforms**:

   **For Android**:
   - No additional configuration needed

   **For iOS**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Update bundle identifier if needed
   - Add location permissions to `ios/Runner/Info.plist`:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs location access to find nearby restaurants.</string>
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/               # Data models
│   ├── restaurant.dart
│   ├── restaurant_visit.dart
│   └── search_filters.dart
├── providers/            # State management
│   ├── auth_provider.dart
│   ├── restaurant_provider.dart
│   └── visits_provider.dart
├── screens/              # UI screens
│   ├── auth/
│   ├── home/
│   ├── restaurant/
│   └── visits/
├── services/             # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── places_service.dart
├── widgets/              # Reusable UI components
└── main.dart            # App entry point
```

## Usage Guide

### Searching for Restaurants
1. Enter a zip code in the search field
2. Optionally apply filters (distance, price, cuisine, etc.)
3. Tap "Search Restaurants" to find nearby options
4. Use "Lucky" button for random selection

### Saving Restaurant Visits
1. Search and select a restaurant
2. Tap on a restaurant to view details
3. Add your visit with notes about what you ordered
4. Rate the restaurant and write a review

### Managing Visits
1. Go to "My Visits" tab
2. Search through your saved visits
3. View statistics about your dining habits
4. Edit or delete visits as needed

## Quick Start Checklist

- [ ] Flutter SDK installed
- [ ] Firebase project created and configured
- [ ] Google Places API key obtained and configured
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App runs successfully (`flutter run`)
- [ ] Firebase authentication working
- [ ] Restaurant search functionality working
- [ ] Visit saving and retrieval working

## Important Notes

⚠️ **Before Running**:
1. Update `lib/firebase_options.dart` with your Firebase project configuration
2. Replace `YOUR_GOOGLE_PLACES_API_KEY` in `lib/services/places_service.dart` with your actual API key
3. The app currently uses an existing Firebase project - you may want to create your own

For additional help, refer to the official documentation:
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Places API Documentation](https://developers.google.com/maps/documentation/places/web-service)
