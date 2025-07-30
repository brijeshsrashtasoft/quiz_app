#!/bin/bash
# quality-check.sh - Run before creating PR

echo "🔍 Running comprehensive quality checks..."

# 1. Format code
echo "📝 Formatting code..."
dart format .

# 2. Analyze code
echo "🔬 Analyzing code..."
if ! flutter analyze; then
    echo "❌ Code analysis failed! Please fix issues before proceeding."
    exit 1
fi

# 3. [TESTS DEFERRED - FOCUS ON MAIN APP]
echo "🏢 Tests deferred - focusing on main app functionality"
echo "   Tests will be added after core features are complete"

# 4. Platform Configuration Check
echo "🔧 Checking platform configuration..."

# Check Android configuration
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  Warning: android/app/google-services.json not found (using placeholder)"
fi

# Check iOS configuration  
if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  Warning: ios/Runner/GoogleService-Info.plist not found (using placeholder)"
fi

# Check iOS deployment target
if ! grep -q "platform :ios, '13.0'" ios/Podfile; then
    echo "❌ iOS deployment target must be 13.0 or higher for Firebase compatibility"
    echo "   Update ios/Podfile: platform :ios, '13.0'"
    exit 1
fi

# Check Android minSdk
if ! grep -q "minSdk = 23" android/app/build.gradle.kts; then
    echo "❌ Android minSdk must be 23 or higher for Firebase compatibility"
    echo "   Update android/app/build.gradle.kts: minSdk = 23"
    exit 1
fi

# 6. Build verification with timeouts
echo "🏗️ Verifying platform builds..."

# Web build (fast)
echo "🌐 Building web..."
if ! timeout 60 flutter build web --release; then
    echo "❌ Web build failed or timed out!"
    exit 1
fi

# Android build (slow, allow more time)
echo "🤖 Building Android (this may take a few minutes)..."
if ! timeout 300 flutter build apk --debug; then
    echo "❌ Android build failed or timed out after 5 minutes!"
    echo "💡 Common fixes:"
    echo "   - Check Firebase configuration files"
    echo "   - Verify NDK version compatibility"
    echo "   - Run 'flutter clean' and retry"
    exit 1
fi

# iOS build check (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Checking iOS build configuration..."
    if ! timeout 120 flutter build ios --debug --no-codesign; then
        echo "❌ iOS build failed or timed out!"
        echo "💡 Common fixes:"
        echo "   - Check iOS deployment target >= 13.0"
        echo "   - Verify Firebase configuration files"
        echo "   - Run 'cd ios && pod install' and retry"
        exit 1
    fi
else
    echo "⏭️  Skipping iOS build (not on macOS)"
fi

echo "✅ All quality checks and platform builds complete!"
echo ""
echo "📱 Platform Status:"
echo "   ✅ Web build successful"
echo "   ✅ Android build successful" 
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   ✅ iOS build successful"
fi
echo ""
echo "🚀 Ready to create PR:"
echo "   git push -u origin \$(git branch --show-current)"
echo "   gh pr create --base development --title 'type(scope): description'"