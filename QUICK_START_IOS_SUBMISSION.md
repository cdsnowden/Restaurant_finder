# Quick Start: iOS App Store Submission

## ✅ What's Already Done (On Windows)

1. **iOS Permissions Added** - Info.plist now has required location permissions
2. **Complete App Store Listing Prepared** - See `APP_STORE_LISTING.md`
3. **App Metadata Ready** - Description, keywords, promotional text all written
4. **Privacy Checklist Created** - Know exactly what to answer in App Store Connect

## ❓ Questions You Need to Answer

Before you go to your Mac, please provide:

1. **Contact Email**: ___________________________
   (For App Store listing and app review team)

2. **Phone Number**: ___________________________
   (For app review team - not shown publicly)

3. **Privacy Policy URL**: ___________________________
   Where will you host it? Options:
   - GitHub Pages: https://YOUR-USERNAME.github.io/restaurant_finder/privacy-policy
   - Your website: https://YOUR-DOMAIN.com/privacy-policy
   - Need help setting up GitHub Pages?

4. **Support URL**: ___________________________
   Current: https://github.com/cdsnowden/Restaurant_finder
   Or use a different URL?

## 📋 What You Need To Do BEFORE Mac

### 1. Host Privacy Policy
Your privacy policy is in `privacy-policy.md`. You need to:
- Fix the date (currently says October 3, 2025 - should be 2024)
- Add your contact email
- Host it publicly on a URL

**Quick GitHub Pages Setup** (if you want):
```bash
# On Windows, in your restaurant_finder folder:
git checkout -b gh-pages
mkdir docs
copy privacy-policy.md docs\
git add docs\privacy-policy.md
git commit -m "Add privacy policy"
git push origin gh-pages
```
Then enable GitHub Pages in your repository settings → Pages → Source: gh-pages → /docs

### 2. Prepare Screenshots (Optional but Recommended)
You'll need iPhone screenshots. You can:
- **Option A**: Take them on Mac using iOS Simulator (easiest)
- **Option B**: Use a design tool like Canva/Figma now
- **Option C**: Submit without screenshots initially (not recommended)

Sizes needed:
- 6.7" Display: 1290 x 2796 pixels (iPhone 15 Pro Max)
- OR 6.5" Display: 1242 x 2688 pixels (iPhone 11 Pro Max)
- Need 3-10 screenshots

### 3. Verify App Icon
Check if `assets/icon/app_icon.png` is 1024x1024 pixels:
```bash
# On Windows
# Right-click app_icon.png → Properties → Details → Dimensions
```

## 🍎 When You're On Your Mac

### Phase 1: Setup (1-2 hours)
```bash
# 1. Check macOS version (need 12.0+ for latest Xcode)
sw_vers

# 2. Install Xcode from Mac App Store
# Search for "Xcode" - it's a large download (10-15 GB)

# 3. Install command line tools
xcode-select --install

# 4. Verify Flutter
cd ~/restaurant_finder  # or wherever you cloned it
flutter doctor

# 5. Get dependencies
flutter pub get
```

### Phase 2: Configure Signing (30 mins)
```bash
# 1. Open project
open ios/Runner.xcworkspace

# In Xcode:
# 2. Sign in: Xcode → Preferences → Accounts → Add Apple ID
# 3. Select "Runner" in left sidebar
# 4. Go to "Signing & Capabilities" tab
# 5. Check "Automatically manage signing"
# 6. Select your Team from dropdown
# 7. Verify Bundle ID: com.chris.restaurantfinder
```

### Phase 3: Build (15-30 mins)
```bash
# In Terminal, in your project folder:
flutter clean
flutter pub get
flutter build ipa

# IPA location: build/ios/ipa/restaurant_finder.ipa
```

### Phase 4: Upload (30 mins - 2 hours)
```bash
# Option A: Use Transporter app (recommended)
# 1. Download "Transporter" from Mac App Store
# 2. Open Transporter
# 3. Sign in with Apple ID
# 4. Drag build/ios/ipa/restaurant_finder.ipa into Transporter
# 5. Click "Deliver"

# Option B: Use Xcode
# 1. Xcode → Window → Organizer
# 2. Archives tab
# 3. Select your archive
# 4. Click "Distribute App" → App Store Connect
```

### Phase 5: App Store Connect (1 hour)
1. Go to https://appstoreconnect.apple.com
2. Click "My Apps" → "+" → "New App"
3. Fill in:
   - Platform: iOS
   - Name: Restaurant Finder
   - Primary Language: English (U.S.)
   - Bundle ID: com.chris.restaurantfinder
   - SKU: restaurant-finder-001
4. Click "Create"
5. Fill in all metadata from `APP_STORE_LISTING.md`
6. Upload screenshots (if ready)
7. Select the build you uploaded
8. Submit for review

## 🚨 Common Issues

**"No valid signing identity"**
- Go to Xcode → Preferences → Accounts
- Sign in with your Apple Developer account
- Wait for certificates to download

**"Flutter build ipa fails"**
```bash
flutter clean
rm -rf ios/Pods
rm ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
flutter build ipa
```

**"Your account is not enrolled"**
- Make sure you paid the $99 Apple Developer fee
- Wait 24-48 hours for enrollment to be processed
- Check email for confirmation from Apple

## ⏱️ Timeline

| Task | Time | Status |
|------|------|--------|
| Answer pre-submission questions | 15 mins | ⬜ Not started |
| Host privacy policy | 30 mins | ⬜ Not started |
| Prepare screenshots (optional) | 1-2 hours | ⬜ Not started |
| **[MAC] Install Xcode** | 1-2 hours | ⬜ Not started |
| **[MAC] Configure signing** | 30 mins | ⬜ Not started |
| **[MAC] Build IPA** | 15-30 mins | ⬜ Not started |
| **[MAC] Upload to App Store** | 30 mins - 2 hrs | ⬜ Not started |
| **[MAC] Complete listing** | 1 hour | ⬜ Not started |
| **Apple Review** | 1-3 days | ⬜ Not started |

## 📞 Need Help?

If you run into issues on Mac:
- Check `APP_STORE_LISTING.md` "Common Issues & Solutions" section
- Flutter iOS documentation: https://docs.flutter.dev/deployment/ios
- App Store Connect Help: https://developer.apple.com/app-store-connect/

## 🎉 After Approval

Once approved (usually 24-48 hours):
1. App goes live on App Store automatically OR you can schedule release
2. Users can download it
3. Update `CLAUDE.md` with App Store link
4. Celebrate! 🎊

---

**Next Step**: Answer the 4 questions at the top of this document, then you're ready for Mac!
