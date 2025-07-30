#!/bin/bash
# scripts/platform-verification.sh - MANDATORY before PR creation

echo "🚀 MANDATORY Platform Verification for PR Creation"
echo "================================================="

# Step 1: Flutter Analysis
echo "📊 Step 1: Flutter Analysis (MUST be <50 issues)"
flutter analyze > analysis_results.txt
issues_count=$(grep -c "•" analysis_results.txt || echo "0")
echo "   Issues found: $issues_count"
if [ "$issues_count" -gt 50 ]; then
    echo "❌ FAILED: Too many issues ($issues_count > 50). Fix issues before PR."
    exit 1
fi
echo "✅ PASSED: Flutter analysis ($issues_count issues)"

# Step 2: Platform Builds
echo "🏗️  Step 2: Platform Builds (ALL must succeed)"

echo "   Building Web..."
if flutter build web --release; then
    echo "✅ PASSED: Web build successful"
else
    echo "❌ FAILED: Web build failed. Fix build before PR."
    exit 1
fi

echo "   Building Android..."  
if flutter build apk --release; then
    echo "✅ PASSED: Android build successful"
else
    echo "❌ FAILED: Android build failed. Fix build before PR."
    exit 1
fi

echo "   Building iOS..."
if flutter build ios --release --no-codesign; then
    echo "✅ PASSED: iOS build successful"
else
    echo "❌ FAILED: iOS build failed. Fix build before PR."
    exit 1
fi

# Step 3: Test Suite
echo "🧪 Step 3: Test Suite (ALL must pass)"
if flutter test; then
    echo "✅ PASSED: All tests successful"
else
    echo "❌ FAILED: Tests failed. Fix tests before PR."
    exit 1
fi

# Step 4: App Execution Verification (Optional but Recommended)
echo "📱 Step 4: App Execution Verification"
echo "   Manual verification required:"
echo "   - flutter run -d chrome --release"
echo "   - flutter run -d android --release" 
echo "   - flutter run -d 'iPhone Simulator' --release"

echo ""
echo "🎉 ALL PLATFORM VERIFICATIONS PASSED!"
echo "✅ Ready to create Pull Request"
echo "================================================="