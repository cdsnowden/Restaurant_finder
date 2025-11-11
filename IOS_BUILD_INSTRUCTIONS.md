# iOS Build Instructions - Updated Version

## What's Included in This Build

### App Store Compliance Fixes:
- ✅ Added Privacy Policy URL
- ✅ Added Support URL
- ✅ Removed iPad support (iPhone only)
- ✅ Fixes App Store rejections: 1.5.0, 2.3.3, 2.3.8

### Functionality Fixes:
- ✅ Fixed "Get Directions" button (now opens Google Maps properly)
- ✅ Fixed "Along Route" search (updated to new Routes API v2)
- ✅ Route search now works with enabled Google Routes API

---

## Step 1: Open Terminal on Mac
Press `Command + Space`, type "Terminal", press Enter

## Step 2: Navigate to Project
```bash
cd ~/restaurant_finder
```

If that doesn't work, try:
```bash
cd ~/Documents/restaurant_finder
```

## Step 3: Pull Latest Changes from GitHub
```bash
git pull origin main
```

**IMPORTANT:** This downloads all the latest fixes including Routes API v2 update.

## Step 4: Clean Build
```bash
flutter clean
```

## Step 5: Get Dependencies
```bash
flutter pub get
```

## Step 6: Build for App Store
```bash
flutter build ipa
```

This takes 5-10 minutes. Wait for it to finish.

## Step 7: Upload to App Store

### Method 1: Xcode Organizer (EASIEST)
```bash
open build/ios/archive/Runner.xcarchive
```

Then:
1. Click "Distribute App"
2. Select "App Store Connect"
3. Click "Next" through prompts
4. Click "Upload"

### Method 2: Transporter App
1. Open "Transporter" app (from Mac App Store)
2. Drag and drop: `build/ios/ipa/restaurant_finder.ipa`
3. Click "Deliver"

## Step 8: Update App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Select Restaurant Finder
3. Go to the rejected version
4. Under "Build", select the new build you uploaded
5. Click "Save"
6. Click "Submit for Review"

---

## Troubleshooting

### If "flutter" command not found:
Find where Flutter is installed and use full path, or:
```bash
export PATH="$PATH:$HOME/flutter/bin"
```

### If signing errors:
Open project in Xcode first:
```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Runner" on left
2. Go to "Signing & Capabilities"
3. Select your Team
4. Check "Automatically manage signing"

Then try build command again.

### If other errors:
Run diagnostics:
```bash
flutter doctor
```

---

## Current Version
**Version: 1.0.34 (Build 46)**

Includes:
- App Store compliance fixes
- Get Directions button fix
- Routes API v2 update for route search

## Privacy Policy Location
https://github.com/cdsnowden/Restaurant_finder/blob/main/PRIVACY_POLICY.md

## Support URL
https://github.com/cdsnowden/Restaurant_finder

---

## Notes for Your Mac Build

Make sure you're building from the **`restaurant_finder`** folder, NOT the old `restaurant_finder_ios` folder.

The `restaurant_finder` folder has all the latest updates (v1.0.34).
