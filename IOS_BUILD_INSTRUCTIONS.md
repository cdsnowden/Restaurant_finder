# iOS Build Instructions for Restaurant Finder

This project is configured and ready to build for iOS/App Store on your Mac.

## Project Configuration

- **Bundle Identifier**: `com.chris.restaurantfinder`
- **Version**: 1.0.5 (Build 15)
- **Display Name**: Restaurant Finder

## Prerequisites on Mac

1. **Xcode** installed (from Mac App Store)
2. **Flutter** installed
3. **Apple Developer Account** (for App Store submission)

## Steps to Build on Mac

### 1. Transfer Project to Mac

The project is ready at: `C:\Users\chris\restaurant_finder_ios`

Transfer this entire folder to your Mac using:
- USB drive
- Cloud storage (OneDrive, Google Drive, iCloud)
- Or pull from GitHub: `git pull origin main`

### 2. Setup on Mac

Open Terminal and navigate to the project:

```bash
cd ~/path/to/restaurant_finder_ios
```

Get Flutter dependencies:

```bash
flutter pub get
```

### 3. Configure Signing in Xcode

Open the iOS project in Xcode:

```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **"Runner"** in the left sidebar (project navigator)
2. Go to **"Signing & Capabilities"** tab
3. Under **"Team"**, select your Apple Developer Team
4. Make sure **"Automatically manage signing"** is checked
5. Verify the **Bundle Identifier** shows: `com.chris.restaurantfinder`

### 4. Build for iOS

#### Option A: Build for Testing

```bash
flutter build ios --release
```

#### Option B: Build for App Store (recommended)

```bash
flutter build ipa
```

The `.ipa` file will be created at:
```
build/ios/ipa/restaurant_finder.ipa
```

### 5. Submit to App Store

#### Using Xcode:

1. Open Xcode
2. Go to **Window** → **Organizer**
3. Select the **Archives** tab
4. Click **"Distribute App"**
5. Follow the prompts to upload to App Store Connect

#### Using Transporter App:

1. Open **Transporter** app (download from Mac App Store if needed)
2. Drag and drop the `.ipa` file
3. Click **"Deliver"**

## Troubleshooting

### "No signing certificate found"

1. Go to [developer.apple.com](https://developer.apple.com)
2. Create an **iOS Distribution Certificate**
3. Download and install it on your Mac
4. Return to Xcode and reselect your team

### "Bundle identifier is not available"

The bundle ID `com.chris.restaurantfinder` must be registered in your Apple Developer account:

1. Go to [developer.apple.com/account](https://developer.apple.com/account)
2. Go to **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **+** (plus button)
4. Select **App IDs** → **Continue**
5. Enter:
   - Description: Restaurant Finder
   - Bundle ID: `com.chris.restaurantfinder`
6. Click **Continue** → **Register**

### "Provisioning profile doesn't match"

In Xcode:
1. Select **Runner** → **Signing & Capabilities**
2. Uncheck **"Automatically manage signing"**
3. Then check it again
4. Select your team again

This will regenerate the provisioning profile.

## App Store Connect Setup

Before submitting, create your app in App Store Connect:

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Click **"My Apps"** → **"+"** → **"New App"**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Restaurant Finder
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select `com.chris.restaurantfinder`
   - **SKU**: `restaurant-finder-001`
4. Click **"Create"**

## Version Information

- This is version **1.0.5 (build 15)**
- Includes city/state search functionality
- State dropdown with all 50 US states
- Google Places API integration

## Support

If you encounter issues, you can:
1. Start Claude Code on the Mac: `cd restaurant_finder_ios && npx @anthropic-ai/claude-code`
2. Ask for help with specific error messages
3. Check Flutter logs: `flutter doctor -v`

---

**Created**: 2025-10-10
**Project**: Restaurant Finder iOS Build
