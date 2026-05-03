# PackRight — Play Store Release Setup Instructions

Follow these steps to prepare your PackRight Flutter app for Google Play Store release.

## Prerequisites
- Flutter SDK installed and in PATH
- Android SDK installed
- Java Development Kit (JDK) 11 or higher
- A Google Play Console developer account ($25 one-time fee)

---

## Step 1: Generate App Icon

### Create Icon Files
1. Create a 1024x1024 PNG file with:
   - White suitcase silhouette
   - Primary teal background (#1B7A6E)
   - No text (text doesn't scale well)

2. Save as `assets/images/app_icon.png`

3. Create a foreground version (for adaptive icons on Android 8.0+):
   - Same design but without background
   - Save as `assets/images/app_icon_foreground.png`
   - Keep within center 66% (safe zone for adaptive icons)

### Generate Icons
```bash
flutter pub get
dart run flutter_launcher_icons
```

This will generate all required icon sizes in `android/app/src/main/res/mipmap-*/ic_launcher.png`

---

## Step 2: Generate Native Splash Screen

```bash
dart run flutter_native_splash:create
```

This creates:
- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/drawable-v21/launch_background.xml`
- Sets background color to #1B7A6E (light) and #134D45 (dark)

---

## Step 3: Generate Signing Key

### Create Keystore
```bash
keytool -genkey -v -keystore ~/packright-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias packright
```

### Fill in Prompts
- Keystore password: Choose a strong password
- Key password: Same as keystore password
- First and last name: PackRight
- Organizational unit: Mobile
- Organization: PackRight
- City: Your city
- State: Your state
- Country: Your country code (e.g., US, IN)

### Update key.properties
Edit `android/key.properties`:
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=packright
storeFile=/full/path/to/packright-release-key.jks
```

**IMPORTANT:** 
- Never commit `android/key.properties` or `*.jks` files to git
- They are already in `.gitignore`
- Back up your keystore file securely (lose it = can't update your app)

---

## Step 4: Update Android Build Configuration

### Edit android/app/build.gradle

Add signing config and update version info:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('android/key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace "com.packright.app"
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.packright.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## Step 5: Secure API Key (Optional but Recommended)

### Option A: Environment Variable (Recommended)
Before building release:
```bash
export GEMINI_API_KEY="your_actual_api_key_here"
```

Update `lib/services/ai_service.dart` to read from const:
```dart
// Replace hardcoded key with:
static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'AIzaSyBkI730IcGvBP_CQdgdgA5ugt8zy4PADFA');
```

### Option B: Keep Hardcoded for MVP
For initial release, the hardcoded key is acceptable since:
- It's a free API with usage limits
- Key is for a specific package name (can be restricted in Google Cloud Console)
- You can regenerate if needed

---

## Step 6: Build Release AAB

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build Android App Bundle (preferred for Play Store)
flutter build appbundle --release

# OR build APK for direct testing
flutter build apk --release
```

### Output Files
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/apk/release/app-release.apk`

---

## Step 7: Test Release Build

```bash
# Install on device
flutter install build/app/outputs/apk/release/app-release.apk

# OR manually install
adb install build/app/outputs/apk/release/app-release.apk
```

### Test Checklist
- [ ] App launches without white flash
- [ ] All screens work correctly
- [ ] AI generation works (check internet permission)
- [ ] Dark mode toggles correctly
- [ ] Data persists across app restarts
- [ ] Share functionality works
- [ ] No crashes or errors

---

## Step 8: Prepare Play Store Assets

### Screenshots (1080x1920 each)
Take screenshots using:
```bash
# On emulator
flutter screenshot

# Or use Android Studio's screenshot tool
```

Required:
- At least 2 screenshots for phone
- At least 1 for 7-inch tablet (optional)
- At least 1 for 10-inch tablet (optional)

### Feature Graphic (1024x500)
Create a promotional banner with:
- PackRight branding
- Suitcase icon
- Teal gradient background
- "Smart Packing List" tagline

### App Icon (512x512)
High-resolution version of your launcher icon

---

## Step 9: Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Fill in store listing:
   - App name: "PackRight — Smart Packing List"
   - Short description: "Describe your trip, get an AI-powered packing list in seconds."
   - Full description: Copy from `PLAY_STORE_LISTING.md`
   - Category: Travel & Local
   - Content rating: Everyone
   - Privacy policy: URL to `PRIVACY_POLICY.md`

4. Upload AAB:
   - Go to Production → Create new release
   - Upload `app-release.aab`
   - Add release notes: "Initial release of PackRight"

5. Upload screenshots and feature graphic

6. Submit for review

---

## Step 10: Post-Release

### Monitor
- Check Play Console for crash reports
- Monitor user reviews
- Track install numbers

### Updates
- Increment versionCode and versionName in build.gradle
- Make changes
- Build new AAB
- Upload as new release

---

## Troubleshooting

### Build Fails: "Signing key not found"
- Check `android/key.properties` path is correct
- Ensure keystore file exists at specified path
- Verify passwords are correct

### App Crashes on Launch
- Check logcat for errors: `adb logcat`
- Verify all permissions in AndroidManifest.xml
- Ensure API key is valid

### White Flash Before Splash
- Verify `flutter_native_splash` was run
- Check `android/app/src/main/res/drawable/launch_background.xml` exists
- Ensure background color matches splash screen

### API Quota Exceeded
- Check Google Cloud Console for usage
- Consider implementing rate limiting
- Upgrade API plan if needed

---

## Final Checklist

- [ ] App icon generated and looks good
- [ ] Native splash screen configured
- [ ] Signing key created and backed up
- [ ] `android/key.properties` configured
- [ ] Build.gradle updated with signing config
- [ ] Release AAB builds without errors
- [ ] Release APK tested on device
- [ ] All 13 screens work in release mode
- [ ] Privacy policy hosted and accessible
- [ ] Play Store listing content prepared
- [ ] Screenshots taken (at least 2)
- [ ] Feature graphic created
- [ ] AAB uploaded to Play Console
- [ ] App submitted for review

---

**Congratulations!** Your PackRight app is ready for the world! 🎉

For questions or support: feedback@packright.app