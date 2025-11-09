# Restaurant Finder App - Claude Code Documentation

## Project Overview

**Restaurant Finder** is a Flutter mobile application that helps users discover restaurants based on location (zip code or city/state), cuisine type, price range, ratings, and more. Users can save their favorite restaurants, track visits, and leave reviews.

## Current Status

### Version Information
- **Current Version**: 1.0.27 (Build 39)
- **Platform**: Android (Google Play Store - Testing)
- **iOS**: In development (configured, awaiting Mac setup completion)

### Deployment
- **Android**: Deployed to Google Play Store (Internal Testing)
- **iOS**: Configuration complete, build pending
- **GitHub Repository**: https://github.com/cdsnowden/Restaurant_finder.git

## Tech Stack

### Frontend
- **Framework**: Flutter 3.24.5
- **Language**: Dart SDK 3.9.0 (iOS version uses 3.5.0)
- **State Management**: Provider pattern
- **UI**: Material Design 3

### Backend & APIs
- **Google Places API**: Restaurant search and details
- **Google Geocoding API**: Convert zip codes and city/state to coordinates
- **Firebase** (potential future use for monetization features)

### Key Dependencies
- `http`: API requests to Google Places
- `provider`: State management
- `url_launcher`: Open maps, websites, and reviews
- `uuid`: Generate unique IDs
- `shared_preferences`: Local storage for visits

## Implemented Features

### Core Features
1. **Restaurant Search**
   - Search by zip code OR city + state
   - Filter by:
     - Distance (1-25 miles)
     - Cuisine type (50 US states dropdown)
     - Price range (multiple selection: $, $$, $$$, $$$$)
     - Minimum rating (0-5 stars)
     - Open now toggle
   - Multiple cuisine types supported

2. **Restaurant Cards**
   - Display name, address, rating, price level
   - Show "Open Now" status
   - Show cuisine type badge
   - Remove checkbox (filter out unwanted results)
   - Three action buttons:
     - "Choose This Restaurant" - Save to My Visits
     - "Get Directions" - Open Google Maps with turn-by-turn directions
     - "Visit Website" - Open restaurant's website

3. **My Visits Page**
   - View all saved restaurants
   - Track visit dates
   - Add personal notes:
     - What you ordered
     - Your rating (1-5 stars)
     - Your review
   - "Leave Google Review" button - Opens Google's review page
   - Delete visits

4. **Random Selection**
   - "I'm Feeling Lucky" button
   - Randomly picks from search results
   - Excludes removed restaurants

### API Integration
- Uses Google Places API for:
  - Nearby search (no cuisine filter)
  - Text search (with cuisine filter)
  - Place details (full info including website, photos)
  - Geocoding (location conversion)

## Bundle Identifiers
- **Android**: `com.chris.restaurantfinder`
- **iOS**: `com.chris.restaurantfinder`

## Monetization Ideas (Under Exploration)

### 1. Restaurant Promotional Offers
**Concept**: Allow restaurants to upload promotional images (coupons, deals) that appear to users.

**User Flow**:
1. User searches for restaurants
2. After clicking "Search Restaurants", a promotional offer image appears
3. Two buttons: "Close" or "Accept Offer"
4. If "Accept Offer" → Image saves to user's gallery
5. User shows saved image at restaurant to redeem

**Restaurant Side**:
- Self-service portal where restaurants log in
- Upload promotional images
- Set targeting criteria (location, cuisine type)
- Track views and redemptions

**Validation Options Discussed**:
- **Option 1 (QR Code)**: Generate QR code on offer, restaurant scans with any QR scanner app
- **Option 4 (Validation Code)**: Generate 6-digit code, restaurant enters on web portal to validate

**Pricing Tiers**:
- Basic: $X/month - 1 offer, shown occasionally
- Premium: $Y/month - Multiple offers, priority display, analytics
- Featured: $Z/month - Always shown first, unlimited offers

### 2. Geofencing
**Concept**: Use location-based notifications to alert users about nearby restaurants and offers.

**Capabilities**:
- Notify users when near saved/"favorite" restaurants
- Auto-trigger offers when entering geofenced area
- Automatic visit tracking
- Background location monitoring

**Restaurant Options**:
- **Standard**: Geofence around own location (0.25-1 mile radius)
- **Strategic** (controversial): Geofence competitor locations to intercept customers
  - Example: Near McDonald's → notification from Burger King
  - Higher pricing, ethical considerations

**Pricing Ideas**:
- Tier 1: Own location only ($50-100/month)
- Tier 2: Multiple locations or competitor targeting ($200-500/month)
- Tier 3: Territory control, unlimited geofences ($1000+/month)

**Considerations**:
- Requires "Always Allow" location permission
- Battery optimization needed
- Privacy compliance (transparent data use)
- Potential legal issues with competitor targeting

### 3. Delivery Service Integration
**Options**:
- **Affiliate Links** (Easiest): Link to DoorDash/Uber Eats, earn 1-5% commission
- **Deep Links**: Open delivery apps directly with pre-selected restaurant
- **API Integration**: Full in-app ordering (requires partnerships, 5-15% commission)
- **Aggregator Services**: One integration for multiple platforms

