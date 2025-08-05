# 📱 Realme 7 Setup Guide for Flutter Development

## 🔧 Step 1: Enable Developer Options

1. **Go to Settings** on your Realme 7
2. **Scroll down and tap "About Phone"**
3. **Find "Build Number"** (usually at the bottom)
4. **Tap "Build Number" 7 times** - You'll see "You are now a developer!"
5. **Go back to Settings**
6. **Find "Additional Settings"** or "System"
7. **Tap "Developer Options"**
8. **Enable the "Developer Options" toggle**

## 🔌 Step 2: Enable USB Debugging

1. **In Developer Options, enable:**
   - ✅ **USB Debugging**
   - ✅ **Install via USB**
   - ✅ **USB Debugging (Security Settings)**
   - ✅ **Stay Awake** (optional, keeps screen on)

## 📲 Step 3: Connect Your Phone

1. **Connect your Realme 7 to PC via USB cable**
2. **On your phone, you'll see a popup: "Allow USB Debugging?"**
3. **Tap "Allow" and check "Always allow from this computer"**
4. **Set USB mode to "File Transfer" or "MTP"**

## 🖥️ Step 4: Install ADB Drivers (if needed)

If your PC doesn't recognize the phone:
1. Download Realme USB drivers from official website
2. Or install Universal ADB drivers
3. Restart your PC after installation

## 🚀 Step 5: Test Connection

Run this command in terminal:
```bash
adb devices
```

You should see your device listed like:
```
List of devices attached
ABC123DEF456    device
```

## 📱 Step 6: Run Flutter App

Once connected, run:
```bash
flutter run
```

## 🔍 Troubleshooting

### If device not detected:
1. Try different USB cable
2. Try different USB port
3. Reinstall ADB drivers
4. Restart both phone and PC

### If "adb devices" shows "unauthorized":
1. Check USB debugging is enabled
2. Allow USB debugging on phone popup
3. Revoke USB debugging and re-enable

### If Flutter can't find device:
1. Run `flutter doctor`
2. Make sure Android SDK is properly installed
3. Check if device appears in `flutter devices`

## 📋 Required Permissions

Make sure your app has these permissions in `android/app/src/main/AndroidManifest.xml`:
- Camera
- Internet
- Storage (if needed)

## 🎯 Success Indicators

✅ Device shows in `flutter devices`
✅ `flutter run` starts successfully
✅ App installs and opens on phone
✅ Camera works properly
✅ No more pixelated feed!

## 📞 Need Help?

If you encounter issues:
1. Check Realme official support
2. Try different USB cables
3. Update phone to latest OS version
4. Clear USB debugging cache in Developer Options 