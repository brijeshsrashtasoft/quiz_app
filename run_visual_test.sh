#!/bin/bash

# Simple E2E Test Runner to see tests visually on screen

echo "🧪 Visual E2E Test Runner for Quiz App"
echo "======================================"

# Check if Android emulator is running
echo "📱 Checking for Android devices..."
flutter devices

echo ""
echo "🎯 Running Splash Screen E2E Test..."
echo "You should see the app launching on your device/emulator"
echo ""

# Run the splash screen test on Android emulator
flutter test integration_test/features/splash/splash_screen_test.dart -d emulator-5554 --verbose

echo ""
echo "✅ Test completed! Check your device screen to see what happened."