**Implementation**:
- Add "Order Delivery" button to restaurant cards
- Check available delivery services for that restaurant
- Track which service user chooses
- Revenue: $0.50-$5 per order depending on integration type

### Other Ideas Mentioned
- Subscription model (premium features for users)
- Commission from reservations
- Sponsored search results
- Analytics packages for restaurants
- White-label versions

## Technical Capabilities Confirmed

Claude Code can implement:
- ✅ QR code generation and validation
- ✅ Validation code system (6-digit codes)
- ✅ Restaurant admin portal (Flutter web or HTML)
- ✅ Image upload to Firebase Storage
- ✅ Geofencing with background location tracking
- ✅ Push notifications
- ✅ Delivery service integration (links or APIs)
- ✅ Analytics dashboards
- ✅ Payment integration (Stripe, etc.)

## Architecture Notes

### File Structure
- `lib/models/` - Data models (Restaurant, SearchFilters, RestaurantVisit)
- `lib/providers/` - State management (RestaurantProvider, VisitsProvider)
- `lib/services/` - API services (PlacesService, VisitService)
- `lib/screens/` - UI screens (SearchScreen, VisitsScreen, etc.)
- `lib/widgets/` - Reusable components (RestaurantCard, VisitCard)

### Key Services
- **PlacesService**:
  - Handles all Google Places API calls
  - Geocoding for zip codes and city/state
  - Distance calculation using Haversine formula
  - Cuisine type formatting

- **VisitService**:
  - Local storage of restaurant visits
  - Uses SharedPreferences
  - Platform-specific implementations (web, mobile, stub)

## Build Commands

### Android
```bash
flutter build appbundle --release  # For Google Play Store
flutter build apk --release        # For direct installation
```

### iOS (on Mac)
```bash
flutter build ipa                  # Requires Xcode configured
open ios/Runner.xcworkspace        # Configure signing
```

### Build Locations
- **Android AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **Android APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **iOS IPA**: `build/ios/ipa/restaurant_finder.ipa`

## Version History

### v1.0.27 (Build 39) - Current
- **Added Kosher Cuisine Type**:
  - Added "Kosher" to the cuisine types filter list
  - Users can now search specifically for kosher restaurants
  - Appears alphabetically in the cuisine selection list between Korean and Mediterranean
  - Works with all existing filters (distance, price, rating, etc.)

### v1.0.19 (Build 29)
- **Added Restaurant Name Search**:
  - New optional "Restaurant Name" field in search screen
  - Search by name works independently with location (zip code OR city/state)
  - Helps users find specific restaurants like "Sawmill Grill"
  - Uses Google Places Text Search API for accurate name matching

- **Added Pagination ("Load More" Button)**:
  - Overcomes Google Places API 20 result limit
  - "Load More" button appears at bottom of results when more are available
  - Fetches next 20 results without losing current list
  - Smooth loading indicator shows when fetching additional results
  - All filters (distance, price, rating, etc.) apply to paginated results

### v1.0.18 (Build 28)
- **Added Breakfast Cuisine Type**:
  - Added "Breakfast" to the cuisine types filter list
  - Users can now search specifically for breakfast restaurants
  - Appears alphabetically in the cuisine selection list
  - Works with all existing filters (distance, price, rating, etc.)

### v1.0.17 (Build 27)
- **Reduced Minimum Distance to 100 Yards**:
  - Minimum search distance reduced from 1 mile to 100 yards
  - Perfect for users looking for walking-distance restaurants
  - Distance display shows yards for distances under 0.2 miles (350 yards)
  - Smoother slider control with 100 divisions for precise distance selection
  - Range now: 100 yards to 25 miles

### v1.0.16 (Build 26)
- **Added Close Button to Restaurant Cards**:
  - New "Close" button added below Get Directions and Visit Website buttons
  - Closes the results modal and returns to search screen
  - Provides easy way to exit from viewing restaurant details
  - Especially useful after using "I'm Feeling Lucky" feature

### v1.0.15 (Build 25)
- **Added Close Button to Results Modal**:
  - New header bar at top of results modal
  - "Search Results" title on the left
  - Close button (X icon) on the right with gray background
  - Users can now easily dismiss the modal with one tap
  - Alternative to swiping down to close
  - Drag handle still available below the header

### v1.0.14 (Build 24)
- **Fixed "I'm Feeling Lucky" Button**:
  - Button no longer closes the results modal
  - Randomly selected restaurant now displays in the modal
  - Users can see their lucky pick and take action (directions/website)
  - Removed `Navigator.pop()` call that was dismissing the modal

### v1.0.13 (Build 23)
- **Enhanced "Choose Restaurant" Confirmation**:
  - Replaced simple snackbar with prominent confirmation modal
  - Large green checkmark icon for clear visual feedback
  - "Restaurant Saved!" heading with restaurant name
  - "What would you like to do next?" prompt with action buttons:
    - 🗺️ **Get Directions** (blue button) - Opens Google Maps immediately
    - 🌐 **Visit Website** (orange button) - Opens restaurant website immediately
    - **Done** (outlined button) - Closes modal and returns to results
  - All actions easily accessible right after saving
  - Much clearer workflow for users

