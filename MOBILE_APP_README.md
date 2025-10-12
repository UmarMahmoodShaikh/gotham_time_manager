# Gotham Time Manager - Mobile App Setup Guide

This document provides a quick start guide for setting up and running the Vue.js + Cordova mobile app.

## 📍 Location

The mobile app is located in the `mobile-app/` directory of this repository.

## 🚀 Quick Start

### 1. Navigate to the mobile app directory

```bash
cd mobile-app
```

### 2. Install dependencies

```bash
npm install
```

### 3. Create environment file

```bash
cp .env.example .env
```

Edit `.env` to configure your API URL (default is `http://localhost:4000`).

### 4. Run in development mode

```bash
npm run dev
```

The app will open at `http://localhost:8080`.

## 📱 Mobile Development

### Android

```bash
# Add Android platform
npm run cordova:add-android

# Run on Android device/emulator
npm run cordova:run-android

# Build Android APK
npm run cordova:build-android
```

### iOS (macOS only)

```bash
# Add iOS platform
npm run cordova:add-ios

# Run on iOS simulator
npm run cordova:emulate-ios

# Build iOS app
npm run cordova:build-ios
```

## 📚 Full Documentation

For complete documentation, see:
- `mobile-app/README.md` - Full setup and features guide
- `mobile-app/DEPLOYMENT.md` - Production deployment guide

## 🎯 Features

- ⏰ Time tracking with clock in/out
- ☕ Break management
- ✓ Task management
- 📊 Work hour analytics
- 👤 User profile
- ⚙️ Customizable settings

## 🔧 Requirements

- Node.js v16+
- For Android: Android Studio
- For iOS: Xcode (macOS only)
- Cordova CLI: `npm install -g cordova`

## 📖 Project Structure

```
mobile-app/
├── src/               # Source code
│   ├── components/    # Vue components
│   ├── views/         # Page views
│   ├── stores/        # Pinia state management
│   ├── services/      # API services
│   └── router/        # Vue Router
├── config.xml         # Cordova configuration
├── package.json       # Dependencies
└── README.md          # Detailed documentation
```

## 🆘 Troubleshooting

### API Connection Issues
- Ensure the Phoenix backend is running on port 4000
- Check the `VITE_API_URL` in `.env` or Settings page

### Build Errors
```bash
# Clean and reinstall
rm -rf node_modules
npm install
```

### Cordova Issues
```bash
# Reinstall platforms
cordova platform remove android
cordova platform add android
```

## 📞 Support

For questions or issues, refer to the full documentation in `mobile-app/README.md`.

---

Happy coding! 🎉