### v1.0.12 (Build 22)
- **Results Shown in Popup Modal**:
  - Search results now appear in a draggable bottom sheet modal
  - Keeps search form always visible - no more scrolling between form and results
  - "I'm Feeling Lucky" button moved to top of results modal (orange, full-width)
  - Modal opens at 90% screen height, can be dragged to resize (50%-95%)
  - Sort button and all filtering options accessible within modal
  - Drag handle at top for easy dismissal
  - Much cleaner navigation between search and results
  - Removed inline results display from main screen

### v1.0.11 (Build 21)
- **Fixed Sort Modal Overflow**:
  - Replaced SingleChildScrollView with DraggableScrollableSheet
  - Modal now properly scrolls to show all 5 sort options
  - Users can drag to expand/collapse the sheet
  - Initial size: 50% of screen, expandable to 75%
  - Fully accessible on all screen sizes

### v1.0.10 (Build 20)
- **Enhanced Color Scheme** (Orange, Blue, White):
  - **Location Card**: Orange gradient header with location icon, orange border/shadow
  - **Filters Card**: Blue gradient header with tune icon, blue border/shadow
  - **Cuisine Types Card**: Orange gradient header with restaurant menu icon, orange-tinted scrollable list
  - **Results Header**: Blue gradient background with restaurant icon
  - **Sort Button**: Orange-tinted button that stands out
  - **Sort Modal**: Orange gradient header, scrollable bottom sheet
  - Increased card elevation (elevation: 4) for depth
  - Added colored shadows matching card themes
  - Larger icons (size: 28) in headers for better visibility
  - Clear visual separation between all sections

### v1.0.9 (Build 19)
- **UI/UX Improvements**:
  - Made sort button more prominent (FilledButton.tonal with background color)
  - Fixed sort modal overflow - now scrollable to see all options
  - Reorganized search screen into 3 separate cards for better visual hierarchy:
    - **Location Card**: Zip code OR city/state inputs
    - **Filters Card**: Distance, price range, rating, open now toggle
    - **Cuisine Types Card**: Scrollable list with border for better differentiation
  - Added colored section headers with icons for each card
  - Improved spacing and visual separation between sections

### v1.0.8 (Build 18)
- Added sorting options for search results
- Sort by: Distance (default), Rating, Name, Price (Low to High), Price (High to Low)
- Distance sorting uses search center coordinates (zip code or city/state location)
- Sort dropdown accessible from restaurant results list

### v1.0.7 (Build 17)
- Added "Leave Google Review" button to My Visits page
- Opens Google's review page for specific restaurant

### v1.0.6 (Build 16)
- Added "Get Directions" button to restaurant cards
- Opens Google Maps with turn-by-turn directions
- Uses GPS coordinates for accuracy

### v1.0.5 (Build 15)
- Added city/state search functionality
- State dropdown with all 50 US states
- Google Geocoding API integration
- Users can search by zip code OR city + state

### Earlier Versions
- Core restaurant search functionality
- My Visits page with notes and ratings
- Remove/filter restaurants from results
- "I'm Feeling Lucky" random selection

## Development Environment

### Windows Setup
- Flutter installed
- Android Studio configured
- Google Play Console access
- Git repository: Restaurant_finder

### Mac Setup (iOS Development)
- macOS 11.1 (Big Sur) - needs update for latest Xcode
- Flutter installed (3.24.5)
- Xcode installation pending
- CocoaPods installed
- Node.js and Claude Code CLI installed

## API Keys & Configuration

### Google APIs
- Google Places API key: `AIzaSyCgoC5_2Ap1P1qJptgZvq8vKaa3JEgBVqc`
- Used for: Places search, Geocoding, Place details

**Note**: API key is currently hardcoded in `lib/services/places_service.dart`. Consider moving to environment variables for production.

## Future Considerations

### Short-term (Under Discussion)
- Finalize monetization strategy
- Restaurant promotional offer system
- Validation/redemption tracking

### Medium-term
- Geofencing implementation
- Delivery service integration
- Restaurant admin portal
- Payment processing

### Long-term
- Analytics dashboard for restaurants
- Multi-language support
- Restaurant reservations
- User reviews within app
- Social features (share restaurants)

## Known Issues / TODOs

- iOS build pending (waiting for Mac setup completion)
- API key should be moved to secure storage
- Consider adding error handling for offline scenarios
- Rate limiting on API calls (cost management)

## Contact & Resources

- **Developer**: Chris
- **Repository**: https://github.com/cdsnowden/Restaurant_finder.git
- **Google Play Store**: Internal Testing
- **Apple Developer Program**: Enrollment needed ($99/year)

---

**Last Updated**: 2025-11-07
**Current Focus**: Added Kosher cuisine type to support dietary and religious preferences in restaurant search
